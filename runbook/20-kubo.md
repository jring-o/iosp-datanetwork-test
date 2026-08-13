# 20 — Kubo: turn the Pi into an IPFS node

**You start with:** a headless node you (and your agent) reach by key-based SSH
(from `10-first-boot.md`).
**You end with:** Kubo (the IPFS program) installed, running as a background service that
starts itself on every boot, connected to the public IPFS network.
**Time:** ~5 minutes. *(Measured on node-00, 2026-07-30: 3 minutes including the reboot
test, on fast home bandwidth.)*

Every command below runs on the node, either inside an SSH session or wrapped as
`ssh <username>@<address> '<command>'` by you or your agent. Your username and address are
in `MY-NODE.md`; substitute them wherever you see the angle brackets.

## Steps

1. Find the newest stable version (skip any `-rc` test versions):

   ```
   curl -s https://dist.ipfs.tech/kubo/versions | grep -v "\-rc" | tail -1
   ```

   This guide was performed with `v0.42.0`; substitute the version you got.

2. Download and install:

   ```
   cd /tmp
   wget -q https://dist.ipfs.tech/kubo/v0.42.0/kubo_v0.42.0_linux-arm64.tar.gz
   tar xzf kubo_v0.42.0_linux-arm64.tar.gz
   sudo bash kubo/install.sh
   ipfs --version
   ```

   Expect: `Moved kubo/ipfs to /usr/local/bin` and `ipfs version 0.42.0`.

3. Create the node's IPFS identity and storage. On this hardware the entire system lives on
   the SSD, so the IPFS storage (the `.ipfs` folder in your home directory) is automatically
   on fast, large storage; no extra step:

   ```
   ipfs init
   ```

   Expect `generating ED25519 keypair...done` and a line `peer identity: 12D3KooW...`.
   **Record that peer identity in `MY-NODE.md`.** It is your node's permanent public name on
   the IPFS network: safe to share, an ID rather than a secret, and it never changes.

   Then set the archive budget. **Kubo defaults to a 10GB storage budget no matter how big
   the drive is**: left alone, a 512GB node tells the cluster it has ~10GB of room
   (caught on node-00, 2026-07-30, months after install would have been too late):

   ```
   ipfs config Datastore.StorageMax 400GB
   ```

   Rule of thumb: ~80% of the drive's free space, leaving room for the OS and overhead
   (400GB on the 512GB kit; scale for your drive). **Record the budget in `MY-NODE.md`.**

4. Install the service so the daemon runs always and returns after every power cut.
   **Replace `<username>` in both places before running** (or have your agent do it,
   reading the value from `MY-NODE.md`):

   ```
   printf '[Unit]\nDescription=IPFS daemon (Kubo)\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nUser=<username>\nEnvironment=IPFS_PATH=/home/<username>/.ipfs\nExecStart=/usr/local/bin/ipfs daemon\nRestart=on-failure\nRestartSec=10\n\n[Install]\nWantedBy=multi-user.target\n' | sudo tee /etc/systemd/system/ipfs.service > /dev/null
   sudo systemctl daemon-reload
   sudo systemctl enable --now ipfs
   ```

   Expect a `Created symlink ...` line.

5. Verify it's alive and connected (give it ~30 seconds first):

   ```
   systemctl is-active ipfs
   ipfs swarm peers | wc -l
   ```

   Expect `active`, and a peer count in the dozens to hundreds: those are live connections
   to other IPFS nodes worldwide.

6. Prove it survives a reboot; this is the property that matters for the months ahead:

   ```
   sudo reboot
   ```

   Wait a minute, SSH back in, and repeat step 5. Expect `active` and a healthy peer count
   with no human having touched anything.

→ Continue to `25-watchdog.md` — the self-healing watchdog every node runs.
