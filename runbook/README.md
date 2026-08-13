# runbook/ — the build guide

Numbered chapters, in execution order, from a sealed box to a node holding the archive.
Read them in order the first time; after that they are reference.

Every step here has been performed on real hardware before it was written down. The timings
are measured from those builds.

| Chapter | What it covers | Who needs it |
|---|---|---|
| [`00-hardware.md`](00-hardware.md) | Unbox, what's in the kit, connect it up | everyone |
| [`10-first-boot.md`](10-first-boot.md) | The setup wizard, naming the node, remote access, retiring the monitor | everyone |
| [`20-kubo.md`](20-kubo.md) | Install IPFS and set it to run itself | everyone |
| [`25-watchdog.md`](25-watchdog.md) | The watchdog that fixes your network connection by itself | everyone |
| [`30-cluster.md`](30-cluster.md) | Join the network. Needs the cluster secret | everyone |
| [`35-meeting-point.md`](35-meeting-point.md) | Volunteering as an anchor: opening a router port so newcomers can dial you | volunteers only |
| [`40-data.md`](40-data.md) | Add a dataset, and prove another node has it | everyone, eventually |

Each chapter opens with the state you start in and the state you end in, so you can tell at a
glance whether you're in the right place.

## If a step doesn't match what you see

That is a defect in this guide, not a mistake by you, and it is the most useful thing you can
tell us. Screens change, software updates, and the people who wrote a step are the last people
able to notice it has gone wrong.

Please open an issue. The template walks you through what to include and what to leave out.
No addresses, no photographs of your screen. If you don't have a GitHub account, send the
same report through the contact route in the root README.

## If you'd rather not do this by hand

`../node-skills/` has agent skills that follow these same chapters with an AI assistant doing
the technical parts. The runbook stays the reference either way; the skills automate it rather
than replacing it.
