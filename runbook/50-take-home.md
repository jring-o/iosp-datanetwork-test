# 50 — The node moved: get it back on the network

**You start with:** a node that was working somewhere else. It moved house, or the Wi-Fi
changed, or someone sent it to you, or you are sitting at a computer that has never talked
to it.
**You end with:** the node on the new network, reachable from your computer without a
password, and back in the consortium's cluster, catching up on whatever it missed.
**Time:** under half an hour when the Wi-Fi cooperates, most of it waiting.

*This chapter was written before it was first performed. Every other chapter was written from
a real build; this one is those same steps in a new order, and its first real performance
will correct it. If something here differs from what you see, that is the chapter's fault,
and reporting it is the most useful thing you can do.*

There is nothing to configure about the new house. The node finds the consortium by itself:
at every boot it asks the public IPFS network where the anchors currently are and dials them.
What it cannot do by itself is join a Wi-Fi network it has never heard of, and that is the
only reason you need a screen.

## What you need

- The node and its power supply.
- **A screen with an HDMI input.** A TV is fine. This is the one step that cannot be done from
  another computer, because until the node is on your network no computer can reach it.
- **A USB keyboard.** A mouse helps but isn't required.
- The node's **username and password**. If the node was sent to you, the sender gives you
  these, along with their `MY-NODE.md` file if they have one. Without the username and
  password there is no way in.
- Your **home Wi-Fi name and password**.
- Your everyday computer, with this repository cloned on it. Copy `MY-NODE.template.md` to
  `MY-NODE.md` if you don't have one yet, and write the username, password and Wi-Fi details
  in as you go. It is gitignored; that is where these facts belong.

**Skip straight to part B if nothing about the node changed and only your computer is new.**

## Before the node moves (if you're the one packing it)

Shut it down cleanly rather than pulling the plug: `ssh <username>@<address> 'sudo poweroff'`,
wait for the light to go out. (`node-skills/node-off` walks through it.) Pack the power supply
with it. If it is going to someone else, send them the username, the password and your
`MY-NODE.md`, by any private route you like. Do not send the cluster secret; it is already on
the node and they don't need it.

## Part A — at the node: give it the Wi-Fi

1. Connect the screen to the micro-HDMI port nearest the power socket, plug in the keyboard,
   and plug in power **last**. There is no power button.

   **You should see:** a boot screen, then the desktop with a bar along the top. If a login
   box appears first, type the username and password.
2. Click the **network icon** near the right end of the top bar, beside the clock. A list of
   nearby Wi-Fi networks drops down. Click yours, type its password in the box that appears,
   and confirm.

   **You should see:** the icon turn into Wi-Fi bars within a few seconds.

   If the menu doesn't look like that, use the terminal instead; it is the more reliable of
   the two. Open it with the black monitor icon in the top bar and type, with your own
   network name and password inside the quotes:

   ```
   sudo nmcli device wifi connect "<home Wi-Fi name>" password "<home Wi-Fi password>"
   ```

   **You should see:** a line ending `successfully activated`. `No network with SSID` means
   the name was mistyped (capitals matter), or the network is 5 GHz-only and the node is too
   far from the router; move it closer or use the 2.4 GHz network's name.

   The node still remembers its old network. That is harmless; it joins whichever one it can
   see.
3. In the terminal, type `hostname -I`. The answer holds two or three items. **You want the
   short one with dots**, like `192.168.1.42`; the long ones full of colons are a different
   kind of address this guide doesn't use. Write it into `MY-NODE.md`, replacing the old
   address. Empty output means the Wi-Fi didn't take; back to step 2.
4. Leave the screen and keyboard plugged in until part B works. They are your fallback.

## Part B — from your computer: get in

5. **Same computer you used before:** in your terminal, `ssh <username>@<address>` with the new
   address. If it logs you in without asking for a password, your key still works. Go to
   part C.

   If instead it refuses with a warning that the **host identification has changed**, the new
   network has handed the node an address that some other machine used before, and your
   computer remembers the other machine. Run `ssh-keygen -R <address>` and try again.
6. **A computer that has never talked to this node:** `ssh <username>@<address>` → type `yes`
   when asked about the host key → type the password.

   **You should see:** a prompt reading `<username>@<node name>`. You're on your node. Type
   `exit`.

   `Connection closed by <address> port 22` with no password prompt means the node is still
   finishing its boot. Wait a minute and run the same command again.
7. Install this computer's key so it never asks for the password again:

   - **Windows:**

     ```powershell
     type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh <username>@<address> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
     ```

   - **Mac/Linux:**

     ```
     ssh-copy-id <username>@<address>
     ```

   Type the password once more. (No key yet? Make one first with `ssh-keygen -t ed25519`,
   accepting the defaults.) Any computer that had a key before keeps working; the node's list
   of trusted computers just got one longer.
8. Verify: `ssh <username>@<address> hostname` prints the node's name with **no password
   prompt**. The screen and keyboard can come off now.

## Part C — is it back in the consortium?

Give the node **five minutes** from the moment the Wi-Fi came up before reading any of this
as a verdict. It has no battery clock, so its first minute online is spent finding out what
time it is, and the cluster takes a few minutes more to find the others.

9. Both services running:

   ```
   ssh <username>@<address> 'systemctl is-active ipfs ipfs-cluster'
   ```

   **You should see:** `active` twice.
10. Internet, not just Wi-Fi:

    ```
    ssh <username>@<address> 'ipfs swarm peers | wc -l'
    ```

    **You should see:** dozens to hundreds. A handful in the first minute is normal. Zero after
    five minutes means the node has Wi-Fi but no internet, which is the router's or the
    ISP's doing, not the node's; check that a phone on the same Wi-Fi can browse.
11. **Membership. This is the one that matters.**

    ```
    ssh <username>@<address> 'ipfs-cluster-ctl peers ls | head -3'
    ```

    **You should see:** the node's own name, then a line saying it **sees N other peers**,
    with N of at least 1.

    If it sees nobody after five minutes: restart the cluster service once
    (`sudo systemctl restart ipfs-cluster`), wait two more minutes, look again. Still nobody:
    stop here and use `node-skills/node-doctor`, part D, which walks the causes in order.
    Capture the exact output first.
12. Data catching up:

    ```
    ssh <username>@<address> 'ipfs-cluster-ctl status | head -20'
    ```

    **You should see:** rows marked `PINNED`, or `PINNING` for anything rescued while the
    node was away. `UNPINNED` right after a restart clears within a minute; a single
    `UNEXPECTEDLY_UNPINNED` can take up to twelve minutes for the cluster's own repair pass.
    Both look like data loss and are not.

**Your node is reconnected.** It is back in the consortium, it is catching up on whatever was
rescued while it was in a box, and it again needs nothing from you.

## Afterwards

- Write the date and what happened in the **Notes** section of `MY-NODE.md`, including what
  kind of move it was (home to home, workshop to home). The consortium's retention study
  lives on that detail.
- If any step above didn't match what you saw, please open an issue. This chapter is waiting
  for exactly that.
- If the node was an **anchor** at its old address, the port forwarding has to be redone on
  the new router (`35-meeting-point.md`). The anchor registry needs no change; it names your
  node by its identity, not its address.
