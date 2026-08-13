---
name: node-meeting-point
description: >-
  Volunteer flow: make this researcher's node a consortium meeting point (publicly dialable
  peer — bootstrap + relay for the cluster). Agent identifies the ISP and router, guides the
  two port forwards, verifies from outside, and registers the new meeting point. Trigger on
  "become a meeting point", "node-meeting-point", "volunteer my node", "open the port".
---

# node-meeting-point — volunteering a publicly dialable node

Reference: runbook chapter 35 (the role's current name is "anchor"; this skill keeps the
older filename). Only volunteers do this (target: ~5 across the consortium). The commitment:
one router setup, a node that stays plugged in, and your node's two permanent IDs entering
the public registry.

**Informed consent comes first.** Before touching the router, read the person runbook 35's
"What volunteering publishes" section, or say the same in your own words: their node's IDs
go into the public registry, anyone can turn those IDs into their current home IP with one
public lookup, and their household becomes publicly linkable to the project for as long as
they hold the role. The role is reversible. Proceed only after they've heard that and said
yes.

## A. Discover what you're dealing with (you, ~1 minute)

1. ISP: `curl -s https://ipinfo.io/json`. The `org` field names the provider; note the
   `ip` (needed for verification later).
2. Router: `curl -s http://<gateway-ip>/ | grep -io "<title>[^<]*</title>"` usually names
   the brand. (Gateway IP = "Default Gateway" in the laptop's network settings.)
3. Match against known ISP paths and tell the human what they're in for:
   - **Comcast/Xfinity rented xFi gateway (US):** app-only. Install the "Xfinity" app →
     WiFi → View WiFi equipment → Advanced settings → Port forwarding. The web admin page
     will NOT offer it; don't send the human hunting there. (Bonus: the app auto-reserves
     the node's LAN address.)
   - **Customer-owned router:** web admin at the gateway IP → Port Forwarding under
     Advanced/NAT/Firewall. Accept any "reserve this IP" offer.
   - **CGNAT / provider refuses:** some ISPs give no real public address, so the human
     simply can't volunteer; thank them, the consortium needs regular nodes too.

## B. The two rules (human, in router UI or app)

Both point at the node's LAN address:

| Port | Protocol | Opens |
|---|---|---|
| **9096** | **TCP only** (the cluster layer cannot use UDP) | cluster coordination — bootstrap/relay |
| **4001** | **TCP/UDP** (UDP carries QUIC) | data layer — direct fetch + public-DHT findability |

## C. Verify from the outside world (you)

```
curl -s -H "Accept: application/json" "https://check-host.net/check-tcp?host=<public-ip>:9096&max_nodes=3"
# note request_id, wait ~10s:
curl -s -H "Accept: application/json" "https://check-host.net/check-result/<request_id>"
```

Repeat for 4001. Success = checker nodes report the address with a connect time. Then the
deep check, whether the node is findable by identity alone (may take a while after 4001
opens):

```
curl -s -H "Accept: application/json" "https://delegated-ipfs.dev/routing/v1/peers/<kubo-peer-id>"
```

Expect the node's current public address among the answers.

## D. Configure the relay role + register (you + the consortium)

1. On the node, set `enable_relay_hop: true` in `~/.ipfs-cluster/service.json` (cluster
   section; edit via a python3 JSON round-trip, not sed), then
   `sudo systemctl restart ipfs-cluster`.
2. Collect the node's two permanent IDs: Kubo (`ipfs id -f "<id>"`) and cluster
   (`ipfs-cluster-ctl id | head -1`).
3. **Send both IDs + the node name through the contact route in the README** so the anchor
   registry (`ops/meeting-points.json`) gains the entry and reaches all nodes. Registry
   distribution is currently manual. Update `MY-NODE.md`: anchor = yes, ports noted.

Done: the node is one of the fixed points the whole floating cluster ties to.
