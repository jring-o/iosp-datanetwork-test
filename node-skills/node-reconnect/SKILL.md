---
name: node-reconnect
description: >-
  Bring a consortium node back onto the network after it moved: a new house, a new Wi-Fi
  network, a node handed to a new owner, or a new everyday computer that has never talked
  to it. Screen and keyboard at the Pi for the Wi-Fi step, then the agent finds the node,
  gets in, records the new facts, and confirms it is back in the cluster (runbook chapter
  50). Trigger on "node-reconnect", "I moved", "new Wi-Fi", "my node came in the post",
  "new laptop can't reach my node", or any node that was working before a change of network.
---

# node-reconnect — the node moved, get it back on the network

You are helping someone whose node used to work and has changed place. The prose reference
is `runbook/50-take-home.md`. Nothing here is new machinery: the steps are the same ones that
built the node, in a different order, and the whole thing takes under half an hour when the
Wi-Fi cooperates. Rhythm: **the human does the screen-and-keyboard part; you do everything
after SSH exists.**

**Done means back in the cluster, not powered on.** A node with a Wi-Fi connection and no
members in `peers ls` is not reconnected; it holds nothing new and serves nobody. Do not
declare success until Phase D passes.

## Who you might be helping

Three people arrive here, and the skill has to know which:

- **The node's owner, after a move or a new router.** Same person, same computer, new
  network. Phases A, B (short), C, D.
- **A new owner.** Someone was sent this node by a member. Their computer has never seen it,
  and they have never seen its facts file. They need three things from the sender, out of
  band: the **username**, the **password**, and the sender's **`MY-NODE.md`** (or at least
  the node's name and its two peer IDs). Without the username and password there is no way
  in and this skill cannot proceed; ask for them before touching anything. The cluster
  secret is already on the node; they do not need it.
- **The same node, a new everyday computer.** Nothing about the node changed. Skip Phase A
  entirely; the node is already on the network. Phase B is the whole job.

Ask which one it is in your first message, after the protocol.

## How to talk to the human

Same contract as `node-setup`, and it is not optional: **one action per message, a blank
line, then what they should see.** First message teaches the protocol (reply **`Done`**,
reply **`That's not what I see`** with a description or photo, ask anything at any time),
then asks which of the three situations above they are in, then gives step one. Never a
numbered list of clicks. Name on-screen labels exactly as written, in bold, and if you do
not know the label, ask what the screen says rather than invent one. When you take over
the keyboard, say what you are doing, how long it takes, and that they have nothing to do.

## Ground rules

- **There is no path without a screen.** Until the node is on their network, nothing can
  reach it, and the only way to give it a network is at the machine. A TV with an HDMI
  input counts; most homes have one. Plus a USB keyboard, which is the thing people most
  often have to borrow. Say this in the first message so they gather both before starting,
  not in the middle.
- **Never use the address in `MY-NODE.md` after a move.** It belonged to the old network. Read
  the new one off the screen in Phase A, or find the node in Phase B; then overwrite it.
- **Passwords are ordinary facts here.** The node's password and the home Wi-Fi password go
  in `MY-NODE.md`; ask for them plainly and record them. `ssh` itself will not accept a
  password from your shell (its prompt reads only from a real keyboard), so a password login
  is either typed by the human in their own terminal or run by you through a helper
  (`sshpass` on Mac/Linux, PuTTY's `plink -pw` on Windows) if one is installed. The cluster
  secret is the one thing that never enters the chat; it is already on the node and this
  skill never needs it.
- **The node may reboot itself during Phase A.** Its watchdog reboots it after about thirty
  minutes without internet. That is the watchdog doing its job, not a fault; wait for the
  desktop to come back and carry on.
- **Wait before judging.** The Pi has no battery clock. After a week in a box its clock is
  wrong until a minute or two after it gets internet, and the cluster daemon takes a few
  minutes more to find the others. Nothing in Phase D is a verdict before five minutes.
- **Errors get captured verbatim**, photo or copy-paste, before anyone clicks past.

## Phase A — at the Pi (human's hands, your eyes)

Skip this phase entirely for the new-computer case. For everyone else:

1. Confirm they have the node, its power supply, a screen with HDMI (a TV is fine), and a
   USB keyboard. A mouse helps but is not required; everything below can be done from the
   keyboard. Confirm they know the node's **username** and **password** (the owner set
   them; a new owner got them from the sender). Confirm they know their **home Wi-Fi name
   and password**; write both into `MY-NODE.md` now.
