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
2. **Find out where it came from, and its license.** You are the only reliable source for
   both: the consortium's indexer copies them into the metadata it writes for your dataset
   (see "Your dataset becomes an RO-Crate"), and a model reading the files cannot know
   where you found them or on what terms. A web address is best for the source; without
   one, a few words will do, such as "copied from a retired lab file server in 2025". For
   the license, a short identifier such as `CC-BY-4.0` or `CC0-1.0` is best. If you don't
   know one of them, leave it out rather than guess, and never write a placeholder such as
   `unknown`, which would be copied into the metadata as though it were an answer.
   *(Written 2026-10-08, ahead of its first performance.)*
3. **Check the size against the smallest node, not yours.** The corpus policy is that everyone
   pins everything, so a dataset has to fit comfortably on the *least* spacious member.
   `du -sh <dataset>` for its size, `df -h /` for your headroom. Megabytes to a few gigabytes:
   go ahead. Tens of gigabytes: raise it first through the contact route in the README,
   because that is a policy conversation rather than a technical one.
4. **Get it onto the node** if it's sitting on your everyday computer:

   ```
   scp -r <local-path> <username>@<address>:/tmp/
   ```

   This is a staging copy. The node imports it into its own archive storage in the next step.

## Add it

On the node, typed in an SSH session:

```
ipfs-cluster-ctl add -r --name '<descriptive-name>' --metadata 'source-url=<where it came from>' --metadata 'license=<license>' /tmp/<dataset>
```

Use `-r` for a folder; drop it for a single file. Leave out each `--metadata '…'` part you
have no answer for.

Keep each value in single quotes, as shown, so the node's shell keeps every character as
typed, including the `$`, backticks and backslashes some web addresses contain
(`…/resource.json?$limit=5000`). A single quote inside a value is written `'\''`, so the
source `Smith's lab server` becomes `'source-url=Smith'\''s lab server'`. Type the command in
an SSH session on the node rather than wrapping it in `ssh '…'` from your computer: the
values' single quotes cannot nest inside the wrapper's, and Windows PowerShell 5.1 also drops
inner double quotes. *(Written 2026-10-08, ahead of its first performance.)*

**You should see:** a line reading `added <identifier> <filename>`. That identifier (starting
`Qm…` or `bafy…`) is the dataset's **permanent address**. It is derived from the content
itself, so it will find this data on any node, anywhere, forever, and it doubles as a checksum:
if the bytes change, the address changes.

**Record the name and the identifier together.** That pair is the archival record.

Straight after the add, check that the source and license arrived as you typed them:

```
ipfs-cluster-ctl --enc=json pin ls <identifier>
```

**You should see:** a `"metadata"` block holding `"source-url"` and `"license"` exactly as you
gave them, and only the ones you gave (no `"source-url"` or `"license"` in it if you gave
neither). If a value is wrong, pin the same identifier again with the right values. On a
pinned identifier, this replaces the name and metadata in place:

```
ipfs-cluster-ctl pin add --name '<descriptive-name>' --metadata '…' <identifier>
```

Once your dataset has become a crate ("Your dataset becomes an RO-Crate", below), a
correction no longer reaches it; report a wrong value through the contact route in the
README instead. *(Written 2026-10-08, ahead of its first performance.)*

## Prove it landed

1. On your own node:

   ```
   ipfs-cluster-ctl status <identifier>
   ```

   **You should see** your node listed as `PINNED`. Large datasets show `PINNING` while they
   ingest; wait and re-check. Once your dataset has become an RO-Crate ("Your dataset
   becomes an RO-Crate", below), this command no longer shows it pinned under its original
   identifier; look for the crate by name instead.

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

## Your dataset becomes an RO-Crate

*(Written 2026-10-08, ahead of its first performance.)*

Usually within an hour of the add, the consortium's indexer reads your dataset. It runs on
some anchors, and on other members' nodes whose owners have agreed to run it. The AI model
named in the indexer's recipe (today Google's Gemini) writes a title, a description,
keywords and a research field for your dataset from excerpts of its files, along with what
its files and columns hold; the FAQ lists what is sent. The indexer wraps your data,
unchanged, in an **RO-Crate**, a folder holding your dataset, a standard metadata file
(`ro-crate-metadata.json`) with that description and your source and license, and a page
any browser can show (`ro-crate-preview.html`). The crate goes onto the shared list under
your dataset's name, with a new identifier. Once every member that is online and holds your
dataset also holds the crate, your dataset's plain entry leaves the list.

Your original identifier keeps working on every node, because the crate contains your
dataset's own blocks. Your sovereignty copy refers to that identifier and is unaffected. A
crate can take longer than an hour when the members that run the indexer are busy or
offline; nothing needs doing in the meantime. The indexer's recipe can also name datasets
that are never wrapped.

To see the crate:

```
ipfs-cluster-ctl pin ls | grep "<descriptive-name>"
ipfs ls <crate identifier>
```

