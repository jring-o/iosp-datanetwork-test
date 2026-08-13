# FAQ

Plain-language answers for members and people considering joining. Terms in *italics* are
defined in `vocabulary.md`.

**How do I join?**
Build a node with the runbook (start at the README), and request the cluster secret through
the contact route in the README's "Joining the network" section. Everything except the final
join works before you have the secret.

**Do I need a monitor and keyboard for my node?**
Only for the first 30 minutes, ever (initial setup asks its questions on a screen). After
that the node is *headless*: it sits near your router and you talk to it from your everyday
computer. Keep a screen in the closet as the break-glass rescue tool.

**Can my laptop be the node's screen?**
No. Laptop video ports send pictures out; they can't receive them. But after setup day your
everyday computer is much better than a screen: it controls the node remotely over *SSH*.

**What's the difference between pinning and replicating?**
*Pinning* is one node's promise to keep one thing ("keep this, never delete it").
*Replication* is the network's policy for how many nodes make that promise per dataset.
Today: everyone pins everything. At scale: "at least 5 copies," per dataset, same machinery.

**Does every node really store all the data?**
Today, yes. The whole rescued corpus fits on every node with room to spare, and you hold the
*entire archive*, not a slice. When collections outgrow a single node, the *replication*
number changes; the architecture stays the same.

**Who decides what gets pinned?**
Any member can add their rescued data to the *shared pin list* from their own node; the
starting rule is that we trust each other's judgment. Whether the consortium wants a formal
process later is a *governance* question the members decide, and changing it never requires
touching the technology.

**What happens when my home IP address changes, or I move house?**
Nothing. Your node only ever dials *out*, like a phone that only makes calls: it doesn't
care what its own number is. It redials the *anchors* and it's back. You do nothing
and notice nothing.

**What happens when an anchor's IP changes?**
The cluster re-finds it by itself, three redundant ways. Members currently online learn the
new address instantly through *gossip*; members waking from sleep reach another anchor
and get told; and a node whose every saved address went stale asks the public IPFS
network, the ownerless global *address book*, where that *peer ID* lives now. All
automatic; no human involved.

**What if ALL the anchors go offline at once?**
The archive is untouched: every node still holds and serves everything. What pauses is
coordination. New pins stop spreading and heartbeats stop being recorded until any one
anchor comes back, at which point everything reconnects and catches up on its own;
nothing is lost in the gap. Only the *permanent* loss of every anchor would need a
human act: any member volunteers, forwards a port, and the consortium shares that one new
address. With five anchors in five different households on different providers,
simultaneous permanent loss is the kind of event where the cluster is not your biggest
problem.

**Why are there TWO networks?**
The Pis form one cluster; the laptops form a parallel one with its own membership
credential. Three reasons: security (the long-lived archive's credential never leaves on a
laptop), science (two survival curves, purpose-built always-on hardware vs everyday
laptops with motivated owners, measured side by side for the published study), and fun
(the two teams compete to keep theirs alive longer). The archive itself never splits:
everything rescued in either network is adopted into both. The laptop network's self-serve
setup guide is still being built; the Pi route is the complete one today.

**Aren't the anchors centralization?**
The *data* is fully distributed: every home holds everything, and no anchor is needed to
*have* or *serve* the archive. Anchors centralize only *coordination convenience*
(where newcomers connect); they're plural, volunteer-run, in homes not clouds, and any
member can become one with one router setting. That's a rotating role, not a center.

**Why doesn't the consortium just use a cloud server or a domain name?**
Deliberate values decision. Clouds get unpaid, domains lapse, companies change terms;
every one is a single point of failure with someone else's name on it. This network's fixed
points are volunteer households, and its permanent names are cryptographic (*peer IDs*),
which nobody issues and nobody can revoke.

**Can I watch the network live?**
Yes: **iosp.science/datanetwork** shows every node's heartbeat, minute by minute, both
networks side by side, straight from the clusters' own *gossip* as heard by the recorder
on node-00. It shows uptime, each node's remaining archive budget, every dataset with how
many nodes are serving it, and the latest *spot-check* verdicts, and nothing else:
never your files, never what you do, never where you are. (If the page ever looks stale,
the *recorder* may be resting, marked by a dashed divider, while the network
itself carries on regardless: the archive never depends on its own scoreboard.)

