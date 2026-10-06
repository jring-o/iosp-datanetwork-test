# set_secret.ps1 - put the cluster secret into a laptop member's service.json (Windows).
# The Windows twin of set_secret.sh. The person runs it in their own PowerShell window:
#   powershell -ExecutionPolicy Bypass -File <kit folder>\ops\set_secret.ps1
# The secret is typed or pasted at a hidden prompt. It is never echoed, never passed as a
# command-line argument, and never written anywhere except service.json.
# With input redirected, it reads the first line instead (for machine-to-machine use).
# Only the "secret" value inside the file changes; everything else stays byte for byte.

$ErrorActionPreference = 'Stop'

$dir = $env:IPFS_CLUSTER_PATH
if (-not $dir) { $dir = Join-Path $env:USERPROFILE '.ipfs-cluster' }
$cfg = Join-Path $dir 'service.json'
if (-not (Test-Path -LiteralPath $cfg)) {
    Write-Output "no $cfg (run ipfs-cluster-service init first)"
    exit 1
}

if ([Console]::IsInputRedirected) {
    $secret = [Console]::In.ReadLine()
    if ($null -eq $secret) { $secret = '' }
} else {
    $secure = Read-Host -AsSecureString -Prompt 'Paste the cluster secret and press Enter (it stays hidden)'
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $secret = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}
$secret = $secret.Trim()

if ($secret -notmatch '^[0-9a-fA-F]{64}$') {
    Write-Output ("That does not look like a cluster secret: expected 64 hexadecimal characters, got {0} character(s). Nothing changed." -f $secret.Length)
    exit 2
}
$secret = $secret.ToLowerInvariant()

$text = [IO.File]::ReadAllText($cfg)
$pattern = '("secret"\s*:\s*")[0-9a-fA-F]*(")'
$found = [regex]::Matches($text, $pattern).Count
if ($found -ne 1) {
    Write-Output "Expected exactly one secret field in $cfg, found $found. Nothing changed."
    exit 3
}
$newText = [regex]::Replace($text, $pattern, '${1}' + $secret + '${2}')

try { $parsed = $newText | ConvertFrom-Json }
catch {
    Write-Output "The edited file would not be valid JSON. Nothing changed."
    exit 3
}
if ($parsed.cluster.secret -ne $secret) {
    Write-Output "The secret did not land in the cluster section. Nothing changed."
    exit 3
}

# UTF-8 without a byte-order mark: the cluster program refuses a file that starts with one.
[IO.File]::WriteAllText($cfg, $newText, (New-Object Text.UTF8Encoding($false)))
$secret = $null
Write-Output ("Secret set (64 characters). Cluster name is: " + $parsed.consensus.crdt.cluster_name)
