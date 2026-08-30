---
name: node-setup
description: >-
  Walk a researcher and their agent through standing up a consortium node on a Raspberry
  Pi 5, from sealed box to a node that is joined to the cluster and holding the archive:
  unbox, first boot, remote access, IPFS (Kubo), self-healing watchdog, and the cluster
  join (runbook chapters 00-40), with the agent doing all machine-side work once SSH is up.
  Trigger on "set up my node", "node-setup", "my Pi arrived", or a researcher starting
  their node build.
---

# node-setup — from sealed box to a node holding the archive

You are assisting a researcher (often non-technical) building their consortium node. The
prose reference is the runbook (chapters `00-hardware`, `10-first-boot`, `20-kubo`,
`25-watchdog`, `30-cluster`, `40-data`). Follow its steps; this skill adds the division of
labor, the verification gates, and the friction learned from real builds. Rhythm: **the human
does the physical world and the first-boot wizard; you do everything after SSH exists.**

**Done means joined, not installed.** A node running IPFS but belonging to no cluster is not
finished; it holds nothing and nobody can reach it. Do not declare the build complete until
the person's node appears in `peers ls` alongside other members and their pins are landing.

## Who you might be helping

Two different people arrive at this skill, and the difference matters:

- **A workshop participant**, whose node was set up in the room with facilitators present.
  They will rarely run this; what they run at home is reconnection and diagnosis. If one does
  run it, their node name and cluster secret were assigned to them.
- **Someone building their own node later**, alone, with nobody to ask. **Write and behave
  for this person.** They choose their own username; nothing may assume otherwise. Never say
  "ask a facilitator" or "this was done for you at the workshop". Anything they must request
  (the cluster secret above all) goes through the contact route in the README's "Joining the
  network" section.

## How to talk to the human (the interaction contract; non-negotiable)

**One action per message, then a blank line, then what they should see.**

```
<one instruction>

You should see: <what appears>
```