**How do we know a node really still has the data?**
Three checks, getting progressively harder to fake.

*Every minute — a roll call.* Which nodes are alive right now. Nobody asks them anything:
the nodes already announce themselves to each other every fifteen seconds, because that is
how a group of machines knows who is in the group. One node simply listens and writes it
down.

*Every five minutes — a stock-take.* Which node says it is holding which datasets. Each
node checks its own disk and reports.

*Every thirty minutes — a spot-check.* A dataset and a node are picked at random, and that
node is asked to hand over a real piece of the file. Claiming is cheap; producing is proof.
A node that answers the roll call but cannot produce the bytes fails here, which is exactly
the failure we most want to catch, because it looks perfectly healthy from the outside.

Two things worth knowing. **A node never spot-checks itself**; testing yourself proves
nothing. And **the roll call is not something we added to your node.** It is the cluster
software's own behaviour, running whether anyone is watching or not, which is why there is
no monitoring program on your Pi to install, consent to, or break.

The dashboard shows all three.

**Is there tracking software on my node?**
No, and this was a deliberate design decision rather than an accident. We considered putting
a program on each node that would report home, and rejected it. Everything we measure is
already being broadcast by the cluster software for its own purposes; we just keep a log of
what it says. Your node runs IPFS, IPFS Cluster, and a watchdog that fixes your own network
if it drops. Nothing else. Nothing reports on you that isn't also how the network functions.

**Who does the checking, and who checks them?**
Today, one machine (the project's own node) does all three checks for both networks. That
is a real weakness and we would rather say so than hide it: a single observer that broke or
lied would not be caught. The intended fix is that anchor volunteers run the spot-checks too,
so several independent machines are testing each other and disagreements become visible.
Separately, some checks are run from outside the consortium entirely, over the public IPFS
network, so the measurement never rests entirely on trusting us.

**I'm in the laptop cohort — can I just shut my laptop whenever?**
Yes, always, with no ceremony. The cluster forgives absences: while you're gone the other
members keep serving everything (including what you added), and the moment you start your
node again it reconnects and catches up on whatever it missed by itself. *(Tested for
real: a dataset added while a laptop was off arrived within a minute of restart.)* The
only cost of being away is to your team's uptime record, not to the archive.

**My node was unplugged for a month. Is it broken? Did the network forget me?**
Neither. Plug it in: it dials out, catches up on the *shared pin list*, downloads anything
it missed, and resumes heartbeating. Designed for, tested, zero effort from you.

**Will constant archiving wear out the storage?**
No. Wear is a real issue for SD cards (which is why we don't use them), but a real SSD's
endurance budget outlives us all at archive rates: decades of margin. The actual storage
risk is yanking power mid-write: just leave it plugged in, and if you must move it, run the
one shutdown command first (runbook).

**What if my node dies or my house floods?**
The archive doesn't care: every other node holds everything (today's replication). Get the
hardware replaced, rejoin with the membership *secret*, and your node re-downloads the
corpus. Your rescued datasets were never only yours to hold.

**What does volunteering as an anchor actually commit me to?**
One router setting (port forwarding: ~15 minutes, provider permitting; some ISPs make it
app-only, a few make it impossible), a node that stays plugged in like everyone else's, and
willingness to be one of ~5 such volunteers per network. Your node's permanent IDs also
enter the public anchor registry; runbook chapter 35 spells out exactly what that makes
visible, before you decide. Your node also runs the network's automatic *spot-checks*; that
is software doing its rounds, and you never lift a finger. No cost, no maintenance, and the
role can rotate to someone else with one setting.

**What if I forget my node's password?**
Your everyday computer's *SSH key* is the everyday door: no password typed, ever. The
password is the written-down-at-home fallback for the rescue-screen scenario. Forget both
and the node gets re-set-up from scratch; the archive re-downloads. Annoying, not fatal.
