<# 
KORSiOS Tweaks
ID: Photo_EnablePhotoViwerClassic
TITLE: KORSiOS - [Visionneuse de Photos Windows]Activer la visionneuse de photos Windows & associations d'images
#>

[CmdletBinding()]
param(
    [ValidateSet("Apply","Revert","Status")]
    [string]$Mode = "Apply"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$TweakId = "Photo_EnablePhotoViwerClassic"
$TweakTitle = "KORSiOS - [Visionneuse de Photos Windows]Activer la visionneuse de photos Windows & associations d'images"

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
    $tmp = Join-Path $env:TEMP ("Photo_EnablePhotoViwerClassic_" + [Guid]::NewGuid().ToString("N") + ".reg")
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
    $backupDir = Join-Path $env:LOCALAPPDATA ("KORSiOS\TweakBackups\Photo_EnablePhotoViwerClassic")
    $regKeys = @(
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\command"
        "HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\DropTarget"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
        "HKEY_CURRENT_USER\Software\Classes\.jpg"
        "HKEY_CURRENT_USER\Software\Classes\.jpeg"
        "HKEY_CURRENT_USER\Software\Classes\.gif"
        "HKEY_CURRENT_USER\Software\Classes\.png"
        "HKEY_CURRENT_USER\Software\Classes\.bmp"
        "HKEY_CURRENT_USER\Software\Classes\.tiff"
        "HKEY_CURRENT_USER\Software\Classes\.ico"
        "HKEY_CURRENT_USER\Software\Classes\.tif"
        "HKEY_CURRENT_USER\Software\Classes\.wdp"
        "HKEY_CURRENT_USER\Software\Classes\.jfif"
        "HKEY_CURRENT_USER\Software\Classes\.dib"
        "HKEY_CURRENT_USER\Software\Classes\.jpe"
        "HKEY_CURRENT_USER\Software\Classes\.jxr"
    )

    if (-not (Test-IsAdmin)) {
        Write-Info "Info: non-admin. Si ce tweak touche HKLM/HKCR, l'application peut échouer."
    }

    Write-Info "Backup registre..."
    Save-RegistryBackup -regKeys $regKeys -backupDir $backupDir | Out-Null

    Write-Info "Application du tweak..."
    $reg = @"
Windows Registry Editor Version 5.00

; KORSiOS - [Visionneuse de Photos Windows]Activer la visionneuse de photos Windows & associations d'images
; ID: Photo_EnablePhotoViwerClassic
; DESC: Restaure et définit la Visionneuse de Photos Windows (classique) comme visionneuse d’images par défaut à la place de l’application Photos moderne.
; IMPACT: - Réactive complètement la Visionneuse de Photos Windows, encore présent mais masqué dans Windows modernes.
; IMPACT: - Réassocie la majorité des formats d’images.
; IMPACT: - Remplace l’ouverture et l’aperçu d’images par le moteur classique.
; RISK: - Fonctionnalités modernes absentes : pas d’édition avancée, pas d’intégration cloud/IA, pas de HDR moderne.
; RISK: - Dépend d’un composant legacy : Microsoft pourrait le retirer définitivement dans de futures versions.
; NOTE: Réglage performance / nostalgie / efficacité : la Visionneuse de Photos Windows (classique) est plus rapide et minimaliste que l’app Photos.
; RESTART: REBOOT
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open]
"MuiVerb"="`@photoviewer.dll,-3043"

[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap]
"ImageOptionFlags"=dword:00000001
"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,36,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\DefaultIcon]
@="%SystemRoot%\\System32\\imageres.dll,-70"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print]
"NeverDefault"=""