2. Connect the screen (micro-HDMI port nearest the power socket), the keyboard, then power
   **last**. There is no power button; plugging in is on.
   Tell them what boot looks like so they don't pull the plug: a boot screen, then the
   desktop, possibly with a login box first. If a login box appears they type the username
   and password. **You should see:** the Raspberry Pi desktop, with a bar along the top.
3. **Join the Wi-Fi.** Have them click the **network icon** near the right end of the top
   bar (beside the clock and the volume icon). A list of nearby Wi-Fi networks drops down.
   Ask them to click their home network. A box asks for the network's password; they type
   it and confirm. **You should see:** the icon change to Wi-Fi bars within a few seconds.
   If the icon or the list doesn't look like that, do not guess at labels; ask what they
   see. The fallback is the terminal, and it is more reliable than the menu: open the
   terminal (the black monitor icon in the top bar) and have them type

   ```
   sudo nmcli device wifi connect "<home Wi-Fi name>" password "<home Wi-Fi password>"
   ```

   **You should see:** a line ending `successfully activated`. Two lines saying
   `No network with SSID` means the name was mistyped (it is case-sensitive) or the
   network is 5 GHz-only and out of range; move the node closer or use the 2.4 GHz name.
   The old network stays saved on the node, which is harmless: it will join whichever one
   it can see.
4. **Read the new address.** In the terminal: `hostname -I`. The output holds two or three
   items. **Ask for the short one with dots** (like `192.168.1.42`); the long ones full of
   colons are a different kind of address this guide doesn't use. Empty output means the
   Wi-Fi didn't take; back to step 3. Record the address in `MY-NODE.md`, replacing the old
   one.
5. Leave the screen and keyboard plugged in until Phase B succeeds; they are the fallback
   if SSH doesn't answer.

## Phase B — get in from their computer (human once, then you)

6. **Same computer as before, same node:** `ssh -o BatchMode=yes <username>@<address>
   hostname` from your shell. If it prints the node's name, the key still works and this
   phase is done; go to Phase C. If the host key is rejected because the address was
   previously used by a different machine (`REMOTE HOST IDENTIFICATION HAS CHANGED`), that is
   the new network reusing an address, not an attack; remove the stale line with
   `ssh-keygen -R <address>` and try again.
