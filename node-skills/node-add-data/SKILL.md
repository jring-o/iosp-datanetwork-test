---
name: node-add-data
description: >-
  Add a rescued dataset to the consortium's shared pin list from the researcher's own
  node. Trigger on "add this dataset", "archive this", "pin this to the cluster",
  "node-add-data", or a researcher with rescued data in hand.
---

# node-add-data — archive a rescued dataset

Any member can do this from their own node (all-equal cluster; no permission step). The
result: the dataset gets a permanent content address (CID), lands on the shared pin list,
and every consortium node automatically downloads and keeps it.

## Before adding

1. **Ask what it is** — you'll need a descriptive name: discipline, source, date matters
   more than filename. Good: `"noaa-tide-gauges-boston-1921-2019"`. Bad: `"data_final2"`.
2. **Size sanity**: `du -sh` the dataset, `df -h /` on the node. The corpus policy is
   "everyone pins everything", so a dataset must comfortably fit the *smallest* node's free
   space. MB–GB: proceed. Tens of GB: pause and raise it first via the contact route in
   the README.
3. **Get it onto the node** if it's on their everyday computer:
   `scp -r <local-path> <username>@<address>:/tmp/` (username and address from `MY-NODE.md`;
   it's a staging copy, and the node imports it into its archive storage in the next step).

## Adding (on the node)

```
ipfs-cluster-ctl add -r --name "<descriptive-name>" /tmp/<dataset>
```

(`-r` for folders; drop it for a single file.) The output's last line is the dataset's
**CID** (`Qm…` / `bafy…`): its permanent, location-independent address. **Record it with
the name**; that pair is the archival record.

## Verify, then clean up

1. `ipfs-cluster-ctl status <cid>` → this node says `PINNED` (large datasets show `PINNING`
   while ingesting; wait, re-check).
2. Other nodes replicate automatically: their names appear alongside as `PINNED` over the
   following minutes or hours (visible whenever they're online).
3. Sovereignty copy (consortium convention): also reference it in the node's Files space,
   which survives shared-list removal AND garbage collection (a plain `ipfs pin add` does
   NOT; cluster unpins remove it; tested):
   `ipfs files mkdir -p /sovereign 2>/dev/null; ipfs files cp /ipfs/<cid> "/sovereign/<descriptive-name>"`
4. Now delete the staging copy: `rm -r /tmp/<dataset>`. The data lives in the node's
   archive storage (and everyone else's), not in /tmp.

## Tell the human what happened

One sentence, always: "*<name>* is archived as `<cid>`: your node holds it, the consortium
is replicating it, and that address will find it on any node, forever."
