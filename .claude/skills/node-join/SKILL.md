---
name: node-join
description: >-
  Join an existing Raspberry Pi node to the consortium's private cluster, so it shares the
  pin list, pulls down the whole archive, and can contribute rescues of its own — runbook
  chapter 30, including the cluster secret's out-of-band handling and the address resolver.
  Trigger on "join the cluster", "node-join", "my node runs IPFS but isn't in the network",
  "connect my node to the consortium", or a node that was set up before the cluster step
  existed.
---

# node-join — put an existing node into the consortium

For a node that already runs IPFS but belongs to no cluster. Most people never need this
separately: `node-setup` runs the join as its Phase G. Use this when the node was built
earlier, when the join failed and is being retried, or when someone is rebuilding cluster
membership after a reinstall.

The prose reference is `runbook/30-cluster.md`. This skill adds the division of labour, the
secret hygiene, and the two failure modes that account for nearly everything that goes wrong.

## Before you start

**The person needs the cluster secret, and it is not in any repository.** It is a
64-character string, it is the *only* credential the network has, and anyone holding it can
join. If they don't have it, stop; have them request it through the contact route in the
README's "Joining the network" section. Do not improvise, do not generate one, do not
proceed "to test the rest".

Confirm first: IPFS is installed and running (`systemctl is-active ipfs`), and you have
key-based SSH. Read their username, node name and address from the node-facts file rather
than assuming any of them.

## Secret hygiene — the rule that has no exceptions

- **The secret never appears in the chat.** Not quoted back, not echoed, not in a command you
  print, not in a file you write into their repository clone.
- **Never put it in a shell command**, which lands in shell history and process listings.
- **Use the shipped helper, `ops/set_secret.sh`.** It reads the secret from standard input,
  validates it, writes `service.json`, and never echoes it. Copy it to `~/ops/` on the node
  first (`mkdir -p ~/ops`, then `scp`). Then:
  - **If you can reach another node that holds it, pipe it** machine to machine:
    `ssh <other> "python3 -c \"import json;
    print(json.load(open('/home/<other-username>/.ipfs-cluster/service.json'))['cluster']['secret'])\""
    | ssh <username>@<address> 'bash ~/ops/set_secret.sh'`. That is how node-01 and node-02
    were joined.
  - **If the human has it on paper or in a password manager,** they run
    `ssh -t <username>@<address> 'bash ~/ops/set_secret.sh'` in their own terminal and paste
    it at the invisible prompt. This is one of the few moments where they, not you, do the
    typing. (`nano ~/.ipfs-cluster/service.json` works too; the helper just checks the paste.)
- A secret that has been in a chat window is compromised for the whole consortium, not just
  their node. Say so if they offer to paste it to you.

## How to talk to the human

Interaction contract in `../README.md`: one action per message, then what they should see.
Tell them up front what joining means in plain words (their node is about to start
downloading everything the consortium has rescued, and to start offering its own copies to
everyone else) and roughly how long you'll be working while they wait.

## Steps (you, over SSH)

1. **Install the cluster software.** `ipfs-cluster-service` and `ipfs-cluster-ctl` from
   dist.ipfs.tech, arm64, current stable (v1.1.6 at time of writing; check for newer, and
   don't try to match other members' versions; mixed versions are normal and fine).
2. **`ipfs-cluster-service init --consensus crdt`.** Expect `service.json`, `identity.json`
   and an empty `peerstore` under `~/.ipfs-cluster/`.
3. **Change exactly two values.** A fresh init already has the rest right: `peername`
   defaults to the hostname, `trusted_peers` to `["*"]`, and `enable_relay_hop` to `true`
   (leave it on; it does nothing behind an ordinary home connection and starts working by
   itself if they ever volunteer as an anchor).
   - `consensus.crdt.cluster_name` → `iosp-nodes`
   - `cluster.secret` → the secret, handled as above
4. **Install the address resolver** (`resolve_meeting_points.py` + `meeting-points.json`
   from the repo's `ops/`, plus its boot-ordered unit, `After=ipfs.service`,
   `Before=ipfs-cluster.service`; runbook 30 step 4 has the commands). Run it once: it reads
   the anchors' permanent IDs from the registry, finds their current addresses on the public
   IPFS network, and writes the peerstore, so no address needs to be known in advance. It is
   also what lets the node re-find the consortium after any address changes later.
5. **Same-network case:** if a member lives on this same home network, append their LOCAL
   address to the peerstore by hand
   (`/ip4/<local address>/tcp/9096/p2p/<their cluster peer ID>`); see the note below.
6. **Install and enable the cluster service** (`User=<their username>`,
   `IPFS_CLUSTER_PATH=/home/<their username>/.ipfs-cluster`, `After=ipfs.service`).
7. **Gate 1 — membership.** `ipfs-cluster-ctl peers ls` must list them **and at least one
   other member**, each reporting they see the other. Confirm from the other side too if you
   can reach it.
8. **Gate 2 — the archive arrives.** `ipfs-cluster-ctl status`: their rows turn `PINNED` as
   content transfers. See the waiting table below before reacting to anything.
9. **Gate 3 — it survives a reboot.** `sudo reboot`; the node must rejoin by itself. On
   node-01 this took about a minute. Don't skip this: the join isn't real until it's
   automatic.
10. **Record in the node-facts file:** cluster peer ID, which cluster, the date joined, and
    which anchor they bootstrapped from.

## The two failures that account for nearly everything

**They see only themselves in `peers ls`.** They are in a private cluster of one. This is
produced by a wrong secret *or* a wrong cluster name, and **the two are indistinguishable
from inside**: a peer with either one wrong simply forms its own separate cluster and
reports itself perfectly healthy. Check both; don't guess. Then restart the cluster service.

**They're a member but nothing pins.** Usually not a failure at all; see the waiting table.
If it persists past 15 minutes, the node can't actually dial the other member. On a shared
home network, suspect the public-vs-local address problem below. Otherwise hand off to
`node-doctor` Phase D.

## What to expect while waiting (and not act on)

| What you see | Normal for | Why |
|---|---|---|
| `UNPINNED` or missing rows just after the daemon starts | ~1 minute | The peer's view rebuilds before it reports truthfully |
| One dataset at `UNEXPECTEDLY_UNPINNED` while others pin fine | **up to 12 minutes** | The cluster's repair pass runs on an interval and hasn't come round |
| Members absent from rows | while they're switched off | Absence is designed for |

Both of the first two look exactly like data loss. **The test that tells waiting from broken
is `ipfs cat <cid>`**: if the content comes back, transport is fine and the pin is simply
queued. Do not re-add, do not restart, do not run `recover`; you'd be "fixing" something that
was about to fix itself.

## Same-network members — the trap

If another consortium node is on the same home network, or you are joining nodes in a room
full of them, **they must reach each other by local address, not the public one.** Most home
and venue routers refuse to loop a connection from inside out to their own public address and
back. The resolver preserves local addresses for exactly this reason; don't tidy them away.

Quick test: `timeout 8 bash -c "cat < /dev/null > /dev/tcp/<public-ip>/9096"` failing while
the local address succeeds is the signature.

## When they're in

Say it plainly: their node now holds the consortium's archive, keeps pulling new material by
itself, and offers its copies to everyone else, with nothing running on their computer and
nothing for them to remember. Then offer `node-add-data`, so they contribute something of
their own while you're still there.

**Offer to report anything that surprised you** as an issue on the public repository,
consent-gated and anonymized per `../README.md`. Join-time confusion is the most valuable
feedback the guide can get, because everyone hits it exactly once.
