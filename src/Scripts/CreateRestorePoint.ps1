# ==========================================================
# KORSiOS Tweaks - Create System Restore Point
# File: Assets\Scripts\Tweaks\CreateRestorePoint.ps1
# ==========================================================

param(
    [string]$BaseName = "KORSiOS Tweaks",
    [string]$CustomName = "",
    [string]$OutFile = ""
)

function Test-IsAdmin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Write-ResultName([string]$name) {
    if (-not [string]::IsNullOrWhiteSpace($OutFile)) {
        try {
            $dir = Split-Path -Parent $OutFile
            if (-not [string]::IsNullOrWhiteSpace($dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            Set-Content -Path $OutFile -Value $name -Encoding UTF8
        } catch {
            # ignore
        }
    }

    # Also emit a pipeline-friendly line (do NOT use Write-Host)
    Write-Output ("RESTOREPOINT_NAME=" + $name)
}

if (-not (Test-IsAdmin)) {
    Write-Output "ERROR: Administrator rights are required to create a system restore point."
    exit 5
}

$srKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
$srName = "SystemRestorePointCreationFrequency"

$hadValue = $false
$oldValue = $null

# Save existing frequency value if present
try {
    $prop = Get-ItemProperty -Path $srKey -Name $srName -ErrorAction Stop
    $hadValue = $true
    $oldValue = [int]$prop.$srName
} catch {
    $hadValue = $false
}

# Ensure base name
if ([string]::IsNullOrWhiteSpace($BaseName)) {
    $BaseName = "KORSiOS Tweaks"
}

# Determine next index (KORSiOS Tweaks 1 / 2 / 3...)
$existing = @()
try {
    $existing = Get-ComputerRestorePoint -ErrorAction Stop
} catch {
    $existing = @()
}

$maxIndex = 0
foreach ($rp in $existing) {
    if ($null -eq $rp.Description) { continue }

    # Match "KORSiOS Tweaks 12"
    $pattern = "^" + [regex]::Escape($BaseName) + "\s+(\d+)"
    $m = [regex]::Match($rp.Description, $pattern)
    if ($m.Success) {
        $num = 0
        if ([int]::TryParse($m.Groups[1].Value, [ref]$num)) {
            if ($num -gt $maxIndex) { $maxIndex = $num }
        }
    }
}

$nextIndex = $maxIndex + 1

# Custom name handling
$finalBase = $BaseName
if (-not [string]::IsNullOrWhiteSpace($CustomName)) {
    $finalBase = $CustomName.Trim()
}

$nowStamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
$finalName = "$finalBase $nextIndex $nowStamp"

try {
    # Temporarily disable frequency limit
    New-Item -Path $srKey -Force | Out-Null
    Set-ItemProperty -Path $srKey -Name $srName -Type DWord -Value 0

    # Enable system restore for system drive
    Enable-ComputerRestore -Drive $env:SystemDrive -ErrorAction SilentlyContinue

    # Create restore point
    Checkpoint-Computer -Description $finalName -RestorePointType "MODIFY_SETTINGS"

    Write-ResultName $finalName
    exit 0
}
catch {
    Write-Output "ERROR: Failed to create restore point."
    Write-Output $_.Exception.Message
    exit 10
}
finally {
    # Restore original frequency value
    try {
        if ($hadValue) {
            Set-ItemProperty -Path $srKey -Name $srName -Type DWord -Value $oldValue
        } else {
            Remove-ItemProperty -Path $srKey -Name $srName -ErrorAction SilentlyContinue
        }
    } catch {
        # ignore
    }
}
