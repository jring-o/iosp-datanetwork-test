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
4. **Size sanity**: `du -sh` the dataset, `df -h /` on the node. The corpus policy is
   "everyone pins everything", so a dataset must comfortably fit the *smallest* node's free
   space. MB–GB: proceed. Tens of GB: pause and raise it first via the contact route in
   the README.
5. **Get it onto the node** if it's on their everyday computer:
   `scp -r <local-path> <username>@<address>:/tmp/` (username and address from `MY-NODE.md`;
   it's a staging copy, and the node imports it into its archive storage in the next step).

## Adding (on the node)

```
ipfs-cluster-ctl add -r --name '<descriptive-name>' --metadata 'source-url=<where it came from>' --metadata 'license=<license>' /tmp/<dataset>
```

(`-r` for folders; drop it for a single file. Leave out each `--metadata '…'` part whose
answer was "I don't know".) *(Written 2026-10-08, ahead of its first performance.)*

Put each value in single quotes, as shown. Inside single quotes the node's shell keeps every
character as typed, including the `$`, backticks and backslashes that web addresses can
contain (`…/resource.json?$limit=5000`). A single quote inside a value is written `'\''`, so
the source `Smith's lab server` becomes `'source-url=Smith'\''s lab server'`.

Run it on the node, never wrapped in a one-line `ssh '…'`: the values' single quotes cannot
nest inside the wrapper's, and Windows PowerShell 5.1 drops inner double quotes on the way to
`ssh`. Either the person types it in an SSH session (`ssh <username>@<address>`, then the
command), or you deliver it as a file, as node-setup delivers every script. Save the one
`ipfs-cluster-ctl add` line as `add-dataset.sh` on their computer, with LF line endings (a
Windows line ending would become part of the last argument), then:

```
scp add-dataset.sh <username>@<address>:/tmp/
ssh <username>@<address> 'bash /tmp/add-dataset.sh'
```

The output's last line is the dataset's **CID** (`Qm…` / `bafy…`): its permanent,
location-independent address. **Record it with the name**; that pair is the archival record.

## Verify, then clean up

1. `ipfs-cluster-ctl status <cid>` → this node says `PINNED` (large datasets show `PINNING`
   while ingesting; wait, re-check). Checking again later, after the dataset has become an
   RO-Crate (see below), `status <cid>` no longer shows it pinned under that CID, which is
   expected: the crate pins the same data. Find the crate by name instead,
   `ipfs-cluster-ctl pin ls | grep -F <descriptive-name>`; `ipfs ls <crate CID>` lists the
   original data beside the two new files, and `ipfs cat <cid>` still prints a file
   dataset.
2. Straight after the add, check that the source and license arrived as the person gave them:
   `ipfs-cluster-ctl --enc=json pin ls <cid>`. You should see a `"metadata"` block holding
   `"source-url"` and `"license"` exactly as they said them, only the ones they answered (no
   `"source-url"` or `"license"` in it when they knew neither). If a value is wrong, pin the
   same CID again with the right values, run the same way as the add; `pin add` on a pinned
   CID replaces its name and metadata in place:
   `ipfs-cluster-ctl pin add --name '<descriptive-name>' --metadata 'source-url=…' --metadata 'license=…' <cid>`.
   Once the dataset has become a crate, a correction no longer reaches it; report a wrong
   value through the contact route in the README instead.
   *(Written 2026-10-08, ahead of its first performance.)*
3. Other nodes replicate automatically: their names appear alongside as `PINNED` over the
   following minutes or hours (visible whenever they're online).
4. Sovereignty copy (consortium convention): also reference it in the node's Files space,
   which survives shared-list removal AND garbage collection (a plain `ipfs pin add` does
   NOT; cluster unpins remove it; tested):
   `ipfs files mkdir -p /sovereign 2>/dev/null; ipfs files cp /ipfs/<cid> "/sovereign/<descriptive-name>"`
5. Now delete the staging copy: `rm -r /tmp/<dataset>` (and `/tmp/add-dataset.sh` if you
   used one). The data lives in the node's archive storage (and everyone else's), not in
   /tmp.

## Tell the human what happened

One sentence, always: "*<name>* is archived as `<cid>`: your node holds it, the consortium
is replicating it, and that address will find it on any node, forever."

Then tell them what happens next, in plain words, so a changed address later does not alarm
them. Usually within an hour, a member that runs the consortium's indexer (an anchor, or
another member who agreed to) reads the dataset. The AI model named in the indexer's recipe
(today Google's Gemini) writes a description of it from excerpts of its files; the FAQ lists
what is sent. The shared list then shows it as an **RO-Crate**, a folder holding their data,
that description and a readable page, under the same name and with a new address. The
address they just recorded keeps working on every node, and their sovereignty copy is
unaffected. A crate can take longer when the members that run the indexer are busy or
offline, and nothing needs doing in the meantime. *(Written 2026-10-08, ahead of its first
performance.)*
