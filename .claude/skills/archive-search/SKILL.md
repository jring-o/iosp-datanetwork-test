---
name: archive-search
description: >-
  Search the consortium's archive from the researcher's own node, without the website, using
  only the commands the node already has. Finds the index files on the node's shared pin
  list, reads them, searches them by word, and fetches a crate. Trigger on
  "search the archive", "find a dataset", "is there data on X in the archive",
  "archive-search", or a researcher looking for something the consortium holds.
---

# archive-search — find a dataset in the archive from your own node

This skill never pins, unpins or adds anything to the archive. Every member that runs the
consortium's indexer (anchors, and other members who agree to) pins one index file,
`_iosp-index-<name>`, into each network it belongs to. `<name>` is the name of that member's
node. The index file is a JSON file listing every RO-Crate the indexer made on that member's
node, in either network, each with its title, dataset name, keywords, research field,
description, size, address and the networks whose shared lists hold it. (A crate is a folder
holding a dataset, its description and a readable page.) Every member holds the index files
pinned in its own network, so it can search them with no website and no extra software.
*(Written 2026-10-08, ahead of its first performance.)*

Talk to the person by the interaction contract in `../README.md`: one action per message,
then what they should see.

## Ask what they are looking for

```
What are you looking for? A word or two is enough, such as "tide" or "household".

You should see: nothing changes on your screen. I'll search the archive on your node and
show you what matches.
```

## Search

Before the first command, tell them in one sentence that you are searching the archive's
index on their node, that it takes a few seconds, and that they have nothing to do. Username
and address come from `MY-NODE.md`. Each command below has no quotes inside its `ssh '…'`,
so it reaches the node intact from bash and from Windows PowerShell 5.1 alike; keep it that
way, and search for single words.

### On a Pi node

Find the index files:

```
ssh -o BatchMode=yes <username>@<address> 'ipfs-cluster-ctl pin ls | grep _iosp-index-'
```

Expect one line per index file, `<index CID> | _iosp-index-<name> | PIN | …`. Then search
each one, with their word in place of `tide` (add `-e <word>` for each further word):

```
ssh -o BatchMode=yes <username>@<address> 'ipfs --timeout=60s cat <index CID> | grep -i -e crate_cid -e name -e networks -e iosp- -e research_field -e title -e total_size -e tide'
```

### On a laptop node, in PowerShell

```powershell
[Console]::OutputEncoding = [Text.Encoding]::UTF8
ipfs-cluster-ctl.exe pin ls | Select-String _iosp-index-
ipfs.exe --timeout=60s cat <index CID> | Select-String -Pattern crate_cid, '"name"', networks, 'iosp-', research_field, '"title"', total_size, tide
```

The first line lets PowerShell show titles in any language. `Select-String` ignores case by
itself. If the programs are not on PATH, name them by their full path,
`& "$env:USERPROFILE\iosp-laptop-node\bin\ipfs.exe"`. From Git Bash, use the Pi's `grep`
forms without `ssh`; avoid `findstr /i` there, because Git Bash rewrites `/i` into the drive
path `I:/`.

## Reading the result

The index file lists each crate's fields in alphabetical order, so the search prints one
block per crate, from its `"crate_cid"` line to its `"total_size"` line:

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

A crate matches when a line with their word appears in its block, its `name` and `title`
lines included. Only the lines directly under `"networks"` name the networks whose shared
lists hold the crate; `iosp-nodes` is the Pis' network and `iosp-laptops` the laptops'.
Other lines containing `iosp-` are the crate's own keywords, description or file names.
`total_size` is the dataset's size in bytes. Skip `previous_crate_cid` lines and the single
`"name"` line at the very top, which names the member that made the file. The lines after
the last block name the file's own format and networks, not a crate's; an index file with no
crates prints only its top `"name"` line and those format and networks lines. Show the person
each match's title, dataset name, research field and crate address, the first five if there
are more, and offer the rest.

If `grep _iosp-index-` prints nothing, no index file has been pinned into this node's network
yet; nothing is wrong with their node. A dataset added in the last hour or so may not be
described yet either. In both cases search the shared list's names, which every dataset has
from the moment it is added:

```
ssh -o BatchMode=yes <username>@<address> 'ipfs-cluster-ctl pin ls | grep -i tide'
```

On a laptop node: `ipfs-cluster-ctl.exe pin ls | Select-String tide`. If `ipfs cat` stops
with an error after its minute, that index file has not reached the node yet; use the others
and try again later.

## Fetch a crate

A crate holds the whole dataset, so offer a copy in a message of its own, with the size from
the crate's `total_size` line in plain units:

```
Would you like a copy of this dataset on your computer? It is about 1.6 MB, and it comes as
one folder holding the data and its description.

You should see: nothing changes yet. Reply yes or no.
```

On a yes, tell them before the first command that you will fetch the dataset and copy it to
their computer, that a small dataset takes about a minute and a large one as long as its
transfer, and that they have nothing to do.

First check, within a minute, that a member holding the crate can be reached. `ipfs get` has
no time limit and waits for as long as no holder is online, so never start it without this
check:

```
ssh -o BatchMode=yes <username>@<address> 'ipfs --timeout=60s ls <crate address>'
```

Expect three lines, naming `ro-crate-metadata.json`, `ro-crate-preview.html` and the data.
If it stops with an error after its minute, no member holding the crate is online; tell them
so and offer to try later. A crate whose networks leave out this node's own network is held
only by members of the other network. The node can still fetch it over the public IPFS
network whenever one of those members is online, though it can be slow.

On a Pi node, fetch it on the node, copy it to their computer, then remove the node's extra
copy. `ipfs get` writes a second full copy of the dataset to the node's disk; the archive
keeps its own:

```
ssh <username>@<address> 'ipfs get -o ~/<dataset name> <crate address>'
scp -r <username>@<address>:~/<dataset name> .
ssh <username>@<address> 'rm -r ~/<dataset name>'
```

On a laptop node: `ipfs.exe --timeout=60s ls <crate address>` for the check, then
`ipfs.exe get -o <dataset name> <crate address>`.

Then tell them it has arrived. They should see a folder named after the dataset, holding
`ro-crate-metadata.json`, `ro-crate-preview.html` and the data itself. The preview opens in
any browser and shows the description.

## Tell the human what happened

One sentence for the best match: "*<title>* (`<dataset name>`, <research field>) is in the
archive at `<crate address>`." Then one more, every time: the title, description and keywords
were written by a model from the files, so check them against the data; the source and
license, when the crate has them, came from the person who added the dataset.

If something here did not match what you saw, offer to report it, consent-gated and
anonymized per `../README.md`.
