# Run-Appx-Deprovision-SAFE.ps1
# KORSiOS SAFE: Deprovision uniquement (futurs comptes)
# Snapshot: C:\ProgramData\KORSiOS\States\AppxDebloat\SAFE\snapshot.json
# Exit codes: 0=ok/nochange, 3010=changed/reboot suggested, 5=admin required, 2=error

[CmdletBinding()]
param(
    [ValidateSet("Apply","Rollback")]
    [string]$Mode = "Apply"
)


# --- Ensure Windows PowerShell 5.1 (best compatibility for Appx/Dism cmdlets) ---
if ($PSVersionTable.PSEdition -eq 'Core') {
    & "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath -Mode $Mode
    exit $LASTEXITCODE
}

$ErrorActionPreference = "Continue"

# ---------- Paths ----------
$base = Join-Path $env:ProgramData "KORSiOS"
$stateDir = Join-Path $base "States\AppxDebloat\SAFE"
$logDir   = Join-Path $base "Logs"
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
New-Item -ItemType Directory -Force -Path $logDir   | Out-Null

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$log   = Join-Path $logDir ("AppxDebloat_SAFE_{0}.log" -f $stamp)
$snap  = Join-Path $stateDir "snapshot.json"

function Log([string]$msg) {
    $line = "[{0:yyyy-MM-dd HH:mm:ss}] {1}" -f (Get-Date), $msg
    $line | Tee-Object -FilePath $log -Append
}

function Is-Admin {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---------- Targets ----------
$Targets = @(
  "Microsoft.549981C3F5F10",
  "Microsoft.BingNews",
  "Microsoft.BingWeather",
  "Microsoft.BingSports",
  "Microsoft.BingTranslator",
  "clipchamp.clipchamp",
  "Microsoft.Copilot",
  "MicrosoftCorporationII.QuickAssist",
  "MicrosoftCorporationII.MicrosoftFamily",
  "Microsoft.GetHelp",
  "Microsoft.Getstarted",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftStickyNotes",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.Microsoft3DViewer",
  "Microsoft.MSPaint",
  "Microsoft.News",
  "Microsoft.OneConnect",
  "Microsoft.OutlookForWindows",
  "Microsoft.People",
  "Microsoft.PowerAutomateDesktop",
  "Microsoft.Paint",
  "Microsoft.Print3D",
  "Microsoft.ScreenSketch",
  "Microsoft.SkypeApp",
  "MicrosoftTeams",
  "MSTeams",
  "Microsoft.Todos",
  "Microsoft.Windows.Photos",
  "Microsoft.WindowsAlarms",
  "Microsoft.WindowsCamera",
  "Microsoft.WindowsCommunicationsApps",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.WindowsMaps",
  "Microsoft.WindowsSoundRecorder",
  "Microsoft.Whiteboard",
  "Microsoft.Windows.DevHome",
  "Microsoft.WindowsNotepad",
  "Microsoft.Windows.Ai.Copilot.Provider",
  "Microsoft.Wallet",
  "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo"
)

# ---------- Blocked (à éviter: frameworks/shell/edge/oneDrive/teams variables) ----------
$Blocked = @(
  "Microsoft.MicrosoftEdge",
  "Microsoft.MicrosoftEdge.Stable",
  "Microsoft.MicrosoftEdgeDevToolsClient",
  "Microsoft.Advertising.Xaml",
  "Microsoft.Windows.PeopleExperienceHost",
  "Microsoft.Windows.ContentDeliveryManager",
  "microsoft.microsoftskydrive",
  "Microsoft.MicrosoftTeamsforSurfaceHub",
  "MicrosoftCorporationII.MailforSurfaceHub",
  "Microsoft.MicrosoftPowerBIForWindows"
)

try {
    Log "=== KORSiOS AppxDebloat SAFE ($Mode) ==="

    if ($Mode -eq "Rollback") {
        # Rollback SAFE: on ne peut pas "re-provision" proprement sans source .appx/.msix
        # On garde un rollback "best effort": log + sortie code 2 (non supporté offline)
        Log "Rollback SAFE: non supporté offline (il faut la source .appx/.msix)."
        Log "Conseil: réinstaller via Microsoft Store / winget selon l'app."
        exit 2
    }

    if (-not (Is-Admin)) {
        Log "Admin requis pour Remove-AppxProvisionedPackage -Online."
        exit 5
    }

    $prov = Get-AppxProvisionedPackage -Online

    # Snapshot (audit)
    $snapshotObj = [ordered]@{
        timestamp = (Get-Date).ToString("o")
        mode = "SAFE"
        targets = $Targets
        provisioned_found = @()
    }

    $changed = $false

    foreach ($t in $Targets) {
        if ($Blocked -contains $t) {
            Log "SKIP blocked: $t"
            continue
        }

        # matching souple (DisplayName peut varier)
        $matches = $prov | Where-Object { $_.DisplayName -eq $t -or $_.DisplayName -like "$t*" }

        if (-not $matches) {
            Log "NOT FOUND provisioned: $t"
            continue
        }

        foreach ($m in $matches) {
            $snapshotObj.provisioned_found += [ordered]@{
                displayName = $m.DisplayName
                packageName = $m.PackageName
                version = $m.Version
            }

            
Log ("DEPROVISION: {0} | {1}" -f $m.DisplayName, $m.PackageName)
try {
    Remove-AppxProvisionedPackage -Online -PackageName $m.PackageName -ErrorAction Stop | Out-Null
    $changed = $true
}
catch {
    $msg = $_.Exception.Message
    Log ("WARN: failed to deprovision {0} -> {1}" -f $m.PackageName, $msg)
}
        }
    }

    ($snapshotObj | ConvertTo-Json -Depth 6) | Set-Content -Encoding UTF8 -Path $snap
    Log "Snapshot: $snap"

    if ($changed) {
        Log "Done. Changes applied. (reboot may be suggested)"
        exit 0
    } else {
        Log "Done. No changes. (0)"
        exit 0
    }
}
catch {
    Log ("ERROR: " + $_.Exception.Message)
    Log ("ERROR_DETAILS: " + ($_ | Out-String).Trim())
    exit 2
}
