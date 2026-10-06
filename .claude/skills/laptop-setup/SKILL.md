---
name: laptop-setup
description: >-
  Turn a participant's own laptop into a member of the laptop cluster: install Kubo +
  IPFS Cluster, join, verify. Trigger on "set up my laptop node", "join the laptop
  cluster", "laptop-setup", or a workshop participant with a laptop and no Pi.
---

# laptop-setup — your laptop becomes a cluster node

> **Status: Windows only.** Performed end-to-end on **Windows 11** (2026-07-30, ~4 minutes
> on good bandwidth). On 2026-10-05 the facilitator hand-over was removed: the person now
> chooses the laptop's name, enters the secret at a hidden prompt (`ops/set_secret.ps1`), and
> you look up the meeting point yourself. On 2026-10-06 a workshop's laptops gained a room
> line, so they join through a laptop already in the room (Phase D step 5). Neither change
> has yet been performed on a laptop joining for the first time, so treat every mismatch as
> a defect to report. macOS
> and Linux have **not been performed at all**: if the person is on one of those, say so
> plainly and steer them to the Pi path (`node-setup`).

Everything runs on the participant's own machine, with no SSH and no extra hardware. The
one thing the person needs from outside is the laptop network's **cluster secret**. At a
workshop it comes from the workshop dashboard; on their own, they request it through the
contact route in the README's "Joining the network" section. Talk to the person by the
interaction contract in `../README.md`: one action per message, then what they should see.

## Phase A — preflight (agent)

1. Check nothing conflicts: `ipfs` not already on PATH, no `%USERPROFILE%\.ipfs` or
   `%USERPROFILE%\.ipfs-cluster` directories. If they exist, STOP and ask the human —
   never overwrite an existing IPFS identity.
2. Disk: ≥ 10 GB free is comfortable to start (the archive grows; you can check usage any
   time with `ipfs repo stat`).

## Phase B — install (agent)

