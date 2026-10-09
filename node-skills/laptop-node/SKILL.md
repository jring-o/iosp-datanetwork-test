---
name: laptop-node
description: >-
  Daily life with a laptop cluster node: start it after a reboot, check it's okay, stop
  it without worry. Trigger on "start my node", "is my node running", "get me back on the
  cluster", "laptop-node", "can I turn this off", or any post-reboot / post-sleep moment.
---

# laptop-node — start, check, stop

> **Status: workshop-room only.** Built for the facilitated workshop; the self-serve
> rewrite has not happened yet (see `../README.md`).

A laptop node has **no auto-start**: after every reboot or shutdown, someone (you or the
human) brings it back. The good news is proven, not hoped: **absences are safe** — a member
that was offline catches up automatically on rejoining. *(Tested 2026-07-30: a dataset was
added to the cluster while the laptop was fully off; within ~30 seconds of restarting, the
laptop had rejoined and pinned it, no commands beyond the start script.)*

## Start (after any reboot — double-click or agent)

Run `%USERPROFILE%\iosp-laptop-node\start-node.bat`:

```bat
@echo off
rem Start the laptop node: Kubo daemon + cluster peer. Double-click after any reboot.
rem Stop: close ipfs.exe and ipfs-cluster-service.exe in Task Manager, or just shut down.
rem The cluster forgives absences - your node catches up when you run this again.
start "ipfs" /min "%USERPROFILE%\iosp-laptop-node\bin\ipfs.exe" daemon
ping -n 9 127.0.0.1 >nul
start "ipfs-cluster" /min "%USERPROFILE%\iosp-laptop-node\bin\ipfs-cluster-service.exe" daemon
echo Both daemons launching (minimized). Check with check-node.bat
ping -n 4 127.0.0.1 >nul
```

Agents writing/repairing this file: **CRLF line endings, ASCII only** (LF-only bats
misparse — real failure), and `ping -n` waits, never `timeout` (fails under agent shells).

## Check ("is my node okay?")

Run `%USERPROFILE%\iosp-laptop-node\check-node.bat`, or the same by hand:

| Check | Command | Healthy looks like |
|---|---|---|
| Network | `ipfs.exe swarm peers` (count lines) | dozens to hundreds |
| Membership | `ipfs-cluster-ctl.exe peers ls` | own peername + others, "Sees N other peers" |
| Pins | `ipfs-cluster-ctl.exe status` | rows say `PINNED` |
| Datasets | the count below | the number of datasets in the archive, the X in the verdict |

Count datasets in PowerShell. This form names the program by its full path, so it works
whether or not the node's `bin` folder is on PATH:

```powershell
(& "$env:USERPROFILE\iosp-laptop-node\bin\ipfs-cluster-ctl.exe" pin ls | Select-String -NotMatch '^\S+ \| _iosp-').Count
```

Pins whose names start `_iosp-` are the archive's index files (`_iosp-index-<name>`, named
after the node of the member that runs the indexer) and the indexer's recipe
(`_iosp-recipe-v<N>`). They belong on the list and should read `PINNED` like everything
else, but they are never datasets, so the count leaves them out.

Datasets show up as RO-Crates. Usually within an hour of being added, the consortium's
indexer wraps each dataset in an RO-Crate (a folder holding the original data, its
description and a readable page) and lists it under the same name with a new CID; its pin
carries the metadata `iosp-kind=crate` (`ipfs-cluster-ctl.exe --enc=json pin ls <cid>`). The
recipe can name datasets that are never wrapped. While a swap completes, a dataset and its
crate can both appear under one name, so the count can briefly run high. It settles by
itself once every member that is online and holds the dataset also holds the crate.
*(Written 2026-10-08, ahead of its first performance.)*

Verdicts, in plain words:

- **HEALTHY** — all four in range: "Node's up, N connections, holding all X datasets." X is
  the dataset count, never the number of status rows.
- **RECOVERING** — just started: peers still climbing, or `status` shows `UNPINNED` /
  missing rows for this node. **Normal for the first minute after every start** — the
  membership view rebuilds before it reports truthfully. Wait a minute, re-check.
  *(Observed after every restart; always self-repaired within ~1 minute.)*
- **NEEDS ATTENTION** — sustained 0 network peers, "Sees 0 other peers" beyond a couple
  of minutes, or `PIN_ERROR`: capture the exact output verbatim, then check the obvious
  (internet up? on an unusual network → the laptop-reconnect skill when it exists), then
  report it with the captured output — an issue on the repository, or the contact route in
  the README.

## Stop

Nothing careful is required — this is the one machine in your life you may simply close:

- Shutting down / closing the lid stops the node with it. Fine.
- To stop just the node: Task Manager → end `ipfs.exe` and `ipfs-cluster-service.exe`.
  *(The catch-up test above used exactly this hard stop; nothing was lost or corrupted.)*

While your node is off, the cluster's other members keep serving everything — including
whatever you added. Your copy resumes on the next start.
