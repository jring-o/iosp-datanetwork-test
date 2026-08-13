# My node

Copy this file to `MY-NODE.md` and fill it in as you go. Your assistant reads it so it never
has to guess your username or address, and you will want it yourself in six months when you
have forgotten all of this.

`MY-NODE.md` is gitignored and must stay that way. It holds your node's address on your home
network. Do not commit it, do not paste it into an issue, do not put it in a chat window you
did not open. Your password and the cluster secret never go in this file, nowhere in it, not
even abbreviated.

## The basics

| | |
|---|---|
| Node name (hostname) | |
| Username | |
| Address on my home network | |
| How to re-find it if that changes | run `hostname -I` on the node, take the short item with dots |
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

## Where the things I must not lose are kept

Write down *where*, never *what*.

| | |
|---|---|
| My node's password | e.g. "on paper in the desk drawer" |
| The cluster secret | e.g. "password manager, entry name X" |

## Notes

Anything odd about this node: a quirk of your network, a workaround you needed, the name of
your Wi-Fi driver if you have ever had to reload it.
