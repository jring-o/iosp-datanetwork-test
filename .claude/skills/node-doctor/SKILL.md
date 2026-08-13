---
name: node-doctor
description: >-
  Diagnose and repair a consortium node that has stopped connecting, reporting, or
  pinning — including a node that looks completely dead from the outside, and one that is
  perfectly reachable but not in the cluster or not holding data. Escalating ladder from
  remote checks to at-the-machine recovery; the agent does the work over SSH when possible
  and guides the human at the Pi's own screen when the network itself is broken. Trigger on
  "my node is offline / unreachable / disappeared", "my node isn't pinning", "node-doctor",
  "the dashboard says my node is gone", or when node-health's reachability check fails.
---

# node-doctor — when the node seems gone, or seems wrong

Companion to `node-health` (read-only checkup): health says *whether* something is wrong,
doctor finds *what* and fixes it. The node runs a watchdog that self-heals common failures
within ~30 minutes, so the first question is always **"how long has it been down?"** If
under 30 minutes: wait, then re-check. Doctor is for when the watchdog lost.

**Two different complaints arrive here.** Sort before you start:

- *"I can't reach my node"* → Phases A–C, network failures.
- *"My node is fine but it isn't pinning / isn't in the cluster / the dashboard shows it
  holding nothing"* → **skip straight to Phase D.** Nothing in the network ladder applies,
  and running it wastes the person's evening.

## Rule zero — inspect before you act

Never run a fixing command until you've run the looking command that names its target.
Module names, interface names, and profile names differ between units; read them off the
machine (`nmcli device status`, `nmcli connection show`, `lsmod`, `rfkill list`) and use
what you read. Guessed names waste attempts and scare the human.

**And capture evidence as you go.** The outputs you see during diagnosis are what you will
need if you get stuck and have to report the case (an issue, or the contact route in the
README). Photos of the screen are fine as evidence for you; never attach one to a report.

## Rule one — do not "fix" something that is repairing itself

Several normal states look exactly like failure, and the obvious remedy destroys the
evidence and teaches everyone the wrong lesson. Before acting, check the wait table in
Phase D. **Patience is a diagnostic step**, and you should say so out loud rather than
appearing to do nothing.

## How to talk to the human

This skill often runs while someone is standing at a Pi with a keyboard, worried. Follow the
interaction contract in `../README.md`: **one action per message, then explicitly what they
should see.** Never send a block of commands to a person at a screen. Name what is on the
screen exactly; never invent a label. And tell them at the outset that "that's not what I see"
is the most useful thing they can say.

## Phase A — from wherever you are (no home access needed)

1. **When did it die?** Ask the human when the node was last known good, and check the
   consortium's public dashboard if one is running (see the FAQ: "Can I watch the network
   live?"). Hard-refresh the dashboard before believing it; an open tab shows stale
   data. A node "down" less than 30 min may self-heal (watchdog); a node down for days
   won't come back without help.
2. **Is it a power/house event?** Ask whoever is home: are the node's lights on? Is the
   home internet working on other devices? A power cut needs nothing; the node rebuilds
   itself completely when power returns (proven by test). A dead home internet is not a
   node problem; the node catches up on its own when the internet returns.

If the node has power, the home internet works, and it's been dark >30 min → Phase B.

## Phase B — from a laptop on the same home network (SSH)

3. Find the node: try `ssh <username>@<its-usual-address>`. The username and last known
   address are in their node-facts file; don't assume either. If that fails, ping-sweep the
   subnet and check ARP for Raspberry Pi hardware prefixes (`2c-cf-67`, `d8-3a-dd`,
   `e4-5f-01`, `dc-a6-32`, `b8-27-eb`, `28-cd-c1`); DHCP may have moved it.
   **Warning:** appearing in ARP does NOT mean the node is alive. A Pi with a wedged
   Wi-Fi radio still shows up there while answering nothing. Confirm another device on
   the same network answers ping (rules out your VPN) before concluding anything.
   **Also check your own vantage point:** are you actually on the same network as the node?
   Pinging a home address from somewhere else fails for the least interesting reason there is.
   - **`Connection closed by <address> port 22`** right after the host-key prompt, with no
     password prompt, is not a fault: the node is mid-reboot and answers TCP before its login
     service is ready. Wait a minute, try again. Don't chase client versions.
4. If SSH works, this is not a network problem: run the node-health checkup, restart the
   failed service (`sudo systemctl restart ipfs` / `ipfs-cluster`), and if it doesn't hold,
   capture the journal and report. **If the services are all running and the complaint is
   about data or cluster membership, go to Phase D.**
5. If SSH fails everywhere while the node ARP-answers, the node's network stack is
   down. Phase C.

## Phase C — at the machine (monitor + keyboard; agent guides, human types)

Plug a screen into the Pi's micro-HDMI (either port; hot-plug usually works, try the
second port and tap a key if black) and a USB keyboard. The human logs in with their own
username and password (the username is in `MY-NODE.md`; they set the password at build
time). The human can photograph each screen for the agent. Then, in order, each step
deciding the next:

6. `hostname -I` — **empty output = the node holds no network address.** Continue.
7. `nmcli device status` — is the Wi-Fi device `connected`, `disconnected`, or
   `unavailable`? `nmcli connection show` — does the Wi-Fi profile (the home network's
   name) still exist?
