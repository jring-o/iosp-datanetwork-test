# 10 — First boot: wizard, remote access, retire the monitor

**You start with:** the Pi booting to its setup wizard (from `00-hardware.md`), and your
everyday computer on the same Wi-Fi network.
**You end with:** a headless node (no screen or keyboard attached) that you and your agent
reach from your everyday computer over SSH with a key, no password typing.

**Time:** ~45–60 minutes, most of it waiting for updates. *(Measured once, node-00,
2026-07-30, on fast home bandwidth: wizard + updates ~25 min, rename + reboot ~5 min,
finding the node + SSH setup ~15 min.)*

**"Your everyday computer"** means the machine you will actually use to look after this node
from now on: laptop or desktop, Windows, Mac or Linux, whichever you normally sit at. It
matters which one you pick, because the key that unlocks the node without a password gets
installed on that machine in section D. You can add a second machine later, but start with
the one you'll really use.

**Before the wizard, one minute at that computer:** in your clone of this repository, copy
`MY-NODE.template.md` to `MY-NODE.md`. This chapter and the next ones produce facts (your
username, the node's name and address, its permanent identities) that you record there as
they appear. Your assistant reads that file instead of guessing, and you will want it
yourself in six months. It never gets committed or shared; the template explains why.

The preloaded system is Raspberry Pi OS (Debian 13 "Trixie" generation). Menus in older
online tutorials look different; follow this document, not screenshots from the internet.

## A. The setup wizard (on the Pi, with keyboard and mouse)

**The pages come in this order** *(confirmed on node-01, 2026-08-12)*. If yours differ, the
OS has changed and this chapter needs updating:

> Welcome → Set Country → Create User → Wi-Fi (two pages) → Choose Browser → Updates → Finish

1. **Welcome to the Raspberry Pi Desktop.** Press **Next**. (It mentions putting Bluetooth
   keyboards and mice into pairing mode. Ignore that if yours are wired, which is what we
   recommend; see `00-hardware.md`.)
2. **Set Country:** pick your country, language, and timezone.

   The page also has two checkboxes, **"Use English language"** and **"Use US keyboard"**:

   - **"Use US keyboard"** — tick it only if the keyboard physically in front of you is a US
     layout. **This is the one that matters.** A wrong layout means the password you set on
     the next page is not the password you think you typed, and you find out much later when
     you can no longer log in. If your keyboard is Dutch, German, UK or anything else, leave
     it unticked and let your country choice pick the layout.
   - **"Use English language"** — cosmetic; it sets the desktop's language without changing
     your country or timezone. Tick it if you want the menus to match this English-language
     runbook, which makes the later Control Centre steps easier to follow.

   Next.
3. **Create user.** Pick any username you like; you will type it every time you talk to your
   node, so short and easy is good. The consortium's own reference nodes use `iosp`, but that
   is a convention, not a requirement: every command in this guide writes `<username>` where
   yours goes, and the skills read yours from `MY-NODE.md`. **Record the username in
   `MY-NODE.md` now, and the password with it.** The password is your fallback forever and
   the thing any new computer needs to get in. The wizard asks only for a username; the
   node gets its proper name in step B.
4. **Wi-Fi:** this is two pages, not one. First a list of the networks the Pi can see: pick
   your home network and press **Next**. Only then does a second page ask for that network's
   password: type it and press **Next** again. If you look for a password box on the first
   page you will not find one.
5. **Choose Browser:** Chromium or Firefox, and a checkbox offering to uninstall the one you
   don't pick.

   **Take Chromium and tick the uninstall box.** Neither choice matters for the node's job:
   it goes headless within the hour and will never open a browser again. Uninstalling the
   spare is worth doing anyway, because it's one less large package to download security
   updates for, every month, for the years this node is expected to run.

   Next.
6. **Updates:** let it check and install.

   **Expect the check to fail the first time.** It has done so on both nodes we have built,
   for two unrelated reasons, and both are cured by the same gesture. You will see one of:

   - *"error checking for updates"* with a repository **"not valid yet"** — the Pi has no
     battery-backed clock, so until it syncs the time the update server's signatures look
     invalid. **Wait two minutes** before retrying, so the clock can catch up.
   - *"error checking for updates"* with a repository that **"changed its 'Version' value"**
     and/or `Packages.diff/Index is not (yet) available` — your preloaded image is older
     than what the servers now carry. Nothing to wait for. This one becomes more likely the
     longer the kit sat in a warehouse before reaching you.

   **The fix for both: click OK, press Back, then Next.** One retry cleared it on node-01
   (2026-08-12). If a second retry also fails, press **Skip** and carry on. The update is
   not lost; you will run it from your everyday computer in `20-kubo.md`, where you can
   actually read the output.

   Installing took ~2 minutes on fast home bandwidth; budget more on slow networks.

   *Why the dialog is so unhelpful: it truncates, doesn't scroll properly, and can't be
   copied. Don't fight it; retry or skip.*
7. **Finish.** Three small things happen in a row:

   - The update ends with a **"System is up to date"** confirmation. Click **OK**.
   - The wizard's last page appears, offering **Back** and **Launch**. Press **Launch**.

   **You should see:** the Pi reboot once more and land on the desktop.

   That is the end of the wizard. You never see it again, on this node or after any future
   reboot.

## B. Name the node and switch on SSH (still on the Pi)

8. Raspberry menu (top-left) → **Preferences** → **Control Centre**.
9. **System** section → **Hostname**. This is four interactions, not one:

   - Click the **Change hostname** button. A popup opens asking you to enter a hostname.
   - Type your node's name (e.g. `node-07`). Any short name works; **record it in
     `MY-NODE.md`**.
   - Click **OK**.
   - A second popup says *"The hostname has been changed successfully and will take effect on
     the next reboot."* Click **OK**.

   **You should see:** both popups gone, and the row still reading **Change hostname**.
   Control Centre never displays the current hostname; the button keeps its label whether or
   not you have changed anything. There is no confirmation to look for here; you verify the
   name after the reboot in step 11.
10. **Interfaces** section → **SSH** → toggle **ON**.
11. Click **Close** (there is no OK/Apply) → it asks to reboot → yes. It reboots to the
    desktop. The screen and keyboard are now nearly done; leave them plugged for one more
    step in case of trouble, but you won't touch them again.

## C. Find the node from your everyday computer

Your node needs an **address**: the number your home network uses to reach it, the way a
street address reaches a house. You are about to read it off the Pi and record it.

12. On the Pi (the monitor and keyboard are still attached), open the terminal: the black
    monitor icon in the taskbar along the top of the screen. Then type:

    ```
    hostname -I
    ```

    **You should see:** one line holding two or three items separated by spaces, like:

    ```
    192.168.1.42 2001:db8:85a3::8a2e:370:7334 2001:db8:85a3:1:5f2c:9ab1:de04:22c7
    ```

    **You want the first item: `192.168.1.42`** — the short one, four numbers with dots between
    them. The long items full of colons are a different kind of address this guide doesn't
    use; ignore them. **Record the short one in `MY-NODE.md`**; every remaining step needs it.

13. *(Optional, skip if you like.)* Many networks also let you reach the node by name. From
    your everyday computer's terminal, `ping node-07.local` (your node's name + `.local`) may answer.
    **It fails on most VPNs** (NordVPN and friends intercept these lookups), and that failure
    means nothing is wrong. The address from step 12 always works; never build a habit on the
    name.
