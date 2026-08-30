# Resilient Data Consortium — build a node, join the network

A small computer in your home, holding copies of data that would otherwise disappear.

Public datasets vanish, usually without an announcement. A grant ends, a server is retired,
an agency reorganises, and a dataset someone's work depends on is gone. This guide is for
researchers who want a copy to exist somewhere no single decision can reach.

You set up a node. It joins a network of other researchers' nodes. Every node holds a copy of
everything the group has rescued, and any member can add more. There is no server, no company,
and no account. If half the nodes disappear, the data is still on the other half.

You do not need to be technical. The guide is written to be followed by a person, and there
are agent skills that do most of it for you if you have an AI assistant. It takes about an
hour and a half, once, and then the node looks after itself.

Two kinds of node exist: a dedicated Raspberry Pi (this guide's main path, complete and
tested end to end) and your own laptop (a parallel network; its self-serve guide is still
being built). If you are here on your own, build the Pi.

## Start here

**With an AI coding assistant** (Claude Code, Codex, Gemini CLI, Cursor, or similar). Clone
this repository, open it with your assistant, and say "set up my node". In Claude Code you can
type `/node-setup`. The assistant reads `node-skills/` and walks you through it one step at a
time, doing the technical work itself once your node is reachable.

**With any AI chat window.** Open [`runbook/00-hardware.md`](runbook/00-hardware.md) and paste
it in, then ask for help following it. The assistant cannot touch your node, but it can read
the steps to you, explain what you are looking at, and interpret whatever appears on screen.

**On your own.** Start at [`runbook/00-hardware.md`](runbook/00-hardware.md) and work through
the numbered chapters. That is what everything else here is built on.

## What you'll need

- **A Raspberry Pi 5 (8GB) with a real SSD, arriving assembled with Raspberry Pi OS
  preinstalled.** The full requirements, and why each one matters, open
  [`runbook/00-hardware.md`](runbook/00-hardware.md); the kit this guide was performed on is
  named there as the reference
- A monitor or TV with HDMI, a USB keyboard, and a USB mouse, borrowed for the setup session;
  afterwards the node runs with none of them attached
- Your Wi-Fi password
- Somewhere at home to leave a small silent box plugged in
- The cluster secret — see "Joining the network" below

## Joining the network

The network's only credential is the **cluster secret**, and it is deliberately not in this
repository. To get it, write to **contact@scios.tech**: say who you are and that you want to
join a node to the consortium. A person answers and the secret reaches you directly. The same
address is the route for anything the repository tells you to "raise with the consortium":
volunteering as an anchor, proposing a very large dataset, or asking a question an issue
doesn't fit.

You can build everything except the final join (runbook chapters 00 through 25) before you
have the secret; only chapter 30 needs it.

## What's here

| | |
|---|---|
| [`runbook/`](runbook/) | The build guide. Numbered chapters, in order, from sealed box to a node holding the archive |
| [`node-skills/`](node-skills/) | Agent skills for setup, health checks, diagnosis, adding data, and joining. The `laptop-*` skills are for the parallel laptop network and are not yet self-serve |
| [`ops/`](ops/) | The two small programs every node runs: a watchdog that repairs your network connection by itself, and a resolver that finds the other members after addresses change. Also the anchor registry, `meeting-points.json` |
| [`vocabulary.md`](vocabulary.md) | The consortium in plain words |
| [`faq.md`](faq.md) | Frequently asked questions |
| [`MY-NODE.template.md`](MY-NODE.template.md) | The node-facts file you fill in during setup; your assistant reads it so it never guesses |

## How the network is put together

Every member is equal. There is no coordinator and no privileged node. Membership is proved by
holding a shared secret, and any member can add to the shared list of what gets stored.

There is no cloud anywhere in the design, and no domain names, because both put a single
owner between the network and its survival. Nodes find each other by permanent cryptographic
identities rather than by address.

Some members volunteer as **anchors**, opening one port on their router so newcomers have
something to dial. It is optional, and it is the one role with a public footprint;
[`runbook/35-meeting-point.md`](runbook/35-meeting-point.md) explains exactly what it commits
you to before you decide.

## Your node after setup

It needs nothing from you. It pulls down new material as the group rescues it, offers its
copies to anyone who asks, survives power cuts without help, and repairs its own network
connection when your Wi-Fi misbehaves. You do not need to leave anything running on your own
computer.

When you do want it: `node-health` for a checkup, `node-doctor` if something seems wrong,
`node-add-data` when you have something to rescue, and `node-reconnect` when the node moves
house, changes Wi-Fi, or arrives from someone else.

## Found something wrong?

Please open an issue; the template walks you through what to include. If you don't have a
GitHub account, send the same report to contact@scios.tech instead.

Please leave out your network addresses, your Wi-Fi name, and photographs of your screen. A
photo carries the whole screen. Typing out the message you saw is more useful and safer.

## Provenance

Built and tested at the [IOSP 2026](https://iosp.io) workshop in Leiden, funded by the IPFS
Implementations Fund. Every step here was performed on real hardware before it was written
down, and the measured timings come from those builds.

It runs on [Kubo](https://github.com/ipfs/kubo) and
[IPFS Cluster](https://github.com/ipfs-cluster/ipfs-cluster), both open-source projects we
depend on and neither of which we wrote.
