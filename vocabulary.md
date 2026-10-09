# Vocabulary — the consortium in plain words

One entry per term, plain language first, the community's technical word in parentheses
where it differs.

## The machine

- **Node** — your machine running the archive software — a Raspberry Pi (take-home cohort)
  or your own laptop (laptop cohort); one member of a network. Also *you*, in a sense:
  researchers and their machines are jointly the consortium.
- **Raspberry Pi (Pi 5)** — the small, silent computer the node runs on. Plugs into power
  and Wi-Fi; no screen needed after setup day.
- **SSD / NVMe drive** — the fast storage inside your node where the archive lives.
- **Headless** — running with no monitor or keyboard attached. Your node is headless after
  first boot; you control it from your laptop.
- **Hostname** — your node's short name on your home network (e.g. `node-07`).
- **Address (IP address)** — the number your home network uses to reach your node: four short
  numbers with dots, like `192.168.1.42`. You read it off the Pi during setup and write it down.
  Longer ones full of colons are a different kind this guide doesn't use.
- **IPFS (Kubo)** — the first of the two programs your node runs. It stores the data and
  hands it out to whoever asks. "Kubo" is the name of the particular version of IPFS we use.
- **IPFS Cluster** — the second program your node runs. It is what makes a pile of separate
  nodes into a group: it keeps the shared list of what should be stored, tells your IPFS to
  fetch things other members added, and announces your node to the others every fifteen
  seconds so the group knows you're there. Both programs are existing open-source projects;
  the consortium didn't write either of them.
- **SSH** — the secure remote-control channel your laptop (and your agent) uses to operate
  the node. Think: a command line to the Pi, from the couch.
- **SSH key** — a cryptographic ID card stored on your everyday computer that logs you into
  your node without typing passwords. Set up once during your node's build.
- **Watchdog** — a small program on your node that checks every two minutes whether the
  node can reach the internet, and if it can't for a while, fixes it itself — first gently
  (rejoining the Wi-Fi), then firmly (restarting the Wi-Fi hardware), then, as a last
  resort, rebooting. It's why a hiccup at 1 AM doesn't need you.

## The data

- **IPFS** — the protocol our network speaks: files are found by *what they are*, not
  *where they are*, so any copy anywhere can serve them.
- **Kubo** — the actual IPFS program running on every node.
- **Content address (CID)** — a fingerprint of a dataset (looks like `QmZHJC…`). If you have
  the fingerprint, any node holding the data can prove it's the real thing and serve it.
- **Pin / pinning** — a node's promise to keep a copy of something and never auto-delete it.
  Unpinned data is treated as disposable cache.
- **Shared pin list** — the consortium's collective "we are keeping these" list. Every
  member's node watches it and pins what's on it.
- **Replication (factor)** — the policy for *how many* nodes pin each item. Ours today:
  "everyone pins everything." Tomorrow, per dataset, it can be "at least 5 copies."
- **Sovereignty copy** — a consortium convention: when you add a dataset, your node *also*
  keeps a reference to it in its private Files space, outside the shared list's control —
  so no change to the shared list can ever remove your data from your own machine. Your
  node, your copy, period. *(Tested for real: survives removal from the shared list and
  cleanup.)*
- **Adoption** — the consortium convention that anything rescued into either network gets
  pinned into both, so the archive never splits. A human act at the workshop (the adoption
  ceremony), a habit afterward.
- **Sharding** — the future mode where big collections are spread across some nodes rather
  than all — same machinery, different replication number.
- **RO-Crate (crate)** — a dataset packaged with its description, as a folder holding the
  original data, a standard metadata file (`ro-crate-metadata.json`) and a page any browser
  can show (`ro-crate-preview.html`). RO-Crate is an open standard from the research
  community. The indexer turns every dataset the recipe does not exclude into one, under
  the dataset's own name; the crate has a new address, and the original address keeps
  working because the crate contains the same data.
- **Indexer** — a program that runs on some anchors, and on other members' nodes whose owners
  agree to it. It reads the datasets on the shared pin list, has the recipe's AI model
  describe each one, wraps it as an RO-Crate, and lists the crate in an index file.
