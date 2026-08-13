#!/usr/bin/env python3
"""Refresh the cluster peerstore with meeting points' current addresses.

Meeting points are identified by permanent Kubo peer IDs (no DNS anywhere).
For each one: ask the public DHT via local Kubo (routing findpeer), extract
public IPv4 addrs, write /ip4/<ip>/tcp/<port>/p2p/<cluster_id> entries into
the cluster peerstore. Existing entries are kept when lookup fails, so
cached addresses remain the first fallback. Runs before ipfs-cluster starts.

Two-clusters aware (2026-07-30): registry entries carry "cluster" + "port";
only entries matching IOSP_CLUSTER (default iosp-nodes) are resolved, so the
same script serves a Pi (defaults), a laptop member (IOSP_CLUSTER=iosp-laptops
+ IOSP_PEERSTORE to its path), or node-00 (runs it once per instance;
self-skip makes the entry for its own role a no-op).
"""
import json
import os
import re
import subprocess

# Defaults derive from the running user and this file's own location, so no
# particular username is assumed anywhere (usernames vary across nodes).
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MP_FILE = os.environ.get("IOSP_MP_FILE", os.path.join(_SCRIPT_DIR, "meeting-points.json"))
PEERSTORE = os.environ.get(
    "IOSP_PEERSTORE", os.path.join(os.path.expanduser("~"), ".ipfs-cluster", "peerstore")
)
CLUSTER = os.environ.get("IOSP_CLUSTER", "iosp-nodes")
PRIVATE = re.compile(r"^/ip4/(10\.|127\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|169\.254\.)")


def sh(args, timeout=90):
    try:
        r = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
        return r.returncode, r.stdout
    except Exception:
        return 1, ""


def main():
    if not os.path.exists(MP_FILE):
        print("no meeting-points.json; nothing to do")
        return
    with open(MP_FILE) as f:
        mps = json.load(f)
    _, me = sh(["ipfs", "id", "-f", "<id>"])
    me = me.strip()

    lines = []
    if os.path.exists(PEERSTORE):
        with open(PEERSTORE) as f:
            lines = [l.strip() for l in f if l.strip()]

    for mp in mps:
        name = mp["name"]
        kubo_id = mp["kubo_id"]
        cluster_id = mp["cluster_id"]
        port = str(mp.get("port", 9096))
        if mp.get("cluster", "iosp-nodes") != CLUSTER:
            continue
        if kubo_id == me:
            print(name + ": this node is the meeting point - skip")
            continue
        rc, out = sh(["ipfs", "routing", "findpeer", kubo_id], timeout=120)
        ips = []
        for a in out.splitlines():
            a = a.strip()
            m = re.match(r"^/ip4/([0-9.]+)/", a)
            if m and not PRIVATE.match(a):
                ips.append(m.group(1))
        ips = list(dict.fromkeys(ips))
        if rc != 0 or not ips:
            print(name + ": lookup failed; keeping cached entries")
            continue
        # Refresh this peer's PUBLIC entries, but never discard private/LAN ones.
        # Two nodes in one household (or a whole workshop room behind one router)
        # usually cannot reach each other via the public address — hairpin NAT is
        # not supported by many home gateways; measured failing on Xfinity xFi,
        # 2026-08-12, node-01 -> node-00. The LAN address is the only route that
        # works there, so keeping it is what makes a same-network bootstrap
        # possible without relying on mDNS or on the cluster daemon happening to
        # have persisted it. Stale LAN entries after a move are harmless: the dial
        # simply fails and the public entry is tried next.
        lines = [l for l in lines if cluster_id not in l or PRIVATE.match(l)]
        lines += ["/ip4/" + ip + "/tcp/" + port + "/p2p/" + cluster_id for ip in ips]
        lines = list(dict.fromkeys(lines))
        print(name + ": resolved -> " + ", ".join(ips))

    tmp = PEERSTORE + ".tmp"
    with open(tmp, "w") as f:
        f.write("\n".join(lines) + ("\n" if lines else ""))
    os.replace(tmp, PEERSTORE)
    print("peerstore written: " + str(len(lines)) + " entries")


if __name__ == "__main__":
    main()
