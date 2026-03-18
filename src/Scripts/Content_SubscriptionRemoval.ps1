<# 
KORSiOS Tweaks
ID: Content_SubscriptionRemoval
TITLE: KORSiOS - [Content Delivery Manager]Suppression des abonnements
#>

[CmdletBinding()]
param(
    [ValidateSet("Apply","Revert","Status")]
    [string]$Mode = "Apply"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TweakId = "Content_SubscriptionRemoval"
$TweakTitle = "KORSiOS - [Content Delivery Manager]Suppression des abonnements"

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
    $tmp = Join-Path $env:TEMP ("Content_SubscriptionRemoval_" + [Guid]::NewGuid().ToString("N") + ".reg")
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
    $backupDir = Join-Path $env:LOCALAPPDATA ("KORSiOS\TweakBackups\Content_SubscriptionRemoval")
    $regKeys = @(
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions"
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps"
    )

    if (-not (Test-IsAdmin)) {
        Write-Info "Info: non-admin. Si ce tweak touche HKLM/HKCR, l'application peut échouer."
    }

    Write-Info "Backup registre..."
    Save-RegistryBackup -regKeys $regKeys -backupDir $backupDir | Out-Null

    Write-Info "Application du tweak..."
    $reg = @"
Windows Registry Editor Version 5.00

; KORSiOS - [Content Delivery Manager]Suppression des abonnements
; ID: Content_SubscriptionRemoval
; DESC: Supprime les abonnements de contenu et les suggestions d’applications de Windows pour l’utilisateur.
; IMPACT: - Efface les clés Subscriptions et SuggestedApps du Content Delivery Manager.
; IMPACT: - Supprime les données déjà enregistrées concernant les contenus suggérés et les apps recommandées.
; IMPACT: - Empêche l’affichage de suggestions basées sur des abonnements précédents.
; IMPACT: - Complète les réglages de désactivation du contenu promotionnel pour un système propre et cohérent.
; RISK: - Perte d’historique de recommandations (sans conséquence fonctionnelle).
; RISK: - Aucun impact sur la stabilité, la sécurité ou les performances du système.
; NOTE: Réglage nettoyage / anti-reliquat : purge les traces de contenus suggérés afin d’éviter leur réapparition.
; RESTART: REBOOT
[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions]
[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps]

"@
    Import-RegFromString -regText $reg

    Write-Info "OK"
}

function Revert-Tweak {
    $backupDir = Join-Path $env:LOCALAPPDATA ("KORSiOS\TweakBackups\Content_SubscriptionRemoval")
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
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions"
        "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps"
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
