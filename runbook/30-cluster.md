# 30 — Join the consortium cluster

**You start with:** a headless node running IPFS, reachable from your everyday computer by
SSH with a key (from `20-kubo.md`), and the network watchdog installed (`25-watchdog.md`).
**You end with:** your node a full member of the consortium's private cluster: sharing one
pin list with every other member, pulling down everything the consortium has rescued, and
contributing everything you rescue.
**Time:** ~8 minutes of work. *(Measured on node-01, 2026-08-12, the first join this cluster
ever had. Add waiting time for the datasets themselves to arrive, which depends on how much
the consortium is holding.)*

**You need one thing that is not in this repository: the cluster secret.** It is a 64-character
string, and it is the only credential that exists: anyone holding it can join, and nobody
without it can. It is never published, never committed, and never pasted into a chat window.
If you don't have it, stop here and ask for it through the contact route in the README's
"Joining the network" section. A person answers; the secret comes to you directly, outside
this repository.

## What you are joining

Every member runs the same software as an equal. There is no server, no head office, and no
account. The cluster keeps one shared list of what should be stored, every member pins
everything on that list, and any member can add to it. Membership is proved by the secret
alone.

That means your node needs exactly two things to join: the secret, and a way to reach one
member who is already in. The second one is solved for you. The repository carries the
permanent identities of the consortium's **anchors** (members who keep a door open precisely
so newcomers have something to dial), and a small helper you install below turns those
identities into current addresses.

## Steps

Everything below runs on the node, inside an SSH session or wrapped as
`ssh <username>@<address> '<command>'` by you or your agent. Your username and address are in
`MY-NODE.md`.

### 1. Install the cluster software

Two programs: the service that runs constantly, and the control tool you type commands into.

```
cd /tmp
for t in ipfs-cluster-service ipfs-cluster-ctl; do
  wget -q https://github.com/ipfs-cluster/ipfs-cluster/releases/download/v1.1.6/${t}_v1.1.6_linux-arm64.tar.gz
  tar xzf ${t}_v1.1.6_linux-arm64.tar.gz
  sudo mv $t/$t /usr/local/bin/
done
ipfs-cluster-service --version
ipfs-cluster-ctl --version
```

Expect both to print `version 1.1.6`. *(Check
`https://github.com/ipfs-cluster/ipfs-cluster/releases` for a newer stable release and
substitute it; v1.1.6 was still current on 2026-10-06. Until that day these files came from
dist.ipfs.tech, which stopped answering.)*

### 2. Create the node's cluster identity

```
ipfs-cluster-service init --consensus crdt
```

Expect three files reported: `service.json`, `identity.json`, and an empty `peerstore`, all
under `~/.ipfs-cluster/`.

**A fresh install is already almost correct.** It sets your peer name to your node's hostname
and already trusts all members, which is what our design wants. Exactly **two** things need
changing, in step 3.

*(Curious what those defaults are? `peername` = your hostname, `trusted_peers` = `["*"]`,
`enable_relay_hop` = `true`. Leave relay-hop on even though it does nothing on an ordinary
home connection: it costs nothing, and it starts working by itself if your node ever becomes
publicly reachable, see `35-meeting-point.md`.)*

### 3. Set the cluster name and the secret

The two values that make this node part of *our* cluster rather than a private one of its own:

| Setting | Where it lives in `~/.ipfs-cluster/service.json` | Value |
|---|---|---|
| Cluster name | `consensus` → `crdt` → `cluster_name` | `iosp-nodes` |
| Secret | `cluster` → `secret` | the 64-character string you were given |

Set the cluster name with any text editor (`nano ~/.ipfs-cluster/service.json`): find
`cluster_name` and make it `iosp-nodes`. You can set the secret the same way, but the helper
below is safer and checks your paste.

**The secret, with the shipped helper.** `ops/set_secret.sh` reads the secret from standard
input, checks that it is 64 hexadecimal characters, writes it into `service.json`, and locks
that file to your user. It never echoes the secret and never puts it in a command line. Copy
it to the node and run it from your computer:

```
ssh <username>@<address> 'mkdir -p ~/ops'
scp ops/set_secret.sh <username>@<address>:/home/<username>/ops/
ssh -t <username>@<address> 'bash ~/ops/set_secret.sh'
```

It asks you to paste the secret; nothing appears as you type. Press Enter.