From https://dist.ipfs.tech, download for your OS/architecture (Windows: `windows-amd64`
zips) into a self-contained folder, `%USERPROFILE%\iosp-laptop-node\bin\`:

- **kubo** v0.42.0
- **ipfs-cluster-service** and **ipfs-cluster-ctl** v1.1.6

These are the versions the network's other members run. Use them, not the newest release.

Verify all three: `ipfs.exe --version`, `ipfs-cluster-service.exe --version`,
`ipfs-cluster-ctl.exe --version`.

## Phase C — IPFS identity + daemon (agent)

1. `ipfs.exe init` → note the `peer identity: 12D3KooW…` line — the laptop's permanent
   public name on the IPFS network (an ID, not a secret). Kubo defaults to a **10GB
   archive budget** (`Datastore.StorageMax`) — a sensible laptop default; raise it only
   if the human wants to host more and has the disk to spare.
2. Start the daemon (`Start-Process -WindowStyle Hidden …\ipfs.exe daemon` or the
   start-node.bat from Phase F) and give it ~15 seconds.
3. Verify: `ipfs.exe swarm peers` shows dozens+ connections. *(Performed through an
   active NordVPN with no trouble and no firewall prompt — a member needs only outbound
   connections.)*

## Phase D — cluster membership (human + agent; the secret rule)

1. **The human chooses the laptop's name.** Every member sees it, and so does the network's
   public status page, so suggest a short name that doesn't identify them, such as
   `laptop-tulip`. Letters, digits and dashes, starting with a letter. Do not let it default:
   a fresh init names the peer after the computer, which is often the owner's name.
2. Agent: `ipfs-cluster-service.exe init --consensus crdt`, then set the two non-secret
   values in `%USERPROFILE%\.ipfs-cluster\service.json`: `cluster.peername` to their chosen
   name and `consensus.crdt.cluster_name` to `iosp-laptops`. A fresh init already sets
   `trusted_peers` to `["*"]`; leave it. Change only those two values, and save the file as
   UTF-8 **without** a byte-order mark (PowerShell 5.1's `Set-Content -Encoding UTF8` adds
   one, and the cluster program then refuses the file):

   ```powershell
   $cfg = "$env:USERPROFILE\.ipfs-cluster\service.json"
   $t = [IO.File]::ReadAllText($cfg)
   $t = $t -replace '("peername"\s*:\s*")[^"]*(")', ('${1}' + '<chosen-name>' + '${2}')
   $t = $t -replace '("cluster_name"\s*:\s*")[^"]*(")', ('${1}' + 'iosp-laptops' + '${2}')
   [IO.File]::WriteAllText($cfg, $t, (New-Object Text.UTF8Encoding($false)))
   ```

3. **The secret: the human's step, never the chat.** Everything an agent sees is transcript
   forever, so the secret must never pass through it. Ask them to open a **second**
   PowerShell window and run, with the kit folder's real path:

   ```powershell
   powershell -ExecutionPolicy Bypass -File "<kit folder>\ops\set_secret.ps1"
   ```

   You should see: a prompt asking them to paste the cluster secret. When they paste it, a
   `*` appears for each character instead of the secret. After Enter:
   `Secret set (64 characters). Cluster name is: iosp-laptops`. If the cluster name shown is
   anything else, step 2 did not take; redo it, then run the script again. A message that
   it does not look like a cluster secret means a partial copy; nothing changed, so they
   copy it again and rerun.
4. **The meeting point (agent).** The laptop network's anchor is the `iosp-laptops` entry in
   `ops/meeting-points.json`. With the Kubo daemon from Phase C running, look up its current
   address: `ipfs.exe routing findpeer <its kubo_id>`. From the output, take each public IPv4
   address (`/ip4/a.b.c.d/...`, skipping 10.x, 127.x, 169.254.x, 172.16-31.x and 192.168.x),
   and write one line per address into `%USERPROFILE%\.ipfs-cluster\peerstore` (plain text,
   no extension, ASCII):
   `/ip4/<address>/tcp/<its port>/p2p/<its cluster_id>`. This is what
   `ops/resolve_meeting_points.py` does on a Pi. If the lookup returns nothing, the fresh
   daemon is still finding its way into the network; wait a minute and retry. If the laptop
   sits on the same local network as the anchor itself, also write the private address the
   lookup returns, because most routers refuse to loop a connection out to their own public
   address and back in.
5. **At a workshop: the room line (human, then agent).** Ask:

   ```
   Are you at a workshop? If so, the workshop page or slide shows a room line for laptops,
   starting /ip4/. Copy it and paste it here.

   You should see: nothing changes on your screen; I'll add it to your laptop's node.
   ```

   It is not secret: an address inside the room and the peer ID of a laptop there that is
   already a member. Check its form: `/ip4/`, a private address (10.x, 172.16–31.x or
   192.168.x), `/tcp/`, a port, `/p2p/`, and a peer ID of 52 characters starting
   `12D3KooW`. Then add it as one more line in the peerstore file from step 4. If they
   aren't at a workshop, or there is no room line yet because theirs is the room's first
   laptop, carry on without one: it joins through the meeting point. With a room line, a failed lookup in step 4 is fine: carry
   on. The laptop joins through the room's Wi-Fi and needs nothing from the venue's
   internet. *(Written 2026-10-06, ahead of its first performance.)*

   Whoever runs the workshop makes the line on the room's first laptop, once it has joined
   and its `status` rows show `PINNED`, as runbook 30 step 5 describes:

   ```powershell
   $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Wi-Fi).IPAddress
   $id = ((ipfs-cluster-ctl.exe id) | Select-Object -First 1).Split(' ')[0]
   "/ip4/$ip/tcp/9096/p2p/$id"
   ```

   That first laptop must accept connections from the others: the room's Wi-Fi set to
   **Private**, and `ipfs.exe` and `ipfs-cluster-service.exe` allowed on private networks.

## Phase E — join + verify (agent)

1. Start the cluster peer: `ipfs-cluster-service.exe daemon` (hidden/minimized, as above).
2. Within ~15s, `ipfs-cluster-ctl.exe peers ls` shows this laptop's peername AND the other
   members, each "Sees N other peers". Seeing only itself means the secret or the cluster
   name is wrong; the two failures look identical, so re-check both. At a workshop, also
   check that the room line went in before the cluster peer started; if not, restart it.
3. **Check the name is theirs alone.** If another member in `peers ls` already uses the same
   name, ask the human for another, set it as in Phase D step 2, and restart the cluster
   peer. Names are only labels (membership goes by peer ID), so a rename after joining is
   harmless.
4. **Expect a false alarm**: for the first minute, `ipfs-cluster-ctl.exe status` may show
   `UNPINNED` for everything, on every peer. That is the fresh membership still syncing,
   not data loss — wait a minute, re-run, watch it turn `PINNED`. *(Observed on the first
   laptop join and again after restarts; always self-repaired.)*

## Phase F — the two helper scripts (agent)

Create `start-node.bat` and `check-node.bat` in `%USERPROFILE%\iosp-laptop-node\` so the
human can run the node by double-click forever after (contents in the `laptop-node` skill,
which is the daily companion to this one). Windows agents writing .bat files: **CRLF line
endings and ASCII only** (LF-only bats misparse), and use `ping -n <s+1> 127.0.0.1 >nul`
for waits — `timeout` refuses to run from an agent shell. *(Both defects hit for real,
2026-07-30.)*

## Tell the human what happened

"Your laptop is now a member: it holds a copy of everything the cluster archives, and
anything you rescue is replicated to every other member. After any reboot, double-click
start-node.bat to rejoin — the cluster catches you up on whatever you missed."

Then tell them the node's name once more, plainly. A workshop dashboard asks for it when they
claim their node.
