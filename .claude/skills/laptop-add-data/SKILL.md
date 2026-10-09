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
2. **Ask where it came from**, in a message of its own once the name is settled. The person
   adding a dataset is the only reliable source for this, and for its license; the
   consortium's indexer copies both answers into the metadata it writes for the dataset and
   never asks a model to guess them. *(Written 2026-10-08, ahead of its first performance.)*

   ```
   Where did this data come from? A web address is best. If there isn't one, describe it
   in a few words, such as "copied from a retired lab file server in 2025". "I don't know"
   is a fine answer too.

   You should see: nothing changes yet. I'll store your answer with the dataset when I add it.
   ```

   Keep their answer to one short line; it becomes the `source-url` value below. If they
   don't know, or there is nothing to name, leave `source-url` out of the command.
3. **Then ask its license**, again in a message of its own:

   ```
   What license is this data under? "I don't know" is a fine answer.

   You should see: nothing changes yet. I'll store your answer with the dataset too.
   ```

   If they name a standard license, its short identifier is best (`CC-BY-4.0`, `CC0-1.0`).
   If they don't know, leave the license out of the command; the dataset's metadata then
   says that no license was stated. Never supply one yourself, because a guessed license is
   worse than none, and never store a placeholder such as `unknown` or `none` for either
   answer: the indexer would copy it into the dataset's crate as though someone had said it.
4. **Size sanity**: the policy is "everyone pins everything", and laptop disks are the
   smallest in the cluster — a dataset must comfortably fit the *smallest* member's free
   space. MB–GB: proceed. Tens of GB: pause and confirm with the consortium first.
   Check your own side: dataset size vs `ipfs.exe repo stat` and free disk.

## Adding

```powershell
ipfs-cluster-ctl.exe add -r --name '<descriptive-name>' --metadata 'source-url=<where it came from>' --metadata 'license=<license>' '<path-to-dataset>'
```

(`-r` for folders; drop it for a single file. Leave out each `--metadata '…'` part whose
answer was "I don't know".) *(Written 2026-10-08, ahead of its first performance.)*

Put each value in single quotes, as shown. In PowerShell, single quotes keep the `$`,
backticks and backslashes that web addresses can contain (`…/resource.json?$limit=5000`)
exactly as typed. A single quote inside a value is doubled, so the source `Smith's lab server`
becomes `'source-url=Smith''s lab server'`. Leave double quotation marks out of the values,
because Windows PowerShell 5.1 drops them on the way to the program, and write the folder
path without a trailing backslash, which 5.1 also mangles. If you run commands from Git Bash
instead, the shell is bash: a single quote inside a value is written `'\''`.

The last output line is the dataset's **CID** (`Qm…` / `bafy…`) — its permanent,
location-independent address. **Record CID + name together**; that pair is the archival
record.

## Verify

1. `ipfs-cluster-ctl.exe status <cid>` → this laptop says `PINNED` (`PINNING` = still
   ingesting a large dataset — wait, re-check). Checking again later, after the dataset has
   become an RO-Crate (see below), `status <cid>` no longer shows it pinned under that CID,
   which is expected: the crate pins the same data. Find the crate by name instead, in
   PowerShell, `ipfs-cluster-ctl.exe pin ls | Select-String -SimpleMatch '<descriptive-name>'`;
   `ipfs.exe ls <crate CID>` lists the original data beside the two new files, and
   `ipfs.exe cat <cid>` still prints a file dataset.
2. Straight after the add, check that the source and license arrived as the person gave them:
   `ipfs-cluster-ctl.exe --enc=json pin ls <cid>`. You should see a `"metadata"` block
   holding `"source-url"` and `"license"` exactly as they said them, only the ones they
   answered (no `"source-url"` or `"license"` in it when they knew neither). If a value is
   wrong, pin the same CID again with the right values; `pin add` on a pinned CID replaces
   its name and metadata in place:
   `ipfs-cluster-ctl.exe pin add --name '<descriptive-name>' --metadata 'source-url=…' --metadata 'license=…' <cid>`.
   Once the dataset has become a crate, a correction no longer reaches it; report a wrong
   value through the contact route in the README instead.
   *(Written 2026-10-08, ahead of its first performance.)*
3. Other members' names appear alongside as `PINNED` over the following minutes (whenever
   they're online) — that's the replication happening.
4. The original files stay wherever they were — the archive copy lives inside the node's
   own storage (and everyone else's). Deleting the originals is the owner's call, not a
   required cleanup.

## Tell the human what happened

One sentence, always: "*<name>* is archived as `<cid>` — your node holds it, the other
members are replicating it, and that address will find it on any member, forever."

Then tell them what happens next, in plain words, so a changed address later does not alarm
them. Usually within an hour, a member that runs the consortium's indexer (an anchor, or
another member who agreed to) reads the dataset. The AI model named in the indexer's recipe
(today Google's Gemini) writes a description of it from excerpts of its files; the FAQ lists
what is sent. The shared list then shows it as an **RO-Crate**, a folder holding their data,
that description and a readable page, under the same name and with a new address. The
address they just recorded keeps working on every member. A crate can take longer when the
members that run the indexer are busy or offline, and nothing needs doing in the meantime.
*(Written 2026-10-08, ahead of its first performance.)*
