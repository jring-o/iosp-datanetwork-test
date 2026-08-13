# 40 — Add a dataset, and prove another node has it

**You start with:** your node a member of the cluster (from `30-cluster.md`), holding whatever
the consortium already had.
**You end with:** a dataset of your own on the shared list, replicated to the other members,
and retrievable from a machine that is not yours.
**Time:** minutes for small datasets; transfer time dominates for large ones. *(Measured on
node-01, 2026-08-12: a small text file was pinned on the second node **25 seconds** after
being added on the first.)*

Any member can do this from their own node. There is no permission step, no approval queue,
and no central node to ask.

## Before you add

1. **Name it properly.** The name is the archival record, and it outlives you. Discipline,
   source, and period matter more than the filename:
   good — `noaa-tide-gauges-boston-1921-2019`; bad — `data_final2`.
2. **Check the size against the smallest node, not yours.** The corpus policy is that everyone
   pins everything, so a dataset has to fit comfortably on the *least* spacious member.
   `du -sh <dataset>` for its size, `df -h /` for your headroom. Megabytes to a few gigabytes:
   go ahead. Tens of gigabytes: raise it first through the contact route in the README,
   because that is a policy conversation rather than a technical one.
3. **Get it onto the node** if it's sitting on your everyday computer:

   ```
   scp -r <local-path> <username>@<address>:/tmp/
   ```

   This is a staging copy. The node imports it into its own archive storage in the next step.

## Add it

On the node:

```
ipfs-cluster-ctl add -r --name "<descriptive-name>" /tmp/<dataset>
```

Use `-r` for a folder; drop it for a single file.

**You should see:** a line reading `added <identifier> <filename>`. That identifier (starting
`Qm…` or `bafy…`) is the dataset's **permanent address**. It is derived from the content
itself, so it will find this data on any node, anywhere, forever, and it doubles as a checksum:
if the bytes change, the address changes.

**Record the name and the identifier together.** That pair is the archival record.

## Prove it landed

1. On your own node:

   ```
   ipfs-cluster-ctl status <identifier>
   ```

   **You should see** your node listed as `PINNED`. Large datasets show `PINNING` while they
   ingest; wait and re-check.

2. **Then watch it appear elsewhere.** Other members pin it automatically as they see it. On
   the node-01 test, the second node reported `PINNED` **25 seconds** after the add. Members
   who are switched off pick it up when they next start.

3. **The real proof: fetch it back from a machine that is not the one you added it on.**

   ```
   ipfs cat <identifier>          # a file
   ipfs get <identifier>          # a folder
   ```

   If another member's node hands you your data back, the archive is real. This was performed
   node-01 → node-00 on 2026-08-12.

## Keep your own copy safe from the shared list

Consortium convention, and worth understanding: a cluster pin belongs to the *shared* list, so
if the dataset is ever removed from that list, your node drops its copy too. If you want your
node to hold it regardless of what the consortium decides later, also place a reference in the
node's own Files space:

```
ipfs files mkdir -p /sovereign
ipfs files cp /ipfs/<identifier> "/sovereign/<descriptive-name>"
```

A plain `ipfs pin add` does **not** achieve this; a cluster unpin removes it anyway. This was
tested and the naive approach falsified (2026-07-30).

## Clean up the staging copy

```
rm -r /tmp/<dataset>
```

The data now lives in your node's archive storage, and on every other member's node. It is
not in `/tmp` any more, and deleting the staging copy does not remove it from the archive.
