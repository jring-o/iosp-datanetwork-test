---
name: node-off
description: >-
  Safely shut down or restart a consortium node: the one command that runs before
  unplugging or moving the Pi. Trigger on "shut down my node", "turn off my Pi", "I'm
  moving my node", "node-off", "we're traveling / power work at home", or any planned
  unplugging.
---

# node-off — the one command before pulling the plug

The node is designed to be left alone: it survives power cuts and comes back by itself.
This skill exists because *planned* power removal deserves a clean landing; yanking power
mid-write is the main storage risk these nodes have.

## When to use

- Moving the node (new shelf, new house, travel prep)
- Planned power interruptions (electrical work, storm prep)
- **Not needed** for: leaving it alone, reboots (see below), or after an unplanned power
  cut — see "It got unplugged without this."

## Shut down (agent + human)

1. You, over SSH: `sudo shutdown -h now`. Your connection dropping immediately is normal
   and correct.
2. Human: wait for the Pi's activity light to go quiet (~30 seconds), then unplug.
3. That's it.

## Turning it back on

Plugging in IS the power button. Nothing else: no screen, no keyboard, no commands. Within
~2 minutes the node is fully back: IPFS reconnected, cluster rejoined, heartbeat
recording resumed. *(Tested 2026-07-30 on node-00: full self-resurrection from a real
unplug, all services + pins intact, 455 network peers within a minute.)* If you want
certainty, run `node-health` after two minutes.

## Restart instead (no hands needed)

`sudo reboot`: no unplugging, back in ~75 seconds. Tested repeatedly; safe to run
whenever a restart is called for.

## It got unplugged WITHOUT the shutdown command

Don't panic; the node normally shrugs this off (journaled filesystem, and the software
re-syncs anything it missed). Plug it back in, wait two minutes, run `node-health`. If
anything reports NEEDS ATTENTION, capture the exact output and report it; that's precisely
the entropy the consortium documents.
