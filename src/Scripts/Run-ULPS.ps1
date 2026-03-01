param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Apply","Rollback","Status")]
    [string]$Mode = "Apply",

    # Optional: enable deeper traversal under known AMD roots (still NOT a full HKLM:\SYSTEM recurse).
    [switch]$DeepScan
)

# -----------------------------------------
# KORSiOS - AMD ULPS (Hybrid, "beton" build)
# -----------------------------------------
# Self-contained (no .psm1 required).
# Scans a broader set of known locations (CurrentControlSet + ControlSet001/002)
# while avoiding dangerous/slow full registry recursion.
#
# KORSiOS requirements (important):
# - ULPS must remain autonomous with dedicated local snapshot + rollback.
# - No global registry-state system. No global snapshot/rollback.
#
# Exit codes (expected by KORSiOS):
# 0    = OK (aucun changement / déjà appliqué)
# 3010 = Appliqué / Rollback effectué (redémarrage recommandé)
# 2    = Rollback impossible (backup introuvable)
# 5    = Admin requis

# ----------------- Helpers -----------------
function Test-IsAdmin {
    try {
        $current = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($current)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Ensure-Dir([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Get-DwordValueSafe([string]$keyPath, [string]$valueName) {
    try {
        $props = Get-ItemProperty -LiteralPath $keyPath -ErrorAction Stop
        $p = $props.PSObject.Properties[$valueName]
        if ($null -eq $p) { return $null }
        return [int]($props.$valueName)
    } catch {
        return $null
    }
}

function Set-Dword([string]$keyPath, [string]$valueName, [int]$value) {
    try {
        $cur = Get-DwordValueSafe $keyPath $valueName
        if ($null -ne $cur -and $cur -eq $value) { return $false }

        # Try Set-ItemProperty first (fastest)
        Set-ItemProperty -LiteralPath $keyPath -Name $valueName -Value $value -Type DWord -ErrorAction Stop
        return $true
    } catch {
        # Fallback: create property if missing
        try {
            New-ItemProperty -LiteralPath $keyPath -Name $valueName -Value $value -PropertyType DWord -Force -ErrorAction Stop | Out-Null
            return $true
        } catch {
            return $false
        }
    }
}

# ----------------- Safety -----------------
if (-not (Test-IsAdmin)) { exit 5 }

# ----------------- Snapshot local (KORSiOS standard) -----------------
# Dedicated local snapshot to match the "OneDrive" rollback style.
$BackupDir  = Join-Path $env:LOCALAPPDATA "KORSiOS\TweakBackups\ULPS"
$BackupFile = Join-Path $BackupDir "backup.json"

function Backup-Exists {
    return (Test-Path -LiteralPath $BackupFile)
}

function Save-Backup([object]$entries) {
    Ensure-Dir $BackupDir
    $payload = [pscustomobject]@{
        Version   = 3
        CreatedAt = (Get-Date).ToString("s")
        DeepScan  = [bool]$DeepScan
        Entries   = $entries
    }
    $payload | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $BackupFile -Encoding UTF8
}

function Load-Backup {
    if (-not (Test-Path -LiteralPath $BackupFile)) { return $null }
    try {
        (Get-Content -LiteralPath $BackupFile -Raw -Encoding UTF8) | ConvertFrom-Json
    } catch {
        return $null
    }
}

# ----------------- Scan logic -----------------
$valueNames = @("EnableUlps","EnableUlps_NA")

# Known AMD registry roots (broader coverage than the minimal version)
$roots = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}",
    "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}",
    "HKLM:\SYSTEM\ControlSet002\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Video",
    "HKLM:\SYSTEM\ControlSet001\Control\Video",
    "HKLM:\SYSTEM\ControlSet002\Control\Video"
)

function Probe-Key([string]$keyPath, [System.Collections.Generic.List[object]]$entries) {
    foreach ($vn in $valueNames) {
        $val = Get-DwordValueSafe $keyPath $vn
        if ($null -ne $val) {
            $entries.Add([pscustomobject]@{
                KeyPath   = $keyPath
                ValueName = $vn
                Kind      = "DWord"
                Value     = [int]$val
            }) | Out-Null
        }
    }
}

function Enumerate-Children([string]$baseKey, [int]$depth, [System.Collections.Generic.List[string]]$outList) {
    if ($depth -le 0) { return }
    try {
        Get-ChildItem -LiteralPath $baseKey -ErrorAction SilentlyContinue | ForEach-Object {
            $p = $_.PSPath
            $outList.Add($p) | Out-Null
            Enumerate-Children $p ($depth - 1) $outList
        }
    } catch { }
}

function Get-UlpsEntries {
    $entries = New-Object System.Collections.Generic.List[object]

    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }

        # Depth strategy:
        # - Class GUID root: usually values on immediate children (0000,0001...), sometimes deeper (0000\UMD)
        # - Video root: typically Video\{GUID}\0000, sometimes a level deeper
        # We'll use depth=3 when DeepScan is enabled; otherwise a conservative depth=2.
        $maxDepth = 2
        if ($DeepScan) { $maxDepth = 3 }

        $toProbe = New-Object System.Collections.Generic.List[string]
        $toProbe.Add($root) | Out-Null
        Enumerate-Children $root $maxDepth $toProbe

        foreach ($k in $toProbe) {
            Probe-Key $k $entries
        }
    }

    # De-duplicate entries (same key/value could be found multiple times through enumeration lists)
    $seen = @{}
    $unique = New-Object System.Collections.Generic.List[object]
    foreach ($e in $entries) {
        $id = "$($e.KeyPath)|$($e.ValueName)"
        if (-not $seen.ContainsKey($id)) {
            $seen[$id] = $true
            $unique.Add($e) | Out-Null
        }
    }
    return $unique
}

# ----------------- Execution -----------------
switch ($Mode) {
    "Apply" {
        $entries = Get-UlpsEntries
        if ($entries.Count -eq 0) { exit 0 }

        # Snapshot BEFORE changing anything (only once).
        # If already present, keep the original baseline to ensure accurate rollback.
        if (-not (Backup-Exists)) {
            Save-Backup $entries
        }

        $changed = $false
        foreach ($e in $entries) {
            if (Set-Dword $e.KeyPath $e.ValueName 0) { $changed = $true }
        }

        if ($changed) { exit 3010 } else { exit 0 }
    }

    "Rollback" {
        $backup = Load-Backup
        if ($null -eq $backup -or $null -eq $backup.Entries) { exit 2 }

        $changed = $false
        foreach ($e in $backup.Entries) {
            if ($e.ValueName -in $valueNames) {
                if (Set-Dword $e.KeyPath $e.ValueName ([int]$e.Value)) { $changed = $true }
            }
        }

        # Clear snapshot to allow a clean baseline next time
        try {
            if (Test-Path -LiteralPath $BackupFile) { Remove-Item -LiteralPath $BackupFile -Force -ErrorAction SilentlyContinue }
        } catch { }

        if ($changed) { exit 3010 } else { exit 0 }
    }

    "Status" {
        $entries = Get-UlpsEntries
        $payload = [pscustomobject]@{
            HasBackup      = [bool](Backup-Exists)
            BackupPath     = $BackupFile
            DetectedValues = [int]$entries.Count
            DeepScan       = [bool]$DeepScan
        }
        $payload | ConvertTo-Json -Depth 4
        exit 0
    }
}
