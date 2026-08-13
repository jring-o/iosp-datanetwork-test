# Instructions for an AI assistant helping with this repository

You are almost certainly here because someone wants to set up, join, check, fix, or add data
to a node in this network. The skills in `node-skills/` are written for you. Read the relevant
one before doing anything else. Each is a `SKILL.md` describing the division of labour between
you and the person, the verification gates, and the friction found on real builds. They are
not summaries of the runbook; they carry things the runbook cannot.

| They want to | Read |
|---|---|
| Set up a new Raspberry Pi node | `node-skills/node-setup/SKILL.md` |
| Join an existing node to the network | `node-skills/node-join/SKILL.md` |
| Check whether their node is okay | `node-skills/node-health/SKILL.md` |
| Fix a node that seems broken or is not holding data | `node-skills/node-doctor/SKILL.md` |
| Add a dataset to the shared archive | `node-skills/node-add-data/SKILL.md` |
| Shut the node down safely, or move it | `node-skills/node-off/SKILL.md` |
| Volunteer as an anchor by opening a router port | `node-skills/node-meeting-point/SKILL.md` |
| Use their own laptop as a node instead | `node-skills/laptop-setup/SKILL.md` and the other `laptop-*` skills — **not yet self-serve**: they were built for a facilitated workshop room. If the person is alone, steer them to the Pi path, or to the contact route in the README |

The prose reference behind all of them is `runbook/`, numbered in execution order. Follow the
runbook's steps and the skill's judgement.

## How to behave

This matters more than the technical content. **One action per message, then a blank line,
then what they should see.** Wait for them to confirm before the next one. Never send a
numbered list of clicks to someone looking at a screen. The full contract is in
`node-skills/README.md` and it is binding.

The rules that matter most:

- Never invent an on-screen label. Ask what the screen says. A plausible guess costs more
  trust than a question costs time, and they cannot tell your guess from an instruction.
- Say what they should see even when nothing visibly changes, or a working step looks broken.
- If what they report differs from what you told them to expect, the document is wrong, not
  the person. Say so plainly, then fix or report it.
- Tell them the protocol before step one. Reply "done" when finished, say "that's not what I
  see" whenever the screen disagrees, and ask anything at any time.
- When you stop instructing and start running commands yourself, say what you are doing,
  roughly how long it will take, and that they have nothing to do. Silence behind terminal
  output reads as something going wrong.

## Things that will bite you

- **You cannot type passwords.** Interactive password prompts fail in an agent shell. Get
  key-based SSH working early. The person does their own password login in their own terminal.
- **The cluster secret must never enter the conversation.** Not quoted, not echoed, not in a
  command you print. If it has to move between machines, pipe it into a script reading
  standard input so it is never rendered. A secret that has appeared in a chat window is
  compromised for the whole network, not just that node. If the person doesn't have the
  secret yet, they request it through the contact route in the README's "Joining the
  network" section; never improvise around its absence.
- **Nothing may assume a username.** Read it from the person's node-facts file, described in
  `MY-NODE.template.md`. Some nodes happen to use `iosp`. That is not a rule.
- **Several normal states look exactly like failure**, and the obvious remedy destroys the
  evidence. A freshly started node misreports its pins for about a minute. A single dataset
  can sit apparently missing for up to twelve minutes before the network's own repair pass
  fixes it. If `ipfs cat <cid>` returns content while the pin looks missing, you are waiting
  rather than broken. Do not intervene before fifteen minutes.

## Their node's details

Record what you learn (node name, username, address, identities, cluster membership) in a copy
of `MY-NODE.template.md` in their working directory, and read from it rather than guessing. It
is gitignored and stays that way, because it contains their home network address. Never commit
it, never paste it into an issue, never show it to anyone.

## Reporting problems back

When something surprises you both, because the guide was wrong or silent about something that
mattered, offer to open an issue, and take no for an answer. Show them the exact text first.
Strip addresses of every kind, network names, and usernames. Never attach a photograph of a
screen; it carries the whole screen, and this has already leaked network details once.
Transcribe instead.
