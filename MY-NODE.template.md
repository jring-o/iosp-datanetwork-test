# My node

Copy this file to `MY-NODE.md` and fill it in as you go. Your assistant reads it so it never
has to guess your username or address, and you will want it yourself in six months when you
have forgotten all of this.

`MY-NODE.md` is gitignored and must stay that way. It holds your node's address on your home
network and your node's password, on purpose: your assistant reads them so it can get a new
computer onto the node, and so can you in six months. Do not commit it and do not paste it
into an issue. The one thing that never goes in this file is the cluster secret, because it
belongs to the whole network, not to you.

## The basics

| | |
|---|---|
| Node name (hostname) | |
| Username | |
| Address on my home network | |
| How to re-find it if that changes | run `hostname -I` on the node, take the short item with dots; after a move, `node-reconnect` |
| Built on (date) | |

## Hardware

| | |
|---|---|
| Model | |
| Memory | |
| Drive model *(read from the machine, not the box; they disagree)* | |
| Drive size / free space at setup | |

## Software

| | |
|---|---|
| Operating system | |
| IPFS (Kubo) version | |
| IPFS Cluster version | |
| Storage budget set to *(not the 10GB default)* | |

## Identities

These are public. They are names, not secrets, and they never change. That is how the network
finds you after your address moves.

| | |
|---|---|
| IPFS peer ID | |
| Cluster peer ID | |

## Network membership

| | |
|---|---|
| Cluster name | |
| Joined on | |
| Bootstrapped from (which member) | |
| Am I an anchor? | no, or yes with ports forwarded: |

## Passwords

These live here so that a new computer, or a new session, can get onto the node without
anyone hunting. Say them to your assistant plainly when it asks; it records them here.

| | |
|---|---|
| My node's password | |
| My home Wi-Fi network name | |
| My home Wi-Fi password | |

## Where the cluster secret is kept

Write down *where*, never *what*. The secret is shared by every member, so it stays in your
password manager and is never written into this file or a chat window.

| | |
|---|---|
| The cluster secret | e.g. "password manager, entry name X" |

## Notes

Anything odd about this node: a quirk of your network, a workaround you needed, the name of
your Wi-Fi driver if you have ever had to reload it.
