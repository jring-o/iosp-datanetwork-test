---
name: laptop-add-data
description: >-
  Add a rescued dataset to the laptop cluster's shared pin list from the laptop itself —
  the core act of the whole network. Trigger on "add this dataset", "archive this",
  "rescue this", "pin this to the cluster", "laptop-add-data", or a researcher with
  at-risk data in hand.
---

# laptop-add-data — archive a rescued dataset from your laptop

> **Status: workshop-room only.** Built for the facilitated workshop; the self-serve
> rewrite has not happened yet (see `../README.md`).

Any member can do this directly (all-equal cluster — no permission step). The result: the
dataset gets a permanent content address (CID), lands on the shared pin list, and every
member's node automatically downloads and keeps a copy. The data is already on the laptop,
so there is no staging/transfer step — this is the shortest path to archived in the whole
consortium. *(First performed laptop-side 2026-07-30: file added from a Windows member,
replicated and `PINNED` on the other member within seconds.)*

## Before adding

1. **Ask what it is** — you need a descriptive name: discipline, source, dates beat
   filenames. Good: `"noaa-tide-gauges-boston-1921-2019"`. Bad: `"data_final2"`.
2. **Size sanity**: the policy is "everyone pins everything", and laptop disks are the
   smallest in the cluster — a dataset must comfortably fit the *smallest* member's free
   space. MB–GB: proceed. Tens of GB: pause and confirm with the consortium first.
   Check your own side: dataset size vs `ipfs.exe repo stat` and free disk.

## Adding

```
ipfs-cluster-ctl.exe add -r --name "<descriptive-name>" "<path-to-dataset>"
```

(`-r` for folders; drop it for a single file.) The last output line is the dataset's
**CID** (`Qm…` / `bafy…`) — its permanent, location-independent address. **Record CID +
name together**; that pair is the archival record.

## Verify

1. `ipfs-cluster-ctl.exe status <cid>` → this laptop says `PINNED` (`PINNING` = still
   ingesting a large dataset — wait, re-check).
2. Other members' names appear alongside as `PINNED` over the following minutes (whenever
   they're online) — that's the replication happening.
3. The original files stay wherever they were — the archive copy lives inside the node's
   own storage (and everyone else's). Deleting the originals is the owner's call, not a
   required cleanup.

## Tell the human what happened

One sentence, always: "*<name>* is archived as `<cid>` — your node holds it, the other
members are replicating it, and that address will find it on any member, forever."