**Your first message teaches them the protocol, before any instruction.** Tell them: reply
**`Done`** when they've finished a step; reply **`That's not what I see`** (with a description
or a photo) whenever the screen doesn't match what you said to expect, stressing that this is
useful and never their fault; and they can **ask anything at any time**, mid-step included,
and you'll be with them for the whole build. Then give step one.

**At the handover (when the monitor is unplugged and you start running commands), tell them
what is happening.** One plain sentence on what you're doing, roughly how long it will take,
and that they have nothing to do until you say so. Then report in plain language at each
milestone rather than going silent behind a wall of terminal output. A bare "this part's mine"
tells someone nothing, and watching an agent do unexplained things to hardware they just
bought is where people panic.

Wait for their confirmation before the next action. Never send a numbered list of clicks;
they are looking at a screen, not reading a document. Name every on-screen label exactly as
written, in bold, and **never invent one**: ask what the screen says rather than guess. State
the expectation even when nothing visibly changes, or a working step will look broken to them.
If what they report differs from what you told them to expect, **the document is wrong**; fix
it before continuing. Full rationale in `../README.md`.

## Ground rules (learned the hard way)

- **You cannot type passwords.** Your shell has no interactive keyboard: password SSH
  prompts fail with `Host key verification failed` / `stdin is not a terminal`. Key-based
  access is your entry ticket. Set it up early; never work around it.
- **The human's password never enters the chat.** Interactive logins and the one-time key
  install happen in the human's own terminal window, not through you. Never echo secrets,
  never store them in any file you write.
- **Sequence the human's dignity:** have them do the plain `ssh` password login FIRST (the
  "I'm on my own node" moment), THEN the key install. Don't lead with plumbing.
- **Errors get captured verbatim** — photo or copy-paste before anyone clicks past. Future
  diagnosis searches by exact symptom.
- **Verify against the device, not the product page** (e.g. drive model from
  `cat /sys/class/nvme/nvme0/model`); listings and reality diverge.
- On Windows, prefer a POSIX shell for remote ssh commands (PowerShell mangles nested
  quoting), and deliver scripts by writing a local file + `scp`, never by heredoc.

## Phase A — hardware + first boot (human's hands, your eyes)

1. Confirm the human has **four** things: the kit, a monitor/TV with HDMI, a USB keyboard,
   **and a USB mouse**. The wizard and Control Centre are point-and-click, so the mouse is
   required, not optional. Plus their Wi-Fi password. The screen is needed for this session
   only; say so, it reassures. Wired peripherals; Bluetooth can work, but if pairing fails
   they have no way to type, which is what they'd need to fix it.
2. **Start the node-facts file now:** copy `MY-NODE.template.md` to `MY-NODE.md` in their
   clone. Every fact this build produces (username, node name, address, identities) gets
   recorded there the moment it appears. It is how every other skill knows their setup
   without guessing, and their own record in six months. It is gitignored because it holds
   their home network address: never committed, never pasted into an issue, never shown to
   anyone.
3. Runbook 00: connect display (micro-HDMI port nearest the power socket), keyboard, mouse,
   power LAST (no power button; plugging in is on).
   **Warn them about the boot sequence before they plug in:** boot screen → loading → **black
   screen** → a second boot screen → **black again** → Welcome wizard. The Pi restarts itself
   once on first power-up. The black screens are where people pull the plug thinking it died.
4. Wizard (runbook 10 A). **The page order is:** Welcome → Set Country → Create User → Wi-Fi
   (two pages) → Choose Browser → Updates → Finish.
   - *Set Country* has two checkboxes the wizard doesn't explain. **"Use US keyboard" is the
     one that matters**: tick it only if their physical keyboard really is US, because a wrong
     layout means the password they set is not the password they typed, discovered much later.
     "Use English language" is cosmetic but worth ticking so the menus match the runbook.
   - *Create User:* whatever username they want (see "Who you might be helping"). Their
     password, written down on paper. **Record the username in `MY-NODE.md`**; everything
     downstream reads it, and nothing may assume a particular value.
   - *Wi-Fi* is **two pages, not one**. Page one lists the networks the Pi can see: pick the
     home network, **Next**. Page two asks for that network's password: type it, **Next**
     again. Tell them both steps up front, or "enter its password and click Next" sends them
     hunting for a password box that is not on the first page.
   - *Choose Browser:* either; tick "uninstall the unused browser". One less large package to
     patch over the node's multi-year life.
   - **Updates: expect the check to FAIL the first time.** It has failed on both units ever
     built, for two unrelated reasons: the Pi has no battery clock so signatures look invalid
     before time sync (wait 2 minutes first), **or** the preloaded image is older than the
     mirror and the incremental index refuses itself (nothing to wait for, and it gets
     more likely the longer the kit sat in a warehouse). **Cure for both: OK → Back → Next.**
     One retry normally clears it. Second failure: press **Skip**; the update is redone from
     their computer later. **Ask for a photo of the error before they dismiss it**, because
     the dialog truncates, won't scroll, and can't be copied.
   - *Finish:* the last page's button says **Launch**, not Finish. Then it reboots.
5. Runbook 10 B: Control Centre (NOT "Raspberry Pi Configuration"; older tutorials show
   the old tool).
   - **Hostname is four interactions, not one:** click the **Change hostname** button → popup
     → type the name → **OK** → a second popup confirming it applies at next reboot → **OK**.
     **The row still reads "Change hostname" afterwards**; Control Centre never displays the
     current hostname. Tell them that, or a working step looks broken. Record the node name
     in `MY-NODE.md`.
   - Interfaces → SSH → **ON**. Then **Close** (there is no OK/Apply) → reboot when asked.

## Phase B — find the node (you)

6. **Simplest reliable route: read it off the Pi**, while the monitor is still attached.
   Have them open the terminal (black monitor icon in the top taskbar) and run `hostname -I`.
   **Do not say "the first number".** The output holds two or three items: one short one with
   dots (`192.168.1.42`) and one or two long ones full of colons. Tell them you want **the
   short one with dots**, and that the long ones are a different kind of address this guide
   doesn't use. Record it in `MY-NODE.md`.
7. mDNS (`ping node-NN.local`) is an optional shortcut, not a step. **Expect failure if their
   computer runs a VPN**; that is very common, and it means nothing is wrong. If you need to
   find the node without their help: ping-sweep the LAN and match Raspberry Pi MAC prefixes
   in the ARP table (`2c-cf-67`, `d8-3a-dd`, `e4-5f-01`, `dc-a6-32`, `b8-27-eb`, `28-cd-c1`).
   **ARP presence is not liveness** (see `node-doctor`).
8. Confirm the door: test TCP port 22 on that address. Expect success; if not, SSH didn't
   get enabled, so back to Control Centre.

## Phase C — access (human once, then you forever)

Say "your everyday computer", never "your laptop": in this project a laptop can be a node in
its own right, and the machine they administer from may be a desktop. It matters which machine
they pick: the key lands on it.

9. Human, in their own terminal: `ssh <username>@<address>` → accept the host key (`yes`) →
   password → they land on `<username>@node-NN`. Celebrate this. `exit`.
   **Known transient:** `Connection closed by <address> port 22` immediately after accepting
   the host key, with no password prompt, means the Pi is still finishing its reboot; the
   network answers before the login service is ready. **Wait a minute and run it again.**
   Nothing is wrong. Don't start diagnosing versions or clients; it resolves itself.
10. Key install, still the human's terminal (their password's last-ever appearance):
    - Windows: `type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh <username>@<address> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"`
    - Mac/Linux: `ssh-copy-id <username>@<address>`
    - No key yet? `ssh-keygen -t ed25519` first, defaults fine.
    - If your own host-key recording is needed non-interactively:
      `ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes <username>@<address> exit`
      (note: `ssh-keyscan` can fail against newer server OpenSSH with a
      `choose_kex`/post-quantum KEX error; the accept-new probe is the reliable path).