[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget]
"Clsid"="{60fd46de-f830-4894-a628-6fa81bc0190d}"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF]
"EditFlags"=dword:00010000
"ImageOptionFlags"=dword:00000001
"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\DefaultIcon]
@="%SystemRoot%\\System32\\imageres.dll,-72"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open]
"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg]
"EditFlags"=dword:00010000
"ImageOptionFlags"=dword:00000001
"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,35,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\DefaultIcon]
@="%SystemRoot%\\System32\\imageres.dll,-72"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open]
"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif]
"ImageOptionFlags"=dword:00000001
"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\DefaultIcon]
@="%SystemRoot%\\System32\\imageres.dll,-83"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png]
"ImageOptionFlags"=dword:00000001
"FriendlyTypeName"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,35,00,37,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\DefaultIcon]
@="%SystemRoot%\\System32\\imageres.dll,-71"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp]
"EditFlags"=dword:00010000
"ImageOptionFlags"=dword:00000001

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\DefaultIcon]
@="%SystemRoot%\\System32\\wmphoto.dll,-400"

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open]
"MuiVerb"=hex(2):40,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,70,00,68,00,6f,00,74,00,6f,00,76,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,33,00,30,00,34,00,33,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget]
"Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

[HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,00,31,00,00,00

[HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\DropTarget]
"{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"=""

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities]
"ApplicationDescription"="`@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3069"
"ApplicationName"="`@%ProgramFiles%\\Windows Photo Viewer\\photoviewer.dll,-3009"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations]
".cr2"="PhotoViewer.FileAssoc.Tiff"
".jpg"="PhotoViewer.FileAssoc.Jpeg"
".wdp"="PhotoViewer.FileAssoc.Wdp"
".jfif"="PhotoViewer.FileAssoc.JFIF"
".dib"="PhotoViewer.FileAssoc.Bitmap"
".png"="PhotoViewer.FileAssoc.Png"
".jxr"="PhotoViewer.FileAssoc.Wdp"
".bmp"="PhotoViewer.FileAssoc.Bitmap"
".jpe"="PhotoViewer.FileAssoc.Jpeg"
".jpeg"="PhotoViewer.FileAssoc.Jpeg"
".gif"="PhotoViewer.FileAssoc.Gif"
".tif"="PhotoViewer.FileAssoc.Tiff"
".tiff"="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.jpg]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.jpeg]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.gif]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.png]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.bmp]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.tiff]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.ico]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.tif]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.wdp]
@="PhotoViewer.FileAssoc.Wdp"

[HKEY_CURRENT_USER\Software\Classes\.jfif]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.dib]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.jpe]
@="PhotoViewer.FileAssoc.Tiff"

[HKEY_CURRENT_USER\Software\Classes\.jxr]
@="PhotoViewer.FileAssoc.Tiff"

"@
    Import-RegFromString -regText $reg

    Write-Info "OK"
}

function Revert-Tweak {
    $backupDir = Join-Path $env:LOCALAPPDATA ("KORSiOS\TweakBackups\Photo_EnablePhotoViwerClassic")
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
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Bitmap\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command"
        "HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.JFIF\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Jpeg\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Gif\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Png\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\DefaultIcon"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\command"
        "HKEY_CLASSES_ROOT\PhotoViewer.FileAssoc.Wdp\shell\open\DropTarget"
        "HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\command"
        "HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\Image Preview\DropTarget"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities"
        "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"
        "HKEY_CURRENT_USER\Software\Classes\.jpg"
        "HKEY_CURRENT_USER\Software\Classes\.jpeg"
        "HKEY_CURRENT_USER\Software\Classes\.gif"
        "HKEY_CURRENT_USER\Software\Classes\.png"
        "HKEY_CURRENT_USER\Software\Classes\.bmp"
        "HKEY_CURRENT_USER\Software\Classes\.tiff"
        "HKEY_CURRENT_USER\Software\Classes\.ico"
        "HKEY_CURRENT_USER\Software\Classes\.tif"
        "HKEY_CURRENT_USER\Software\Classes\.wdp"
        "HKEY_CURRENT_USER\Software\Classes\.jfif"
        "HKEY_CURRENT_USER\Software\Classes\.dib"
        "HKEY_CURRENT_USER\Software\Classes\.jpe"
        "HKEY_CURRENT_USER\Software\Classes\.jxr"
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
        "Apply"    { Apply-Tweak; break }
        "Revert"   { Revert-Tweak; break }
        "Rollback" { Revert-Tweak; break }
        "Status"   { Status-Tweak; break }
        default    { throw "Mode invalide: $Mode" }
    }
    exit 0
} catch {
    Write-Error "[KORSiOS][$TweakId] FAIL: $($_.Exception.Message)"
    exit 1
}