- **Recipe** — the consortium's one set of instructions for the indexer, wherever it runs. It
  names the AI model that describes the data and what the model is told, and the datasets
  that are never wrapped. It is pinned into the network as `_iosp-recipe-v<N>`. A new version
  is a consortium decision, and when one appears the indexer remakes every crate under it.
- **Index file** — the list of crates the indexer made on one member's node, with each
  crate's title, keywords, research field and address, pinned into each of that member's
  networks as `_iosp-index-<name>`, named after that member's node. Every member holds the
  index files pinned in its own network, so it can search them without the website. Pins
  whose names start `_iosp-` are index files and recipes, never datasets.

## The network

- **NAT / home router** — your home internet's front door: your node can always dial *out*
  through it, but nothing outside can dial *in* uninvited. Our whole design assumes this.
- **Publicly dialable** — the opposite condition: a node whose door answers from the
  internet, because its owner set up port forwarding.
- **Anchor** — our name for a publicly dialable member node. Same thing, two words:
  "publicly dialable" is what it *is*, "anchor" is what it's *for* — the fixed spots where
  the rest of its network connects. Held by volunteers; each network keeps its own set.
  Anchors also run the regular spot-checks that confirm members still hold and serve the
  archive. (Earlier drafts said "meeting point"; some project files still use the old name.)
- **Port forwarding** — the one router setting an anchor volunteer makes: "knocks on
  door 9096 go to my node."
- **Bootstrap peer** — the community's term for the known member a node dials first when
  joining. Our anchors are the cluster's bootstrap peers.
- **Relay** — a member that passes traffic along for members who can't connect directly.
  Anchors do this too.
- **Peer ID** — a node's permanent cryptographic name (looks like `12D3KooW…`). Derived from
  keys, owned by nobody, registered nowhere, never changes even when addresses do.
- **DHT ("the public address book")** — the global, ownerless directory run collectively by
  millions of public IPFS nodes: look up a peer ID or a content fingerprint, get current
  locations. Our deep backstop for finding anchors that moved.
- **Hole punching** — how two home nodes open a direct line to each other despite both being
  behind NAT, using the public commons as matchmaker. Works ~70% of the time per pair; when
  it fails, data flows via another copy instead.
- **Gossip** — the cluster's continuous background chatter: members share current addresses,
  heartbeats, and pin-list updates with whoever they're connected to, and word spreads.
- **Heartbeat (ping metric)** — the periodic "I'm alive, here's my free space" every member
  broadcasts. Recorded on node-00; the source of the retention count.
- **Spot-check (probe)** — an automatic test where one member is asked to hand over a real
  piece of a dataset, proving it *serves* the data rather than merely claiming to hold it.
  A node is never asked to vouch for itself. Runs every half hour; verdicts appear on the
  dashboard as "✓ served".

## The consortium

- **Cluster** — the coordination layer tying a group of nodes into one archive with one
  shared pin list. We run two: `iosp-nodes` (the Pis) and `iosp-laptops` (the laptops),
  each with its own membership secret; everything rescued in either is adopted into both.
- **Resilient Network #1 / #2** — the participant-facing names for the two clusters:
  #1 is the take-home Pis, #2 is members' laptops. Practically identical software; the
  hardware difference is the experiment.
- **Observer (recorder)** — node-00's role inside the laptop cluster: a member that exists
  to *listen* — it takes the attendance record and serves as the always-on anchor —
  and is never counted as one of the laptops' copies in the study or on the dashboard.
- **Storage budget** — how much disk a node offers the archive (a setting, not the drive
  size — the software's default is a small 10GB until deliberately raised). What the
  dashboard's "free" number means.
- **Cluster secret** — the membership card: a shared code that encrypts all coordination
  traffic. Holding it = being a member (and being able to pin). Kept in password managers,
  never published, never in any repo.
- **All-equal / trusted cluster** — our trust model: every member's node has the same rights
  (any member can pin). No privileged machines, no followers.
- **Governance** — the human rules (what gets pinned, who volunteers as anchors, who
  holds what). Written by the consortium at the workshop, evolvable without touching the
  technology.
- **Dashboard (iosp.science/datanetwork)** — the public live health readout: every node's
  *heartbeats* as strips of green, both clusters side by side. A window onto the network,
  never a part of it — if the dashboard vanished, no node would notice.