**You should see:** `Secret set (64 characters). Cluster name is: iosp-nodes`. Any other
message means the paste was wrong and nothing was changed; run it again.

**Do not paste the secret into a chat window, an issue, or a terminal command that gets
logged.** If an agent is helping you, it uses the same helper: you type the secret at the
invisible prompt in your own terminal, or the agent pipes it into the helper from a node that
already holds it. Either way it never appears as text the agent can see. That is how node-01
and node-02 were joined.

### 4. Install the address resolver — this is how your node finds the consortium

The consortium's anchors are listed in this repository at `ops/meeting-points.json`, by their
**permanent identities** rather than by any address or domain name; home addresses change,
identities never do. The resolver reads that registry, asks the public IPFS network where
each identity currently lives, and writes the answers into your node's peerstore, before the
cluster starts, on every boot. It is what lets your node find the consortium on day one, and
still find it after your router hands out a different address, after an anchor's provider
rotates theirs, or after you move house.

Copy the two files from your clone to the node, then run the resolver once:

```
scp ops/resolve_meeting_points.py ops/meeting-points.json <username>@<address>:/home/<username>/ops/
ssh <username>@<address> 'python3 ~/ops/resolve_meeting_points.py'
```

**You should see** a line per anchor, like `node-00: resolved -> 203.0.113.9`, then
`peerstore written: N entries`. If it says `lookup failed; keeping cached entries`, that is
safe (your existing entries are untouched and it will try again next boot), but on a first
join there are no cached entries yet, so wait a minute and run it again before continuing.
**At a workshop with a room line (step 5), carry on instead:** the room line is enough to
join, and the lookup will succeed by itself once the node is somewhere with open internet.

Then install it as a boot-ordered service, so it runs before the cluster every time.
**Replace `<username>` in both places:**

```
sudo tee /etc/systemd/system/iosp-resolve-mp.service > /dev/null <<'EOF'
[Unit]
Description=Resolve anchor addresses
After=ipfs.service
Before=ipfs-cluster.service

[Service]
Type=oneshot
User=<username>
ExecStart=/usr/bin/python3 /home/<username>/ops/resolve_meeting_points.py

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable iosp-resolve-mp.service
```

### 5. If another consortium node is on your own network, or you are at a workshop

A second node in your house, or a room full of them at a workshop, is a special case: most
home routers will not let you reach your own public address from inside the network, so
between neighbours the **local** address is the only route that works. Add the neighbour's
local address to the peerstore by hand, one line:

```
echo "/ip4/<neighbour's local address>/tcp/9096/p2p/<neighbour's cluster peer ID>" >> ~/.ipfs-cluster/peerstore
```

The resolver preserves local addresses for exactly this reason; don't delete them by hand.
(The same line, with a public address, also works as a manual bootstrap if a member ever
hands you their address directly; the resolver is the normal path, not the only one.)

**At a workshop, this is how every node joins.** Whoever runs the workshop gives you a
**room line**: one line in the form above, pointing at a node in the room that is already a
member. Add it exactly as above, before you start the cluster in step 6:

```
echo "<the room line>" >> ~/.ipfs-cluster/peerstore
```

Your node then joins through the room's own Wi-Fi. It gets the shared list and the archive
from the nodes around it, so it needs nothing from the venue's internet, and nobody in the
room depends on reaching an anchor. Whatever the room adds reaches the rest of the network as
soon as any node in the room can reach it, at the latest when the nodes go home. Leave the
line in place afterwards; at home it simply fails and the anchors take over. *(Written
2026-10-06, ahead of its first performance.)*

**If you run the workshop: making the room line.** Do this once, before anyone else joins.
1. Join one node in the room the normal way, through an anchor. If the venue's internet
   blocks the cluster ports, give the room's router another internet for these few minutes,
   such as a phone.
2. In the room's router, give that node a fixed address (most routers call this *address
   reservation*), so the room line stays true all session.
3. Wait until `ipfs-cluster-ctl peers ls` on it lists an anchor and `ipfs-cluster-ctl status`
   shows its rows `PINNED`. It now holds the shared list and the archive.
4. Print its room line on it:

   ```
   echo "/ip4/$(hostname -I | cut -d' ' -f1)/tcp/9096/p2p/$(ipfs-cluster-ctl id | head -1 | cut -d' ' -f1)"
   ```

   and show it to the room (a slide or the workshop page). It holds an address inside the
   room and a peer ID, nothing secret. The router can then go back to the venue's internet.

