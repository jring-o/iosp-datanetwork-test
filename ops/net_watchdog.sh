#!/bin/bash
# iosp-net-watchdog — self-healing network recovery for IOSP nodes.
#
# Motivation: on 2026-08-02 node-00's on-board Wi-Fi firmware wedged (SDIO bus
# errors, then every command timing out with -110). The node was healthy but
# offline for 4 days; a driver reload revived it in seconds. Participants'
# nodes will be far from any keyboard — this watchdog encodes the recovery
# ladder so nobody has to drive 500 km with a monitor.
#
# Run every 2 minutes by iosp-net-watchdog.timer. Escalation ladder, driven by
# consecutive failed internet probes (one probe per run):
#
#   healthy                  -> reset counter, exit
#   L1  count >= 5  (~10 m)  -> re-activate the Wi-Fi profile (nmcli up)
#   L2  count >= 8  (~16 m)  -> reload the Wi-Fi driver, then L1
#                               (only if the link is down, OR count >= 30 (~1 h):
#                                a wedged radio can claim "connected" for days —
#                                seen on node-00 — so a long outage forces it)
#   L3  count >= 15 (~30 m)  -> reboot — only if the link is STILL down after a
#                               driver reload (radio truly dead), or forced at
#                               count >= 180 (~6 h) for unknown-unknowns.
#                               Rate-limited: at most one watchdog reboot per 6 h
#                               (stamp survives reboots), so an ISP outage can
#                               never cause a reboot loop.
#
# An ISP outage (Wi-Fi associated with an address, internet dark) therefore
# never triggers a reboot in its first 6 hours, and never a driver reload in
# its first hour — the node just waits, like it should.
#
# ADDING RECIPES: as new failure modes are diagnosed (see docs/triage), add a
# detection + remedy pair below at the marked spot, log every action with
# `note`, and keep remedies idempotent — this script must always be safe to
# run on a healthy node.

set -u

TAG="iosp-net-watchdog"
STATE_DIR="/run/iosp-net-watchdog"          # tmpfs: counter resets on boot
PERSIST_DIR="/var/lib/iosp-net-watchdog"    # survives reboots: reboot stamp
COUNT_FILE="$STATE_DIR/fail_count"
REBOOT_STAMP="$PERSIST_DIR/last-reboot"

L1_AT=5          # ~10 min: reconnect Wi-Fi profile
L2_AT=8          # ~16 min: driver reload (if link down)
L2_FORCE_AT=30   # ~1 h:   driver reload even if link claims connected
L3_AT=15         # ~30 min: reboot (only if link still down after reload)
L3_FORCE_AT=180  # ~6 h:   reboot regardless (rate-limited)
REBOOT_MIN_GAP=$((6 * 3600))

mkdir -p "$STATE_DIR" "$PERSIST_DIR"

note() { logger -t "$TAG" -- "$1"; echo "$1"; }

# --- observe -----------------------------------------------------------------

internet_up() {
  curl -sm 8 -o /dev/null https://one.one.one.one && return 0
  ping -c1 -W4 1.1.1.1 >/dev/null 2>&1 && return 0
  ping -c1 -W4 8.8.8.8 >/dev/null 2>&1 && return 0
  return 1
}

WIFI_IF=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')
WIFI_PROFILE=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2=="802-11-wireless"{print $1; exit}')

link_up() {
  [ -n "$WIFI_IF" ] || return 1
  nmcli -t -f GENERAL.STATE device show "$WIFI_IF" 2>/dev/null | grep -q "(connected)" || return 1
  ip -4 addr show dev "$WIFI_IF" 2>/dev/null | grep -q "inet " || return 1
  return 0
}

# --- remedies ----------------------------------------------------------------

remedy_reconnect() {
  note "L1: re-activating Wi-Fi profile '${WIFI_PROFILE:-<none found>}'"
  [ -n "$WIFI_PROFILE" ] && nmcli connection up "$WIFI_PROFILE" >/dev/null 2>&1
}

remedy_driver_reload() {
  # The fix proven on node-00 2026-08-06: brcmfmac must be freed (stop the
  # managers, down the link) before it will unload; the vendor sub-module
  # (brcmfmac_cyw / _wcc / _bca — chip-dependent) must go first.
  local variant
  variant=$(lsmod | awk '$1 ~ /^brcmfmac_/{print $1; exit}')
  note "L2: reloading Wi-Fi driver (variant: ${variant:-none})"
  systemctl stop NetworkManager wpa_supplicant >/dev/null 2>&1
  [ -n "$WIFI_IF" ] && ip link set "$WIFI_IF" down 2>/dev/null
  # shellcheck disable=SC2086
  modprobe -r $variant brcmfmac 2>/dev/null || { sleep 2; modprobe -r $variant brcmfmac 2>/dev/null; }
  sleep 2
  [ -n "$variant" ] && modprobe "$variant" 2>/dev/null
  modprobe brcmfmac 2>/dev/null
  systemctl start NetworkManager >/dev/null 2>&1
  sleep 15
  remedy_reconnect
}

remedy_reboot() {
  local now last gap
  now=$(date +%s)
  last=$(cat "$REBOOT_STAMP" 2>/dev/null || echo 0)
  gap=$((now - last))
  if [ "$gap" -lt "$REBOOT_MIN_GAP" ]; then
    note "L3: reboot wanted but rate-limited (last watchdog reboot ${gap}s ago)"
    return
  fi
  echo "$now" > "$REBOOT_STAMP"
  note "L3: rebooting — offline too long and lesser remedies failed"
  sync
  systemctl reboot
}

# --- ADD NEW RECIPES HERE ----------------------------------------------------
# Pattern: a detection function (cheap, read-only) plus a remedy, wired into
# the ladder below with its own threshold. Document the incident that earned
# the recipe in docs/triage and reference it here by date.

# --- the ladder --------------------------------------------------------------

if internet_up; then
  prev=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
  [ "$prev" -ge "$L1_AT" ] && note "recovered: internet is back after $prev failed checks"
  echo 0 > "$COUNT_FILE"
  exit 0
fi

count=$(( $(cat "$COUNT_FILE" 2>/dev/null || echo 0) + 1 ))
echo "$count" > "$COUNT_FILE"
note "internet probe failed (consecutive: $count; wifi link: $(link_up && echo up || echo down))"

if [ "$count" -ge "$L3_FORCE_AT" ]; then
  remedy_reboot
elif [ "$count" -ge "$L3_AT" ] && ! link_up; then
  # Only reboot if a driver reload has had its chance and the link is still dead.
  if [ "$count" -gt "$L2_AT" ]; then
    remedy_reboot
  fi
elif [ "$count" -ge "$L2_AT" ]; then
  if ! link_up || [ "$count" -ge "$L2_FORCE_AT" ]; then
    remedy_driver_reload
  else
    note "holding at L1: link claims connected — likely an upstream/ISP outage"
    remedy_reconnect
  fi
elif [ "$count" -ge "$L1_AT" ]; then
  remedy_reconnect
fi

exit 0
