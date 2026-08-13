---
name: laptop-setup
description: >-
  Turn a participant's own laptop into a member of the laptop cluster: install Kubo +
  IPFS Cluster, join, verify. Trigger on "set up my laptop node", "join the laptop
  cluster", "laptop-setup", or a workshop participant with a laptop and no Pi.
---

# laptop-setup — your laptop becomes a cluster node

> **Status: workshop-room only.** This skill was built for a facilitated workshop and still
> assumes a facilitator hands over the cluster details in person. The self-serve rewrite has
> not happened yet. If the person is alone with no facilitator, steer them to the Pi path
> (`node-setup`) or to the contact route in the README.

Everything runs on the participant's own machine — no SSH, no extra hardware. Performed
end-to-end on **Windows 11** (2026-07-30, ~4 minutes on good bandwidth). macOS and Linux
follow the same shape but their legs have **not been performed yet** — if you're on those,
expect to adapt paths and tell the facilitators what you hit.

## Phase A — preflight (agent)

1. Check nothing conflicts: `ipfs` not already on PATH, no `%USERPROFILE%\.ipfs` or
   `%USERPROFILE%\.ipfs-cluster` directories. If they exist, STOP and ask the human —
   never overwrite an existing IPFS identity.
2. Disk: ≥ 10 GB free is comfortable to start (the archive grows; you can check usage any
   time with `ipfs repo stat`).

## Phase B — install (agent)

From https://dist.ipfs.tech, download for your OS/architecture (Windows: `windows-amd64`
zips) into a self-contained folder, `%USERPROFILE%\iosp-laptop-node\bin\`:

- **kubo** — use the version your cluster's other nodes run (ask the facilitator; this
  guide was performed with v0.42.0)
- **ipfs-cluster-service** and **ipfs-cluster-ctl** — likewise (performed with v1.1.6)

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

1. Agent: `ipfs-cluster-service.exe init --consensus crdt`.
2. The facilitator gives the human three things **person-to-person**: the cluster's
   **name**, its **secret**, and this laptop's assigned **peername** (`laptop-NN`).
3. **The secret must never pass through the agent chat** — everything an agent sees is
   transcript forever. The human pastes it directly into
   `%USERPROFILE%\.ipfs-cluster\service.json` themselves (Notepad: the `"secret"` field
   under `"cluster"`), or hands the agent a facilitator-prepared file to place. The agent
   may set the non-secret fields: `cluster.peername`, `consensus.crdt.cluster_name`,
   `consensus.crdt.trusted_peers` (as the facilitator specifies).
4. Agent: write the meeting-point line the facilitator provides (format
   `/ip4/<ip>/tcp/<port>/p2p/<cluster-peer-id>`) into
   `%USERPROFILE%\.ipfs-cluster\peerstore` (one line, plain text file, no extension).

## Phase E — join + verify (agent)

1. Start the cluster peer: `ipfs-cluster-service.exe daemon` (hidden/minimized, as above).
2. Within ~15s, `ipfs-cluster-ctl.exe peers ls` shows this laptop's peername AND the other
   members, each "Sees N other peers".
3. **Expect a false alarm**: for the first minute, `ipfs-cluster-ctl.exe status` may show
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
