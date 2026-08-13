# 25 — Network watchdog (self-healing connectivity)

**You start with:** a headless node running IPFS (from `20-kubo.md`), reachable by key-based
SSH from your everyday computer.
**You end with:** a watchdog on the node that checks real internet reachability every 2
minutes and repairs the connection itself when it breaks.
**Time:** ~2 minutes.

Every node gets this. A Pi in someone's home has nobody to notice it fell off the Wi-Fi. On
the first node we built, the on-board radio froze and the node sat healthy-but-offline for
four days until a human drove a monitor to it. The watchdog notices instead, and climbs a
ladder of increasingly firm fixes. It re-joins the Wi-Fi after ~10 minutes offline, reloads
the Wi-Fi driver after ~16 minutes (the fix that cured the real incident), and reboots after
~30 minutes, never more than once per 6 hours, so an ISP outage can't cause a reboot loop.
While the internet is fine it does nothing, silently, every 2 minutes.

*Proven on node-00 2026-08-06, including a live drill: we forced the Wi-Fi off and watched
the watchdog bring the node back unattended.*

## Install (agent does this; ~2 min)

From your clone's `ops/` directory, copy the three files to the node and enable the timer.
The script lives at `/usr/local/bin/` so nothing depends on your username:

```
scp ops/net_watchdog.sh ops/iosp-net-watchdog.service ops/iosp-net-watchdog.timer <username>@<address>:/tmp/
ssh <username>@<address> 'sudo install -m 755 /tmp/net_watchdog.sh /usr/local/bin/ && sudo mv /tmp/iosp-net-watchdog.service /tmp/iosp-net-watchdog.timer /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now iosp-net-watchdog.timer'
```

## Verify

```
ssh <username>@<address> 'systemctl list-timers iosp-net-watchdog.timer --no-pager && sudo systemctl start iosp-net-watchdog.service && systemctl show -p Result iosp-net-watchdog.service && cat /run/iosp-net-watchdog/fail_count'
```

Expect the timer listed with a NEXT time no more than 2 minutes out, `Result=success`, and `0`.

## Reading it later

- `journalctl -t iosp-net-watchdog` — empty or quiet means healthy. It logs every failed
  probe, every remedy it tries, and a `recovered:` line when the internet returns.
- Escalation thresholds and the recipe ladder are constants at the top of
  `/usr/local/bin/net_watchdog.sh`; new failure modes get added at the marked
  "ADD NEW RECIPES HERE" section as they are diagnosed.

→ Continue to `30-cluster.md`.
