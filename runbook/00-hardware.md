# 00 — Hardware: what to buy, unbox, hook up

## What a consortium node needs

Any kit meeting all of these works. The requirements are load-bearing; each one closes a
known failure:

- **Raspberry Pi 5 with 8GB of memory.** The archive software (Kubo) needs about 6GB to run
  well; the 4GB model is below that floor, and it fails silently: the node looks alive while
  its data becomes unreachable.
- **Storage on a real SSD, never a microSD card.** The software writes constantly, and
  consumer microSD cards die under that load within months. This is the classic way an
  unattended Pi dies.
- **256GB of storage is comfortable.** Typical rescued datasets are megabytes to gigabytes;
  a 256GB node holds thousands of them. Bigger is fine.
- **The official 27W USB-C power supply** and a case with active cooling.
- **It must arrive assembled, with Raspberry Pi OS preinstalled on the drive.** This guide
  starts at a machine that boots; it does not cover installing an operating system, because
  we have never had to perform that step. Kits sold as complete desktop bundles ship this way.
- Wi-Fi is assumed throughout. If you can run an Ethernet cable to your router instead, do:
  it removes the most common failure the watchdog exists to fix.

The build this guide was performed and measured on is the CanaKit **"Raspberry Pi 5 Desktop
PC with SSD"** bundle (Pi 5 8GB, NVMe SSD preloaded with Pi OS, case, cooler, power supply).
It is the reference, not a rule. A different kit that meets the list above joins the same
path at the Welcome wizard below; only the unboxing details differ.

## What you must have ready (the kit does not include these)

1. A monitor or TV with an HDMI input
2. A USB keyboard
3. A USB mouse — **required, not optional**: the setup wizard and Control Centre are
   point-and-click
4. Your home Wi-Fi name and password

**Wired USB, not Bluetooth.** The first wizard screen offers to pair Bluetooth keyboards and
mice, and it can work. But if pairing fails you have no way to type, and typing is what you
would need to fix it. If Bluetooth is genuinely all you own, put the devices in pairing mode
at that welcome screen, wait for them to connect, and borrow a wired set as backup.

**You start with:** the sealed kit plus the four things above.
**You end with:** the assembled Pi connected to screen, keyboard, mouse, and power, booting.
**Time:** ~10–15 minutes. *(Measured once, node-00, 2026-07-30.)*

## What's in the box (the reference kit; check it)

- The assembled unit: Raspberry Pi 5 (8GB) in the black Turbine case, with the NVMe SSD and
  cooler already installed. You never open the case.
- USB-C power supply (45W)
- 2× video cables: micro-HDMI (small end) to HDMI (regular end), 6 ft

Not included, on purpose, and not needed: no ethernet cable (Wi-Fi works), no
keyboard, mouse, or monitor (borrowed ones are needed only for the first session).

## Steps

1. Place the unit where it can reach your screen and a power outlet. It's silent and small;
   anywhere works.
2. Connect a video cable: **small end into the Pi's micro-HDMI port nearest the USB-C power
   socket**, regular end into your monitor or TV. Switch the display to that input.
3. Plug the USB keyboard into the Pi. Any port is fine.
4. Plug the USB mouse into the Pi. Any port is fine.
5. Plug the power supply into the wall, then its USB-C end into the Pi: **power goes in
   last**. There is no power button; plugging in IS turning on.
6. **What you should see, in this order; do not unplug at any point:**
   a. A boot screen (raspberries in the corner, scrolling text).
   b. Things load and move.
   c. **The screen goes black.** This is normal.
   d. A second boot screen — the Pi restarts itself once on its very first power-up.
   e. **The screen goes black again.** Also normal.
   f. The **Welcome wizard** appears. This is your destination.

   The two black screens are the step people misread as a dead unit. The whole sequence takes
   a couple of minutes on first power-up. *(Sequence observed on node-01, 2026-08-12; node-00's
   log recorded only "boot sequence, then wizard", which understated it.)*

   **If you reach the Welcome wizard → continue to `10-first-boot.md`.** If the screen is
   still black after five minutes with no second boot screen, check that the display is on
   the right HDMI input and that you used the micro-HDMI port nearest the power socket.

→ Continue to `10-first-boot.md`.
