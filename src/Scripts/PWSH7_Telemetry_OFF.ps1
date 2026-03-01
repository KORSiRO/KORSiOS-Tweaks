# ==========================================================
# KORSiOS Tweaks - Disable PowerShell 7 Telemetry (Machine)
# ==========================================================

param(
    [ValidateSet("Apply","Rollback")]
    [string]$Mode = "Apply"
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

if (-not (Test-IsAdmin)) {
    Write-Output "ERROR: Administrator rights are required."
    exit 5
}

$VarName = "POWERSHELL_TELEMETRY_OPTOUT"
$BackupDir = Join-Path $env:ProgramData "KORSiOS\States\PWSH7Telemetry"
$BackupFile = Join-Path $BackupDir "backup.txt"

New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

try {
    if ($Mode -eq "Apply") {

        # Backup current value (or marker if missing)
        $current = [Environment]::GetEnvironmentVariable($VarName, "Machine")
        if ($null -eq $current) {
            Set-Content -Path $BackupFile -Value "__MISSING__" -Encoding UTF8
        } else {
            Set-Content -Path $BackupFile -Value $current -Encoding UTF8
        }

        # Apply
        [Environment]::SetEnvironmentVariable($VarName, "1", "Machine")

        Write-Output "OK: PowerShell 7 telemetry disabled (POWERSHELL_TELEMETRY_OPTOUT=1)."
        exit 0
    }
    else {
        if (-not (Test-Path $BackupFile)) {
            Write-Output "ERROR: Backup not found: $BackupFile"
            exit 2
        }

        $old = (Get-Content -Path $BackupFile -Raw).Trim()

        if ($old -eq "__MISSING__") {
            # Proper removal
            [Environment]::SetEnvironmentVariable($VarName, $null, "Machine")
            Write-Output "OK: Restored (variable removed)."
        } else {
            [Environment]::SetEnvironmentVariable($VarName, $old, "Machine")
            Write-Output "OK: Restored (previous value)."
        }

        exit 0
    }
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 10
}