8. Profile exists but inactive: `nmcli connection up "<profile name>"`.
   - "network could not be found" → step 9.
   - Profile GONE: `sudo nmcli device wifi connect "<network>" password "<wifi password>"`
     (the human types their own Wi-Fi password directly at the machine — never into chat).
9. `nmcli device wifi list` — **an empty scan in a residential area means the radio
   itself is dead**, not the router. Confirm nothing blocks it: `rfkill list` (all
   should say "no").
10. **The radio-wedge fix** (no reboot; the node's data services keep running). First
    read the driver's vendor-variant name: `lsmod | grep brcm` (it's `brcmfmac_cyw`,
    `_wcc`, or `_bca` depending on the unit). Then exactly:
    ```
    sudo systemctl stop NetworkManager wpa_supplicant
    sudo ip link set wlan0 down
    sudo modprobe -r brcmfmac_<variant> brcmfmac
    sudo modprobe brcmfmac_<variant>
    sudo modprobe brcmfmac
    sudo systemctl start NetworkManager
    ```
    Wait 15 seconds, rescan (step 9); networks should appear; reconnect (step 8).
11. **Last resort — reboot:** `sudo reboot`. Safe: every service returns by itself.
    If even a reboot doesn't restore Wi-Fi, the radio may have failed for good.
    A USB Ethernet adapter or a cable to the router is the workaround; report it.

## Phase D — the node is reachable but isn't in the cluster, or isn't holding data

Nothing here is a network fault. Work top to bottom; each check rules out a whole class.

### D1. How long has it been like this? (the wait table)

Acting too early is the most common mistake, and it hides the real behaviour.

| Symptom | Normal for | What's happening | Do |
|---|---|---|---|
| `UNPINNED`, or rows missing entirely, right after any restart | ~1 minute | The peer's view rebuilds before it reports truthfully | Wait, re-run `status` |
| One dataset stuck at `UNEXPECTEDLY_UNPINNED` while others are fine | **up to 12 minutes** from daemon start | The cluster's periodic repair pass hasn't come round yet | Wait. Only investigate after 15 min |
| A member showing nothing at all | as long as they're switched off | Absence is allowed; they catch up on return | Nothing |

**The test that separates "waiting" from "broken":** `ipfs cat <the dataset's identifier>`.
If content comes back while the pin is missing, transport is healthy and you are only waiting
for the repair pass; do not intervene. Running `recover` here "fixes" something that was
already fixing itself and teaches nobody anything.

### D2. Is it in the cluster at all?

```
ipfs-cluster-ctl peers ls
```

- **Other members listed, mutually seeing each other** → membership is fine, go to D3.
- **Only themselves** → they are not in the consortium's cluster. They are in a private
  cluster of one, which is what a wrong **secret** *or* a wrong **cluster name** produces.
  **These two failures are indistinguishable from inside**; do not guess which. Check both
  against `runbook/30`: `consensus.crdt.cluster_name` must read `iosp-nodes`, and the secret
  must be the one the consortium issued. Then `sudo systemctl restart ipfs-cluster`.
  If the secret needs replacing, it arrives out of band and **never through the chat**.

### D3. Can it actually reach another member?

A cluster peer that knows about others but can't dial them will sit alone.

- `cat ~/.ipfs-cluster/peerstore` — is there at least one address for another member?
- **If another member is on the same home network, that entry must be the LOCAL address.**
  Most home routers refuse to loop a connection out to their own public address and back, so
  two nodes in one house, or twenty in one room, cannot reach each other by public address.
  Test it directly: `timeout 8 bash -c "cat < /dev/null > /dev/tcp/<their-public-ip>/9096"`
  failing while the local address succeeds is the signature.
- **Being resolvable is not being reachable.** An anchor can be dialable from three
  continents and unreachable from the node beside it.
- Check the resolver ran: `systemctl status iosp-resolve-mp.service`. `lookup failed; keeping
  cached entries` is safe; it left existing addresses alone and will retry at next boot.

### D4. Is it storing anything?

- `ipfs config Datastore.StorageMax` — **if this reads `10GB`, that is the default, not a
  choice.** A node on a large drive will advertise 10GB and quietly stop taking the archive.
  Set it to ~80% of free space and restart IPFS.
- `df -h /` — a genuinely full disk produces pin failures that look like network faults.
- `ipfs-cluster-ctl status` with rows showing `PIN_ERROR` after the wait table's grace
  periods is a real failure: capture the error text verbatim and report it.

## Afterwards

- Verify from their everyday computer: SSH back in, run the node-health checkup, and, if the
  consortium runs a dashboard, confirm it shows the node again within a few minutes.
  **Hard-refresh the dashboard first**; a stale tab has convinced people a four-days-dead
  node was healthy.
- Report what you found and fixed, with the evidence (an issue, or the contact route in the
  README). Every diagnosed failure becomes a new automatic recipe in the watchdog, so the
  next person's node heals itself instead.
- **Offer to file it as an issue on the public repository**, consent-gated and anonymized per
  `../README.md`: no addresses, no network names, no photographs, and show them the exact text
  before they answer. A failure that dies in one chat window costs the next person the same
  evening.