14. Confirm the SSH door is open, on your everyday computer (Windows shown; Mac: `nc -z <address> 22`):

    ```
    Test-NetConnection <address> -Port 22
    ```

    Expect `TcpTestSucceeded : True`.

## D. First login and the one-time key setup (on your everyday computer)

15. Log in as a human, using your username and the address from `MY-NODE.md`:

    ```
    ssh <username>@<address>
    ```

    **You should see:** a question about the authenticity of the host, quoting a fingerprint
    → type `yes`. Then `Warning: Permanently added …`, which is normal and means it will
    never ask again. Then a password prompt where **nothing appears as you type**. Then a
    prompt reading `<username>@node-07`. You are on your node. Look around; type `exit` to
    come back.

    **If instead you get `Connection closed by <address> port 22`** immediately after typing
    `yes`, with no password prompt: the Pi is still finishing its reboot. The network answers
    before the login service is ready, so the door looks open while nobody is behind it yet.
    **Wait about a minute and run the same command again.** Nothing is wrong and nothing needs
    fixing. (Seen on node-01, 2026-08-12; the identical command succeeded on the retry.)
16. Install that computer's key so future logins (yours and your agent's) need no password.
    - **Windows** (creates a key first only if you've never had one; if
      `type $env:USERPROFILE\.ssh\id_ed25519.pub` shows a line starting `ssh-ed25519`, you
      have one):

      ```powershell
      type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh <username>@<address> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
      ```

    - **Mac/Linux:**

      ```
      ssh-copy-id <username>@<address>
      ```

    Type the password once more. (No key yet? Make one first: `ssh-keygen -t ed25519`,
    accept the defaults.)
17. Verify the key works; this must log you in with **no password prompt**:

    ```
    ssh <username>@<address>
    ```

18. Done: unplug the monitor, keyboard and mouse. The node now runs headless; everything from
    here on happens from your everyday computer. Fill in `MY-NODE.md`'s build date and
    hardware rows while it's all fresh (the drive model comes from the machine in the next
    chapter, not from the box). → Continue to `20-kubo.md`.