The laptop network works the same way, with a laptop as the room's first node and the line
made in PowerShell. That laptop must accept connections from the others: set the room's
Wi-Fi to **Private** in Windows' network settings, and allow `ipfs.exe` and
`ipfs-cluster-service.exe` on private networks under **Allow an app through firewall**.

### 6. Run the cluster as a service

So the cluster peer starts itself on every boot, after IPFS is up.
**Replace `<username>` in both places:**

```
sudo tee /etc/systemd/system/ipfs-cluster.service > /dev/null <<'EOF'
[Unit]
Description=IPFS Cluster service (iosp-nodes)
After=ipfs.service network-online.target
Wants=ipfs.service network-online.target

[Service]
User=<username>
Environment=IPFS_CLUSTER_PATH=/home/<username>/.ipfs-cluster
ExecStart=/usr/local/bin/ipfs-cluster-service daemon
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now ipfs-cluster
```

Expect a `Created symlink …` line. Give it 20 seconds, then `systemctl is-active ipfs-cluster`
should print `active`.

### 7. Confirm you are in

```
ipfs-cluster-ctl peers ls
```

**Expect one line per member**, including yourself, each ending `Sees N other peers`. On
node-01's join this read:

```
12D3KooW…UocF7 | node-01 | Sees 1 other peers
12D3KooW…12NtMN | node-00 | Sees 1 other peers
```

If you only see yourself, the secret or the cluster name is wrong. Those two failures look
identical from here, because a peer with either one wrong simply forms a different cluster of
one. Re-check both, then restart with `sudo systemctl restart ipfs-cluster`. At a workshop,
also check that the room line went in before the cluster started; if it went in after,
restart the cluster.

**Check that your name is yours alone.** If another line shows the same name as yours, choose
another and rename. Names are only labels, since membership goes by peer ID, so this is
harmless. *(Written 2026-10-05, ahead of its first performance.)* With your new name in place
of `<new-name>`:

```
sudo raspi-config nonint do_hostname <new-name>
python3 -c 'import json,os; p=os.path.expanduser("~/.ipfs-cluster/service.json"); d=json.load(open(p)); d["cluster"]["peername"]="<new-name>"; json.dump(d,open(p,"w"),indent=2)'
sudo systemctl restart ipfs-cluster
```

The first line renames the machine, which takes full effect at the next reboot; the second
renames it within the cluster. Run `ipfs-cluster-ctl peers ls` again after 20 seconds and
expect your new name. Update `MY-NODE.md`.

### 8. Watch the archive arrive

```
ipfs-cluster-ctl status
```

You will see every dataset the consortium holds, with a line per member.

**Expect a mess for the first minute or two, and do not act on it.** A peer that has just
started reports `UNPINNED`, or omits rows, or shows `UNEXPECTEDLY_UNPINNED`, for pins that are
perfectly fine. It looks exactly like data loss and is not. Wait and re-run.

**Then expect your own rows to turn `PINNED`, one dataset at a time**, as the content
transfers. How long depends on how much there is and how fast your connection is.

**One dataset may lag well behind the others (up to about twelve minutes) and that is
normal.** On node-01's join, three of the four datasets pinned within 90 seconds and the
fourth sat at `UNEXPECTEDLY_UNPINNED` for ten minutes before fixing itself. The cluster runs
a repair pass every 12 minutes that compares what it believes it should be storing against
what is really on disk, and pins whatever is missing. That is the system working.

**Do not intervene before fifteen minutes**, and resist the urge to re-add the dataset or
restart anything. If you want to confirm nothing is actually broken while you wait, run
`ipfs cat <the dataset's identifier>` (identifiers are the long `Qm…`/`bafy…` strings in the
status output). If it prints content, transport is fine and you are only waiting on the
repair pass.

After fifteen minutes the repair pass has had its chance and something is genuinely wrong:
open an issue on this repository, or write to the contact route in the README.

## Record it, then what you have now

Add to `MY-NODE.md`: the cluster name (`iosp-nodes`), today's date as the join date, your
cluster peer ID (`ipfs-cluster-ctl id | head -1`, the leading `12D3KooW…` string), and which
anchor you bootstrapped from.

Your node holds a copy of everything the consortium has rescued, and will keep pulling new
material as members add it. Nothing needs to be running on your computer; the node does this
by itself, including after a power cut.

→ Next: `40-data.md` — adding a rescued dataset of your own.