7. **New computer (the new-owner case, or the owner's new machine).** Find the node first
   if Phase A was skipped: try `ping <node name>.local`; if that fails (common when the
   computer runs a VPN), ping-sweep the home network and match Raspberry Pi hardware
   prefixes in the ARP table (`2c-cf-67`, `d8-3a-dd`, `e4-5f-01`, `dc-a6-32`, `b8-27-eb`,
   `28-cd-c1`). Then, in the human's own terminal: `ssh <username>@<address>` → `yes` to
   the host key → password → they land on `<username>@<node name>`. That is the moment; say
   so. `exit`.
   **`Connection closed by <address> port 22`** with no password prompt means the node is
   still finishing a boot; wait a minute and try again. Nothing is wrong.
8. Install this computer's key so the password is never asked again from it:
   - Windows: `type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh <username>@<address> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"`
   - Mac/Linux: `ssh-copy-id <username>@<address>`
   - No key yet? `ssh-keygen -t ed25519` first, defaults fine.
   Either the human runs it in their terminal (typing the password once more), or you run it
   through a password helper with the password from `MY-NODE.md`. Then record your host key
   non-interactively: `ssh -o StrictHostKeyChecking=accept-new -o BatchMode=yes
   <username>@<address> exit`.
9. Verify: `ssh -o BatchMode=yes <username>@<address> hostname` prints the node name with no
   password prompt. The old computer's key still works too; nothing was replaced, the node's
   list of trusted computers just grew. From here the screen and keyboard can retire.

## Phase C — bring `MY-NODE.md` up to date (you)

10. If the human has no `MY-NODE.md` (new owner without the sender's copy), create it from
    `MY-NODE.template.md` and fill it from the machine: node name (`hostname`), username,
    address (Phase A or B), OS (`head -2 /etc/os-release`), drive (`cat
    /sys/class/nvme/nvme0/model`), free space (`df -h /`), Kubo version (`ipfs --version`),
    cluster version (`ipfs-cluster-service --version`), storage budget (`ipfs config
    Datastore.StorageMax`), IPFS peer ID (`ipfs id -f '<id>'`), cluster peer ID
    (`ipfs-cluster-ctl id | head -1`, the leading `12D3KooW…` string), cluster name
    (`grep cluster_name ~/.ipfs-cluster/service.json`).
11. Otherwise update what changed: the address, the Wi-Fi name and password, the node's
    password if it was handed over, and a dated line in **Notes** saying the node moved and
    from what kind of network to what kind (home to home, workshop to home), which is the
    detail the retention report needs.

## Phase D — is it back in the cluster? (you; this is the finish line)

Run these over SSH (`ssh -o BatchMode=yes <username>@<address> '<command>'`). Give the node
five minutes from the moment Wi-Fi came up before reading any result as a verdict.

12. Services: `systemctl is-active ipfs ipfs-cluster` → both `active`. If either is
    `inactive` or `failed`: `sudo systemctl restart <service>`, once; if it doesn't hold,
    capture `journalctl -u <service> -n 50` verbatim and hand off to `node-doctor`.
13. Internet: `ipfs swarm peers | wc -l` → dozens to hundreds. Single digits in the first
    minute is normal; sustained zero after five minutes means the node has Wi-Fi but no
    internet, which is a router or ISP matter, not a node fault. Check that another device
    in the house can browse before going further.
14. **Membership:** `ipfs-cluster-ctl peers ls | head -3` → the node's own name, then
    `Sees N other peers` with N ≥ 1. **This is the check that matters.** The node finds the
    consortium by itself: at every boot its resolver asks the public IPFS network where the
    anchors currently are and writes the answers into its peerstore, so no address had to
    be known in advance and nothing about the new house has to be configured. If N is 0
    after five minutes, in order:
    - `systemctl status iosp-resolve-mp.service`: did it run at this boot? `lookup failed;
      keeping cached entries` is safe (it kept what it had and retries next boot); an error
      is a finding.
    - `cat ~/.ipfs-cluster/peerstore`: is there at least one **public** address (not
      `192.168…` or `10.…`) for an anchor? Addresses from the old network are still listed
      and harmless; that dial fails and the next entry is tried.
    - `sudo systemctl restart ipfs-cluster`, wait two minutes, re-run `peers ls`.
    - Still alone: the new network may block the outbound port the cluster uses. Test it:
      `timeout 8 bash -c "cat < /dev/null > /dev/tcp/<anchor public address>/9096"` (the
      address is in the peerstore). Failure here on a network where browsing works is a
      real finding; capture it verbatim and go to `node-doctor` Phase D.
15. **Data:** `ipfs-cluster-ctl status | head -20` → rows `PINNED`. `PINNING` is fine (still
    downloading what it missed). `UNPINNED` right after a restart clears within a minute; a
    single `UNEXPECTEDLY_UNPINNED` can take up to twelve minutes for the cluster's own
    repair pass. Both look like data loss and are not. `ipfs cat <a dataset's CID> | head -c
    200` returning content means transport is fine and you are only waiting.
16. Watchdog: `systemctl is-active iosp-net-watchdog.timer` → `active`. It protects the node
    from the next Wi-Fi hiccup; if it isn't running, `sudo systemctl enable --now
    iosp-net-watchdog.timer`.

**Now the node is reconnected.** Tell the human, in plain words: their node is back in the
consortium, it has caught up (or is catching up) on whatever was rescued while it was away,
and it again needs nothing from them, including after a power cut. The screen and keyboard
come off.

## Phase E — hand over

17. Write the date and the outcome into `MY-NODE.md` Notes.
18. Point them at what to run later: `node-health` for a checkup, `node-doctor` if something
    seems wrong, `node-add-data` when they have something to rescue.
19. **Offer to report anything that surprised you both** as an issue on the public repository,
    consent-gated and anonymized per `../README.md`. This chapter was written before its
    first performance; every place it differed from what actually happened is exactly what
    the next mover needs.

## What this skill does NOT cover

A node that was never joined (`node-join`), a node that stopped working without moving
(`node-doctor`), and volunteering the node as an anchor from its new address
(`node-meeting-point`; note an anchor that moves house has to redo its port forwarding on
the new router, and the registry entry needs no change because it names the node by identity,
not address).