**You should see:** a line with your dataset's name and the crate's identifier, then the
crate's three entries, `ro-crate-metadata.json`, `ro-crate-preview.html` and your data. For
a while the first command can show two lines, your plain entry and the crate; the plain one
goes once the swap completes.

## Find a dataset in the archive

*(Written 2026-10-09, ahead of its first performance.)*

Every member that runs the indexer pins an index file, `_iosp-index-<name>`, into each
network it belongs to. `<name>` is the name of that member's node. The file lists the crates
the indexer made on that member's node, in either network, with each crate's title, dataset
name, research field, networks, size and identifier. Your node holds every index file pinned
in its network, so you can search them on the node itself. The `archive-search` skill does
the same with an assistant.

On the node, typed in an SSH session, find the index files:

```
ipfs-cluster-ctl pin ls | grep _iosp-index-
```

**You should see:** one line per index file, such as
`<index identifier> | _iosp-index-<name> | PIN | …`. If it prints nothing, no index file
has been pinned into your network yet; search the names on the shared list instead, as shown
further down.

Search each index file for a word, here `tide`; add `-e <word>` for each further word:

```
ipfs --timeout=60s cat <index identifier> | grep -i -e crate_cid -e name -e networks -e iosp- -e research_field -e title -e total_size -e tide
```

**You should see:** one block per crate, from its `"crate_cid"` line to its `"total_size"`
line:

```
   "crate_cid": "bafy…",
    "tide gauge",
   "name": "noaa-tide-gauges-boston-1921-2019",
   "networks": [
    "iosp-laptops",
    "iosp-nodes"
   "previous_crate_cid": null,
   "research_field": "Earth and related Environmental sciences",
   "title": "Boston tide gauge readings, 1921 to 2019",
   "total_size": 1654321
```

A crate matches when your word appears in its block. Only the lines directly under
`"networks"` name the networks whose shared lists hold the crate; `iosp-nodes` is the Pis'
network and `iosp-laptops` the laptops'. Other lines containing `iosp-` are the crate's own
keywords, description or file names. `total_size` is the dataset's size in bytes. Skip
`previous_crate_cid` lines and the single `"name"` line at the very top, which names the
member that made the file. The lines after the last block name the file's own format and
networks, not a crate's; an index file with no crates prints only its top `"name"` line and
those format and networks lines. If the command stops with an error after a minute, that
index file has not reached your node yet; use the others, and try it again later.

A dataset added in the last hour or so may not be in an index yet, but its name is on the
shared list from the moment it is added:

```
ipfs-cluster-ctl pin ls | grep -i tide
```

**You should see:** a line for each dataset or crate whose name contains your word.

To fetch a crate, first check that a member holding it is online:

```
ipfs --timeout=60s ls <crate identifier>
```

**You should see:** within a minute, three lines naming `ro-crate-metadata.json`,
`ro-crate-preview.html` and the data. An error after a minute means no member holding the
crate is online; try again later, and do not run `ipfs get` until this check passes, because
`ipfs get` has no time limit and waits for as long as no holder is online. A crate whose
networks leave out `iosp-nodes` is held only in the laptops' network. Your node can still
fetch it over the public IPFS network whenever one of those laptops is online, though it can
be slow.

Then fetch it on the node:

```
ipfs get -o ~/<dataset name> <crate identifier>
```

**You should see:** `Saving file(s) to` and the folder's path; a large dataset may also show
a progress bar. The prompt comes back when it has finished. The crate holds the whole
dataset, so this is a second full copy on the node's disk; the archive keeps its own.

From a terminal on your everyday computer, copy it over:

```
scp -r <username>@<address>:~/<dataset name> .
```

**You should see:** each file's name as it copies, then a folder named after the dataset in
your computer's current folder, holding `ro-crate-metadata.json`, `ro-crate-preview.html`
and the data. The preview opens in any browser and shows the description.

Back on the node, remove its extra copy:

```
rm -r ~/<dataset name>
```

**You should see:** nothing printed. The archive's own copy is untouched.

On a laptop node, the same steps in PowerShell are below. The first line lets PowerShell
show titles in any language, and each step shows what is described above; the fetched
folder lands in PowerShell's current folder, and a crate whose networks leave out
`iosp-laptops` is held only in the Pis' network.

```powershell
[Console]::OutputEncoding = [Text.Encoding]::UTF8
ipfs-cluster-ctl.exe pin ls | Select-String _iosp-index-
ipfs.exe --timeout=60s cat <index identifier> | Select-String -Pattern crate_cid, '"name"', networks, 'iosp-', research_field, '"title"', total_size, tide
ipfs.exe --timeout=60s ls <crate identifier>
ipfs.exe get -o <dataset name> <crate identifier>
```

If the programs are not on PATH, name them by their full path,
`& "$env:USERPROFILE\iosp-laptop-node\bin\ipfs.exe"`.