11. Verify YOUR access: `ssh -o BatchMode=yes <username>@<address> hostname` must print the
    node name with no password prompt. If their key and yours are the same file on the same
    machine, this also satisfies their verification; say so rather than making them repeat it.
    From here the monitor, keyboard and mouse retire; you operate.

## Phase D — complete the node-facts file (you)

12. Capture from the device, not from any product page: OS (`head -2 /etc/os-release`),
    kernel (`uname -srm`), drive (`cat /sys/class/nvme/nvme0/model`), free space (`df -h /`),
    and confirm passwordless sudo with a harmless `sudo true`.
13. **Write these into `MY-NODE.md`** alongside what Phases A–B already recorded, and keep it
    current as later phases produce more (peer IDs, cluster membership, storage budget).

## Phase E — Kubo (you, runbook 20 exactly)

14. Latest stable: `curl -s https://dist.ipfs.tech/kubo/versions | grep -v "\-rc" | tail -1`.
    **Take the newest, even if it differs from other nodes.** Members build months apart;
    mixed versions are the cluster's normal state, not a problem to reconcile.
15. Download `kubo_<version>_linux-arm64.tar.gz` from dist.ipfs.tech, extract,
    `sudo bash kubo/install.sh`, confirm `ipfs --version`.
16. `ipfs init` → **record the peer identity** (`12D3KooW…`, the node's permanent public
    name; safe to share, never changes) in `MY-NODE.md`. Then set the archive budget:
    **Kubo defaults to 10GB regardless of drive size**, so a 512GB node would advertise 10GB
    and quietly stop accepting the archive. `ipfs config Datastore.StorageMax 400GB`
    (~80% of the drive's free space; scale to their drive). Record the budget too.
17. Install the systemd unit from runbook 20 (`User=<username>`, `Restart=on-failure`),
    enable, start.
18. Gate 1: `systemctl is-active ipfs` → `active`; `ipfs swarm peers | wc -l` → dozens to
    hundreds within a minute.
19. Gate 2: `sudo reboot`, wait ~90 s, reconnect, repeat gate 1. The node must come back
    connected with zero human action.

## Phase F — the watchdog (you, runbook 25; every node, no exceptions)

20. Copy `net_watchdog.sh` and its two unit files per runbook 25: the script installs to
    `/usr/local/bin/`, the units to `/etc/systemd/system/`, then enable the timer. (`scp`
    to `/tmp/` first; the runbook's two commands do the rest.)
21. Verify: timer listed with a NEXT time ≤2 min out, a manual run reporting `Result=success`,
    and a fail count of `0`.

Tell the human plainly what this is, because it is the part that protects them: it checks
every two minutes whether the node can really reach the internet (never whether the system
*claims* to be connected), and if it can't, it fixes itself, escalating from rejoining the
Wi-Fi to reloading the radio driver to a rate-limited reboot. It exists because a dry-run
node's radio froze while the OS reported "connected" for 44 hours, and it sat dark for four
days.

## Phase G — join the cluster (you, runbook 30); the build is not done until this passes

22. **The cluster secret comes to the person directly, outside this repository.** If they
    don't have it, stop and have them request it through the contact route in the README's
    "Joining the network" section; you cannot proceed and must not improvise around it.
    **Never let the secret into the chat**, an issue, or a shell command that gets logged.
    If you are copying it from another node you have access to, pipe it directly into a script
    that reads standard input, so it is never rendered anywhere.
23. Install `ipfs-cluster-service` + `ipfs-cluster-ctl` (v1.1.6 at time of writing; check
    dist.ipfs.tech for newer), then `ipfs-cluster-service init --consensus crdt`.
24. **A fresh init is already almost right**: `peername` defaults to the hostname,
    `trusted_peers` to `["*"]`, `enable_relay_hop` to `true` (leave it on; harmless behind
    NAT, useful if they ever become an anchor). **Only two values need changing:**
    `consensus.crdt.cluster_name` → `iosp-nodes`, and `cluster.secret` → the secret.
25. Install the anchor resolver per runbook 30 step 4 (`resolve_meeting_points.py` +
    `meeting-points.json` to `~/ops/`, run it once, then its boot-ordered unit). The registry
    ships in the repo; the resolver turns its permanent IDs into current addresses and writes
    the peerstore, so no address needs to be known in advance. Then the cluster's own systemd
    unit. **If another member is on their own network, add its LOCAL address to the peerstore
    by hand**: most home routers refuse to loop a connection out to their own public address
    and back, so between neighbours the local address is the only one that works.
26. Gate 3: `ipfs-cluster-ctl peers ls` shows them **and at least one other member**, both
    reporting they see each other. If they see only themselves, the secret or the cluster name
    is wrong, **and those two failures look identical**, because either one silently forms a
    private cluster of one. Re-check both; don't guess which.
27. Gate 4: `ipfs-cluster-ctl status` shows their rows turning `PINNED` as the archive
    arrives. **Expect noise and do not act on it.** A freshly started peer reports `UNPINNED`
    or missing rows for a minute; separately, a single dataset can sit at
    `UNEXPECTEDLY_UNPINNED` for up to **12 minutes** before the cluster's own repair pass
    fixes it. Both look exactly like data loss and are exactly not. If you want to check
    while waiting, run `ipfs cat <cid>`; if content comes back, transport is fine and you
    are only waiting. Only after 15 minutes is it worth investigating.
28. Record in `MY-NODE.md`: cluster name, cluster peer ID, join date, which anchor they
    bootstrapped from.

**Now the build is done.** Tell them in plain language: their node holds the consortium's
archive, it will keep pulling new material by itself, it fixes its own network, and it needs
nothing from them, including after a power cut.

## Phase H — hand over (you)

29. Offer to walk them through adding a dataset of their own (`node-add-data`, runbook 40).
    It is the thing the network is for, and doing it once while you're there is worth more
    than reading about it later.
30. Tell them what to run later, so the answer isn't "nothing, good luck": `node-health` for a
    checkup, `node-doctor` if something seems wrong (including after a move or network change,
    until a dedicated `node-reconnect` skill exists), `node-add-data` whenever they rescue
    something.
31. **Offer to report anything that surprised you both** as an issue on the public repository,
    consent-gated and anonymized, per `../README.md`. Anything the runbook got wrong or didn't
    mention is exactly what the next person needs.

## What this skill does NOT cover

Volunteering as an anchor (`node-meeting-point`, runbook 35 — opt-in, needs router access) and
diagnosing a node that has stopped working (`node-doctor`). Point at those rather than
improvising.
