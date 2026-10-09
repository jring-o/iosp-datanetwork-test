# node-skills/ — agent skills for your node

Skills your AI assistant reads so it can walk you through setting up, checking, fixing and
using your node. Each is a `SKILL.md` describing what the assistant does, what you do, and the
friction found on real builds.

**Using them:** clone this repository and open it with an assistant that reads skills; in
Claude Code they appear as slash commands (`/node-setup`). With any other tool, or a plain
chat window, point it at this directory or just paste in the skill you need. They're markdown;
nothing special is required to read them.

The prose reference behind all of them is [`../runbook/`](../runbook/). Skills automate and
assist the runbook; they don't replace it, and a skill only exists once its runbook chapter
has been performed on real hardware.

## The interaction contract (every skill that drives a human)

This is binding on every skill here that walks a person through anything. It was written
after a guide that had already produced a working machine generated eighteen defects the first
time an agent read it aloud to someone.

**One action per message, then a blank line, then what they should see.**

```
<one instruction>

You should see: <what appears>
```

### Open by teaching them the protocol

Before the first instruction, the skill's opening message tells the person how this will work.
They cannot follow a rhythm nobody explained, and a person who doesn't know they're allowed to
say "that's not what I see" will assume they made the mistake and quietly improvise. Say all
three:

- **Reply `Done`** when they've completed what they were asked to do.
- **Reply `That's not what I see`** (and describe or photograph it) whenever the screen
  doesn't match the stated expectation. Say explicitly that this is useful information and
  never their fault.
- **They can ask anything, at any point.** Questions are welcome mid-step, not just at the
  end, and you'll stay with them for the whole build.

Then, and only then, the first instruction.

The rules that make it work:

- **One action per message.** Never a numbered list of four clicks; the human is looking at
  a screen, not reading a document. Wait for them to confirm before sending the next one.
- **Name the exact on-screen label**, in bold, as it is literally written: **Change hostname**,
  not "the hostname setting". If a button says **Launch**, do not call it "Finish".
- **Never invent a label.** If you do not know what the screen says, ask. Guessing a plausible
  word costs more trust than asking costs time.
- **Always state the expectation — including when nothing visible happens.** "The row still
  reads *Change hostname*; Control Centre never shows the current value" is a real and
  necessary expectation. Silence here makes a working step look broken.
- **A step with no expected outcome is unusable**, because the agent has nothing to assert and
  will fall back on asking the human "what do you see?", which inverts the whole point of the
  skill and pushes diagnosis onto the person who has the least context.
- **If what they report differs from what you told them to expect, that is a defect in the
  document, not a mistake by the human.** Fix the document before continuing.

## When you take over the machine work, say so in plain words

There's a handover point in every build: the human stops clicking and the agent starts running
commands. From their side this looks like the conversation suddenly filling with output they
didn't ask for and can't read. **Announce the handover before the first command**, in language
that assumes no knowledge:

- **What you're about to do**, in one plain sentence — "I'm going to install the archive
  software on your node and set it to start itself whenever the power comes back."
- **Roughly how long**, so silence has a shape — "about five minutes."
- **That they have nothing to do** — "you don't need to do anything; I'll tell you when I need
  you again."

Then, while you work: **don't go silent for long stretches**. Report at natural milestones in
the same plain language, and say plainly when something worked. Technical output is evidence
for you, not a message to them; translate it. And when you need them again, say so
unmistakably, because they will have stopped watching.

Never open a stretch of machine work with a bare "this part's mine" or a chapter number. That
tells someone who doesn't know the runbook exactly nothing, and a person watching an agent do
unexplained things to hardware they just paid for will assume the worst.

## Offer to report the quirk — with consent, anonymized

Every skill that hits a surprise offers to send it back as an issue on the public repo. The
people running these nodes are the only witnesses to most of what goes wrong, and a quirk that
dies in one person's chat window costs the next person the same hour.

**The rules are not optional:**

1. **Ask, every time, and take no for an answer.** Never post automatically, never treat an
   earlier yes as standing permission for a later issue. Default is don't.
2. **Show the exact text you would post, in full, before they answer.** Consent to a summary
   is not consent to the contents.
3. **Anonymize before showing it, not after.** Strip: IP addresses of every kind (LAN, public,
   and IPv6 — the long colon-filled ones are globally unique to their household), Wi-Fi
   network names, the username, a hostname if they personalized it, MAC addresses, ISP and
   account identifiers, file paths containing their name, and any location detail. Replace
   with reserved documentation values (`192.168.1.42`, `2001:db8::…`) or a plain
   `<your address>`.
4. **Never attach a photograph or screenshot. Transcribe the text instead.** A photo of a
   screen carries the whole screen: other windows, reflections, whatever else was open. This
   has already leaked a builder's full network addresses once.
5. **Peer IDs are public by design but still identify a person's node** — leave them out unless
   the quirk genuinely cannot be described without one, and say so when you ask.
6. **Don't make them authenticate.** Most researchers have no GitHub CLI set up. Hand them the
   finished text to paste, or a prefilled link, or offer the contact route in the README for
   people with no GitHub account at all. The offer must not become a second setup task.

What makes a quirk worth offering to report: it wasn't in the runbook, or the runbook said
something different from what happened. That is exactly the material the guide is missing.

## The Pi catalogue

A member's node should need no physical contact after setup beyond a power cord and, someday,
a house move. The skills cover that whole life:

| Skill | Covers | Status |
|---|---|---|
| `node-setup` | sealed box → node **joined and holding the archive** (runbook 00–40 assisted) | ready |
| `node-join` | join an existing node to the cluster (runbook 30) — for nodes built before joining, or retries | ready |
| `node-health` | read-only "is my node okay?" checkup + plain verdict | ready; dataset count written 2026-10-08 ahead of its first performance |
| `node-doctor` | diagnose and repair a node that stopped connecting, reporting, or pinning | ready |
| `node-add-data` | add a rescued dataset to the shared pin list from your own node | ready; source and license questions written 2026-10-08 ahead of their first performance |
| `archive-search` | search the archive's index from your own node (Pi or laptop), without the website, and fetch a crate | written ahead of its first performance; report every mismatch |
| `node-off` | safe shutdown/restart before unplugging or moving | ready |
| `node-meeting-point` | anchor volunteer flow: ISP discovery, port forwards, external verify (runbook 35) | ready |
| `node-reconnect` | node moved house, new Wi-Fi, new owner, or a new computer that has never reached it (runbook 50) | written ahead of its first performance; report every mismatch |
| `node-update` | safe OS/Kubo/cluster updates over the months | **not yet written** |

## The laptop catalogue — not yet self-serve

The consortium runs a second, parallel network of members' own laptops. These skills were
built for the facilitated workshop room. `laptop-setup` no longer needs a facilitator: like the
Pi path, it needs only the network's cluster secret, and it runs on Windows only. The other
laptop skills have not been reworked yet. If you are on your own and not on Windows, build the
Pi path above, or write to the contact route in the README.

| Skill | Covers | Status |
|---|---|---|
| `laptop-setup` | own laptop → cluster member (install, join, verify) | Windows only: performed 2026-07-30; secret prompt, own naming and meeting-point lookup rewritten 2026-10-05 ahead of performance. macOS/Linux unwritten |
| `laptop-node` | daily start / check / stop | workshop-room only |
| `laptop-add-data` | add a rescued dataset from the laptop | workshop-room only |
| `laptop-reconnect` | laptop on a different network (travel, campus) | **not yet written** |
