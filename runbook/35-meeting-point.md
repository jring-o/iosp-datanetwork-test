# 35 — Anchor: making your node publicly dialable (volunteers only)

*(This file keeps its historical `35-meeting-point.md` name; the role was renamed
"anchor" on 2026-07-31.)*

Most nodes never need this chapter. Each cluster needs a few **anchors**: in IPFS terms,
*publicly dialable peers* that serve as the cluster's *bootstrap peers* and *relays*. Every
other node just dials out to them. If you volunteered for the role, this chapter opens your
node's doors; it takes ~15 minutes plus however your internet provider complicates it.

**You start with:** a running node (through `20-kubo.md`) on your home network, and access
to your internet provider's router settings (an account login or the router's admin
password).
**You end with:** two ports on your home router forwarding to your node, verified reachable
from the outside world.

## What volunteering publishes, in plain terms — read before opening anything

An anchor's permanent identities go into the public registry (`ops/meeting-points.json` in
this repository) so that newcomers can find the network. Understand what that means before
you agree to it:

- Anyone in the world can turn a published identity into your **current home IP address**
  with one free lookup on the public IPFS network. That is not a flaw; it is exactly how
  members find you, and it is what "publicly dialable" means.
- Your household is therefore publicly linkable to this project, for as long as you hold
  the role.
- Your two open ports can be knocked on by strangers. Port 4001 is the standard IPFS port
  that millions of nodes expose; port 9096 is inert to anyone without the cluster secret,
  and the software's own security guide documents it as safe to expose.

The role is reversible: remove the forwarding rules and ask for your entry to be removed
from the registry, and the exposure ends. Your identities enter the registry only after you
have read this and said yes, through the contact route in the README.

## A. Find out who controls your router

Your internet provider's equipment decides *how* (and whether) you can open a port. Your
agent can identify this for you in seconds:

1. Look up who owns your public address: `curl https://ipinfo.io/json`. The `org` line
   names your provider.
2. Read your router's login page title: `curl -s http://<gateway-ip>/ | grep -i title`
   (your gateway IP is the "Default Gateway" in your network settings, commonly
   `192.168.1.1` or `10.0.0.1`). The title usually names the router brand.

Then find your provider's port-forwarding instructions. Known cases (grow this list):

- **Comcast/Xfinity rented xFi gateway (US):** app-only; no laptop path. Install the
  "Xfinity" app → WiFi → View WiFi equipment → Advanced settings → Port forwarding.
  *(Performed 2026-07-30; the app auto-reserves your node's LAN address, a nice bonus.)*
- **Most customer-owned routers:** web admin at the gateway IP → look for "Port
  Forwarding" under Advanced/NAT/Firewall.

## B. Create two forwarding rules

Both point at your node's LAN address (e.g. `192.168.1.42`):

| Rule | Port | Protocol | What it opens |
|---|---|---|---|
| 1 | **9096** | **TCP** (only — the cluster layer can't use UDP) | cluster coordination: lets other members bootstrap through you |
| 2 | **4001** | **TCP/UDP** (both — UDP carries the fast QUIC transport) | data layer: lets any node pull data from you directly, first try |

If the form offers to "reserve" your node's LAN address, accept; it stops the address from
changing under the rules.

## C. Verify from the outside world

Your own network can't reliably test its own front door, so use an external checker. Via
API (your agent can run this):

```
curl -s -H "Accept: application/json" "https://check-host.net/check-tcp?host=<your-public-ip>:9096&max_nodes=3"
# note the request_id, wait ~10s, then:
curl -s -H "Accept: application/json" "https://check-host.net/check-result/<request_id>"
```

Success looks like checker nodes reporting your address with a connect time (e.g.
`{"address":"…","time":0.11}`); failure shows a connection error. Test both 9096 and 4001.
(Your public IP: the `ip` field from the ipinfo lookup in step A.)

## D. Register

Collect your node's two permanent IDs, Kubo (`ipfs id -f "<id>"`) and cluster
(`ipfs-cluster-ctl id | head -1`), and send them with your node's name through the contact
route in the README. Your entry goes into `ops/meeting-points.json` and reaches every node
from there. Registry distribution is currently manual. Update `MY-NODE.md`: you are an
anchor now, with both ports noted.

## How others find you when your IP changes (no action needed)

Home public IPs are **dynamic**; your provider can rotate yours. The consortium deliberately
uses no DNS and no domains (nothing that any single party owns or that can lapse). Instead,
your node is known by its **permanent cryptographic peer ID**, and other members find your
current address three independent ways: their cached copy of your last address, the cluster's
live gossip, and, for a cold node with stale caches, asking the public IPFS network where
your peer ID currently lives. That last path is why this chapter forwards port 4001: an
anchor's data port being publicly dialable is what makes it findable by the whole world
without any phone book. *(The resolver helper each node runs is part of the standard node
setup; see `30-cluster.md`.)*
