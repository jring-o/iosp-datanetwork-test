---
name: node-health
description: >-
  Read-only checkup of a consortium node: services, network connections, cluster state,
  disk, and a plain-language verdict. Trigger on "is my node okay", "check my node",
  "node-health", "is my Pi still working", or any worry about the node that doesn't name a
  specific error (specific errors → node-doctor).
---

# node-health — "is my node okay?"

Read-only: this skill NEVER changes anything. Run everything over SSH
(`ssh -o BatchMode=yes <username>@<address> '<command>'`, with username and address read
from the person's `MY-NODE.md`, never assumed). If you can't reach the node, that IS
the finding; see "Can't reach it" below.

## The checkup (one pass, ~30 seconds)

| Check | Command | Healthy looks like |
|---|---|---|
| Node reachable | `hostname && uptime -p` | answers; uptime as expected (short uptime = it rebooted — note when) |
| IPFS service | `systemctl is-active ipfs` | `active` |
| Cluster service | `systemctl is-active ipfs-cluster` | `active` |
| Network connections | `ipfs swarm peers \| wc -l` | dozens to hundreds (single digits within the first minute after boot is normal; sustained 0 = problem) |
| Cluster membership | `ipfs-cluster-ctl peers ls \| head -3` | its own name + "Sees N other peers" (N ≥ 1 once the consortium has other nodes online) |
| Pins | `ipfs-cluster-ctl status \| head -20` | entries say `PINNED` (`PINNING` = still downloading, fine; `PIN_ERROR` = report it) |
| Disk | `df -h /` | Use% comfortably under 80% |
| Meeting-point resolver (if installed) | `systemctl is-enabled iosp-resolve-mp 2>/dev/null` | `enabled` |

## The verdict (always give one, in plain words)

- **HEALTHY** — everything above in range: "Your node is up N days, holding all X datasets,
  talking to Y peers. Nothing to do."
- **RECOVERING** — just rebooted / peers still climbing / pins still downloading: "Give it
  ten minutes and I'll check again." Then actually re-check.
- **NEEDS ATTENTION** — a service inactive, sustained 0 peers, `PIN_ERROR`, or disk >80%:
  say which check failed, in one sentence, and capture the exact output verbatim before
  anything else. Restarting a failed service (`sudo systemctl restart ipfs` /
  `ipfs-cluster`) is the one safe intervention; if it doesn't hold, stop and report it with
  the captured output: an issue on the repository, or the contact route in the README.

## Can't reach the node at all

In order: (1) is it plugged in and its light on? (human checks); (2) how long has it been
unreachable? Under ~30 minutes, wait (the node's watchdog self-heals common failures),
then re-check; (3) the laptop may have moved networks or a VPN is interfering, so re-find
the node per the node-setup skill's Phase B (ARP + Raspberry Pi MAC prefixes, or
`hostname -I` on the Pi with a screen as last resort); (4) still unreachable → switch to
the **node-doctor** skill, which owns the full recovery ladder down to at-the-machine
repair.
