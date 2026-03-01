param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Apply","Rollback","Status")]
    [string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -------------------------------------------------------------------
# KORSiOS Tweaks — ScriptTweak autonome (snapshot local + rollback dédié)
# ID   : Power_plan
# Title: KORSiOS - [Alimentation] • Plan • KORSiOS High Performance
#
# Objectif:
# - Apply    : créer (si besoin) + activer un plan "KORSiOS High Performance"
# - Rollback : restaurer EXACTEMENT le plan actif avant Apply, et supprimer
#              le plan KORSiOS uniquement s'il a été créé par ce tweak
# - Status   : renvoyer ACTIVE / PRESENT / ABSENT
#
# Backup:
# - %LOCALAPPDATA%\KORSiOS\TweakBackups\POWER_PLAN\backup.json
# -------------------------------------------------------------------

# -------- Helpers --------
function Write-Ok($m){ Write-Host "[OK] $m" }
function Write-Info($m){ Write-Host "[INFO] $m" }
function Write-Warn($m){ Write-Warning $m }

function Ensure-Admin {
    $wi = [Security.Principal.WindowsIdentity]::GetCurrent()
    $wp = New-Object Security.Principal.WindowsPrincipal($wi)
    if (-not $wp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Admin rights required."
    }
}

$Base = Join-Path $env:LOCALAPPDATA "KORSiOS\TweakBackups\POWER_PLAN"
$BackupJson = Join-Path $Base "backup.json"

function Ensure-Folder([string]$path){
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -Force -ItemType Directory -Path $path | Out-Null
    }
}

function Get-ActiveSchemeGuid {
    $out = powercfg /getactivescheme 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    $m = [regex]::Match(($out -join "`n"), "([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})")
    if ($m.Success) { return $m.Groups[1].Value.ToLowerInvariant() }
    return $null
}

function Find-SchemeByName([string]$name) {
    $out = powercfg /list 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    foreach ($line in $out) {
        if ($line -match "([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}).+\((.+)\)") {
            $guid = $Matches[1].ToLowerInvariant()
            $n = $Matches[2].Trim()
            if ($n -ieq $name) { return $guid }
        }
    }
    return $null
}

function Backup-Once([hashtable]$state){
    # Snapshot local : on ne re-snapshot pas si déjà présent (modèle OneDrive)
    if (Test-Path -LiteralPath $BackupJson) { return }

    Ensure-Folder $Base
    ([ordered]$state | ConvertTo-Json -Depth 6) | Out-File -FilePath $BackupJson -Encoding UTF8
}

function Load-Backup {
    if (-not (Test-Path -LiteralPath $BackupJson)) { return $null }
    return (Get-Content $BackupJson -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Apply {
    $planName = "KORSiOS High Performance"
    $activeBefore = Get-ActiveSchemeGuid
    if (-not $activeBefore) { throw "Unable to read active power scheme (powercfg /getactivescheme)." }

    $existingGuid = Find-SchemeByName $planName

    $createdNew = $false
    $planGuid = $existingGuid

    if (-not $existingGuid) {
        # Duplicate the built-in "High performance" plan (SCHEME_MIN)
        $baseHighPerf = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        $dup = powercfg /duplicatescheme $baseHighPerf 2>$null
        if ($LASTEXITCODE -ne 0) { throw "Failed: powercfg /duplicatescheme (High performance)." }

        $m = [regex]::Match(($dup -join "`n"), "([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})")
        if (-not $m.Success) { throw "Unable to parse duplicated scheme GUID." }
        $planGuid = $m.Groups[1].Value.ToLowerInvariant()

        powercfg /changename $planGuid $planName 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Failed: powercfg /changename." }

        $createdNew = $true
        Write-Info "Created scheme: $planGuid ($planName)"
    } else {
        Write-Info "Scheme already exists: $planGuid ($planName)"
    }

    # Snapshot local (rollback exact)
    $state = @{
        created   = (Get-Date).ToString("s")
        activeBefore = $activeBefore
        planName  = $planName
        planGuid  = $planGuid
        createdNew = $createdNew
    }
    Backup-Once -state $state

    powercfg /setactive $planGuid 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Failed: powercfg /setactive." }

    Write-Ok "Applied. Active scheme is now: $planGuid"
}

function Rollback {
    $backup = Load-Backup
    if (-not $backup) { throw "No backup found: $BackupJson" }

    $activeBefore = $backup.activeBefore
    $planGuid     = $backup.planGuid
    $createdNew   = [bool]$backup.createdNew

    if ($activeBefore) {
        powercfg /setactive $activeBefore 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Failed: powercfg /setactive (restore previous scheme)." }
        Write-Ok "Restored previous active scheme: $activeBefore"
    } else {
        # Fallback (shouldn't happen if Apply succeeded)
        $balanced = "381b4222-f694-41f0-9685-ff5bb260df2e" # SCHEME_BALANCED
        powercfg /setactive $balanced 2>$null | Out-Null
        Write-Warn "Previous active scheme missing in backup. Activated Balanced."
    }

    if ($createdNew -and $planGuid) {
        powercfg /delete $planGuid 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Deleted scheme created by tweak: $planGuid"
        } else {
            Write-Warn "Could not delete scheme $planGuid (may be already removed)."
        }
    } else {
        Write-Info "No scheme deletion (plan existed before Apply)."
    }
}

function Status {
    $planName = "KORSiOS High Performance"
    $guid = Find-SchemeByName $planName
    if (-not $guid) {
        Write-Output "ABSENT"
        return
    }
    $active = Get-ActiveSchemeGuid
    if ($active -and ($active -eq $guid)) {
        Write-Output "ACTIVE"
    } else {
        Write-Output "PRESENT"
    }
}

# -------- Main --------
try {
    if ($Mode -eq "Status") { Status; exit 0 }

    Ensure-Admin

    if ($Mode -eq "Apply")    { Apply; exit 0 }
    if ($Mode -eq "Rollback") { Rollback; exit 0 }

    throw "Unknown Mode: $Mode"
}
catch {
    Write-Error $_
    exit 1
}
