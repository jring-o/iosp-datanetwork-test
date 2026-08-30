#!/bin/bash
# set_secret.sh — put the cluster secret into ~/.ipfs-cluster/service.json.
# The secret arrives on standard input only. It is never echoed, never passed as a
# command-line argument, never written anywhere except service.json.
set -e
CFG="${IPFS_CLUSTER_PATH:-$HOME/.ipfs-cluster}/service.json"
if [ ! -f "$CFG" ]; then echo "no $CFG (run ipfs-cluster-service init first)"; exit 1; fi
if [ -t 0 ]; then
  read -rs -p "Paste the cluster secret and press Enter (nothing appears as you type): " SECRET
  echo
else
  IFS= read -r SECRET
fi
printf '%s' "$SECRET" | python3 -c '
import json, re, sys
s = sys.stdin.read().strip()
if not re.fullmatch(r"[0-9a-fA-F]{64}", s):
    print("That does not look like a cluster secret: expected 64 hexadecimal characters, got %d character(s). Nothing changed." % len(s))
    sys.exit(2)
cfg = sys.argv[1]
d = json.load(open(cfg))
d["cluster"]["secret"] = s.lower()
json.dump(d, open(cfg, "w"), indent=2)
print("Secret set (64 characters). Cluster name is: " + d["consensus"]["crdt"]["cluster_name"])
' "$CFG"
chmod 600 "$CFG"
