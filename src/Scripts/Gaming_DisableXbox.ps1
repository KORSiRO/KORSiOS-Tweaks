<# 
KORSiOS Tweaks — ScriptTweak autonome
ID: Gaming_DisableXbox
TITLE: KORSiOS - [Gaming]• Xbox •  Désactiver Xbox GameBar & DVR

Mode:
  -Mode Apply   : applique le tweak (avec backup local)
  -Mode Revert  : restaure le backup local (rollback)
  -Mode Status  : indique si le tweak semble appliqué (best-effort)

Notes:
- Backup/rollback stocké dans %LOCALAPPDATA%\KORSiOS\TweakBackups\Gaming_DisableXbox
- Certaines clés peuvent nécessiter des droits administrateur (HKLM/HKCR).
#>

[CmdletBinding()]
param(
    [ValidateSet("Apply","Revert","Status")]
    [string]$Mode = "Apply"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TweakId = "Gaming_DisableXbox"
$TweakTitle = "KORSiOS - [Gaming]• Xbox •  Désactiver Xbox GameBar & DVR"

function Write-Info([string]$msg) {
    Write-Host "[KORSiOS][$TweakId] $msg"
}

function Test-IsAdmin {
    try {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Ensure-Folder([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Save-RegistryBackup([string[]]$regKeys, [string]$backupDir) {
    Ensure-Folder $backupDir
    $backupFile = Join-Path $backupDir "backup.reg"
    $indexFile  = Join-Path $backupDir "keys.txt"

    $tmpDir = Join-Path $backupDir "_tmp"
    if (Test-Path -LiteralPath $tmpDir) { Remove-Item -LiteralPath $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    $exported = @()
    foreach ($k in $regKeys) {
        $safeName = ($k -replace "[\\/:\*\?`"<>\|]", "_") + ".reg"
        $out = Join-Path $tmpDir $safeName

        $p = Start-Process -FilePath "reg.exe" -ArgumentList @("export", $k, $out, "/y") -Wait -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue
        if (Test-Path -LiteralPath $out) {
            $exported += $out
        }
    }

    $header = "Windows Registry Editor Version 5.00`r`n`r`n"
    Set-Content -LiteralPath $backupFile -Value $header -Encoding Unicode

    foreach ($f in $exported) {
        $lines = Get-Content -LiteralPath $f -Encoding Unicode
        if ($lines.Count -gt 0 -and $lines[0] -match "^Windows Registry Editor Version") {
            $lines = $lines | Select-Object -Skip 1
        }
        Add-Content -LiteralPath $backupFile -Value ($lines -join "`r`n") -Encoding Unicode
        Add-Content -LiteralPath $backupFile -Value "`r`n" -Encoding Unicode
    }

    Set-Content -LiteralPath $indexFile -Value ($regKeys -join "`r`n") -Encoding UTF8
    if (Test-Path -LiteralPath $tmpDir) { Remove-Item -LiteralPath $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }

    return $backupFile
}

function Import-RegFromString([string]$regText) {
    $tmp = Join-Path $env:TEMP ("Gaming_DisableXbox_" + [Guid]::NewGuid().ToString("N") + ".reg")
    Set-Content -LiteralPath $tmp -Value $regText -Encoding Unicode
    try {
        $p = Start-Process -FilePath "reg.exe" -ArgumentList @("import", $tmp) -Wait -PassThru -WindowStyle Hidden
        if ($p.ExitCode -ne 0) {
            throw "reg.exe import a échoué (ExitCode=$($p.ExitCode))"
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Apply-Tweak {
    $backupDir = Join-Path $env:LOCALAPPDATA ("KORSiOS\TweakBackups\Gaming_DisableXbox")
    $regKeys = @(
        "HKEY_CURRENT_USER\System\GameConfigStore"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
        "HKEY_CURRENT_USER\Software\Microsoft\GameBar"
		"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    )

    if (-not (Test-IsAdmin)) {.
        Write-Info "Info: non-admin. Si ce tweak touche HKLM/HKCR, l'application peut échouer."
    }

    Write-Info "Backup registre..."
    Save-RegistryBackup -regKeys $regKeys -backupDir $backupDir | Out-Null

    Write-Info "Application du tweak..."
    $reg = @"
Windows Registry Editor Version 5.00

; KORSiOS - [Gaming]• Xbox •  Désactiver Xbox GameBar & DVR
; ID: Gaming_DisableXbox
; DESC: Désactive Game DVR et force un mode plein écran exclusif pour les jeux.
; IMPACT: - Désactive l’enregistrement vidéo en arrière-plan (Game DVR / Xbox Game Bar).
; IMPACT: - Force le comportement plein écran exclusif, évitant les optimisations plein écran hybrides.
; IMPACT: - Réduit la charge CPU/GPU et la latence en jeu.
; IMPACT: - Améliore la stabilité et les performances dans les jeux, surtout compétitifs.
; RISK: - Perte des fonctions d’enregistrement instantané et de capture automatique.
; RISK: - Certains jeux récents optimisés pour le mode fenêtré/borderless peuvent ne pas tirer avantage de ce réglage.
; RISK: - Impact nul hors jeu.
; NOTE: Réglage gaming / performance : coupe les services Xbox inutiles et privilégie le plein écran exclusif pour des performances maximales.
; RESTART: REBOOT
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000
"GameDVR_FSEBehaviorMode"=dword:00000002
"GameDVR_FSEBehavior"=dword:00000002
"GameDVR_HonorUserFSEBehaviorMode"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
"AllowGameDVR"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"ShowStartupPanel"=dword:00000000
"GameBarEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000

"@
    Import-RegFromString -regText $reg

    Write-Info "OK"
}

function Revert-Tweak {
    $backupDir = Join-Path $env:LOCALAPPDATA ("KORSiOS\TweakBackups\Gaming_DisableXbox")
    $backupFile = Join-Path $backupDir "backup.reg"

    if (-not (Test-Path -LiteralPath $backupFile)) {
        throw "Aucun backup trouvé: $backupFile"
    }

    if (-not (Test-IsAdmin)) {
        Write-Info "Info: non-admin. Si le rollback touche HKLM/HKCR, il peut échouer."
    }

    Write-Info "Restauration backup..."
    $reg = Get-Content -LiteralPath $backupFile -Encoding Unicode -Raw
    Import-RegFromString -regText $reg

    Write-Info "Rollback OK"
}

function Status-Tweak {
    $regKeys = @(
        "HKEY_CURRENT_USER\System\GameConfigStore"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
        "HKEY_CURRENT_USER\Software\Microsoft\GameBar"
		"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    )
    $exists = $false
    foreach ($k in $regKeys) {
        try {
            $psPath = "Registry::" + $k
            if (Test-Path -LiteralPath $psPath) { $exists = $true; break }
        } catch {}
    }
    if ($exists) {
        Write-Output "PRESENT"
    } else {
        Write-Output "ABSENT"
    }
}

try {
    switch ($Mode) {
        "Apply"  { Apply-Tweak }
        "Revert" { Revert-Tweak }
        "Status" { Status-Tweak }
    }
} catch {
    Write-Error "[KORSiOS][$TweakId] FAIL: $($_.Exception.Message)"
    exit 1
}
