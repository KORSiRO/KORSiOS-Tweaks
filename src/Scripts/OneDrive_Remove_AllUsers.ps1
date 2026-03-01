param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Apply","Rollback","Status")]
    [string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

$Base = Join-Path $env:LOCALAPPDATA "KORSiOS\TweakBackups\ONEDRIVE_REMOVE_ALLUSERS"
$BackupRegDir = Join-Path $Base "reg"
$BackupJson = Join-Path $Base "backup.json"

function SafeFileName($s){
    # PowerShell quote escaping uses backtick
    $s = $s -replace '[\\\/:\*\?`"<>\|]', "_"
    return $s
}

function Export-RegKey($keyPath){
    New-Item -Force -ItemType Directory -Path $BackupRegDir | Out-Null
    $safe = (SafeFileName $keyPath) + ".reg"
    $out = Join-Path $BackupRegDir $safe
    & reg.exe export "$keyPath" "$out" /y *> $null
    return $out
}

function Import-RegFile($file){
    if (Test-Path $file){
        & reg.exe import "$file" *> $null
    }
}

function Backup-Once {
    if (Test-Path $BackupJson) { return }
    New-Item -Force -ItemType Directory -Path $Base | Out-Null

    $toBackup = @(
        "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive",
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
        "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    )

    $exports = @()
    foreach($k in $toBackup){
        try { $exports += @{ key=$k; file=(Export-RegKey $k) } } catch { }
    }

    $data = [ordered]@{
        created = (Get-Date).ToString("s")
        regExports = $exports
    } | ConvertTo-Json -Depth 6

    $data | Out-File -FilePath $BackupJson -Encoding UTF8
}

function Rollback-Backup {
    if (-not (Test-Path $BackupJson)) { throw "No backup found: $BackupJson" }
    $data = Get-Content $BackupJson -Raw | ConvertFrom-Json
    foreach($e in $data.regExports){
        try { Import-RegFile $e.file } catch { }
    }
}

function Stop-OneDriveProcesses {
    $names = @("OneDrive","OneDriveStandaloneUpdater","OneDriveSetup")
    foreach($n in $names){
        Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

function Uninstall-OneDriveOfficial {
    # Official uninstall entry points
    $sys32 = Join-Path $env:SystemRoot "System32\OneDriveSetup.exe"
    $syswow = Join-Path $env:SystemRoot "SysWOW64\OneDriveSetup.exe"

    if (Test-Path $syswow) {
        Write-Info "Uninstall via $syswow"
        & $syswow /uninstall | Out-Null
        return
    }
    if (Test-Path $sys32) {
        Write-Info "Uninstall via $sys32"
        & $sys32 /uninstall | Out-Null
        return
    }
    Write-Warn "OneDriveSetup.exe not found (may already be removed)."
}

function Apply-OneDrivePolicyAllUsers {
    # Prevent OneDrive file storage usage (HKLM policy -> applies to all users)
    $k = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    New-Item -Force $k | Out-Null
    New-ItemProperty -Path $k -Name "DisableFileSyncNGSC" -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Ok "Policy DisableFileSyncNGSC=1 applied (all users)"
}

function Remove-OneDriveFromExplorer {
    # Remove namespace entries (Navigation pane)
    $k1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    $k2 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    if (Test-Path $k1) { Remove-Item -Recurse -Force $k1; Write-Ok "Removed Explorer NameSpace (64-bit)" }
    if (Test-Path $k2) { Remove-Item -Recurse -Force $k2; Write-Ok "Removed Explorer NameSpace (32-bit)" }
}

function Cleanup-OneDriveFoldersAllUsers {
    # Remove per-user OneDrive folders + leftovers
    # 1) C:\Users\<user>\OneDrive
    # 2) AppData leftovers for each profile
    $userRoot = Join-Path $env:SystemDrive "Users"
    if (-not (Test-Path $userRoot)) { return }

    $profiles = Get-ChildItem $userRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @("Public","Default","Default User","All Users") }

    foreach($p in $profiles){
        $one = Join-Path $p.FullName "OneDrive"
        if (Test-Path $one) {
            try { Remove-Item -Recurse -Force $one; Write-Ok "Deleted: $one" } catch { Write-Warn "Failed delete: $one ($_)"} 
        }

        $local = Join-Path $p.FullName "AppData\Local\Microsoft\OneDrive"
        $roam  = Join-Path $p.FullName "AppData\Roaming\Microsoft\OneDrive"
        $prog  = Join-Path $p.FullName "AppData\Local\Microsoft\OneDriveSetup"

        foreach($d in @($local,$roam,$prog)){
            if (Test-Path $d) {
                try { Remove-Item -Recurse -Force $d; Write-Ok "Deleted: $d" } catch { Write-Warn "Failed delete: $d ($_)"} 
            }
        }
    }

    # ProgramData leftovers
    $pd = Join-Path $env:ProgramData "Microsoft OneDrive"
    if (Test-Path $pd) {
        try { Remove-Item -Recurse -Force $pd; Write-Ok "Deleted: $pd" } catch { Write-Warn "Failed delete: $pd ($_)"} 
    }
}

function Status {
    $installed = $false
    $pf = Join-Path $env:ProgramFiles "Microsoft OneDrive\OneDrive.exe"
    $pfx = Join-Path ${env:ProgramFiles(x86)} "Microsoft OneDrive\OneDrive.exe"
    if (Test-Path $pf -or Test-Path $pfx) { $installed = $true }

    $policy = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue).DisableFileSyncNGSC
    $ns1 = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    $ns2 = Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"

    Write-Host "InstalledExe=$installed PolicyDisableFileSyncNGSC=$policy ExplorerNamespace64=$ns1 Namespace32=$ns2"
    exit 0
}

# -------- Main --------
try {
    if ($Mode -eq "Status") { Status }

    Ensure-Admin

    if ($Mode -eq "Apply") {
        Backup-Once
        Stop-OneDriveProcesses
        Apply-OneDrivePolicyAllUsers
        Uninstall-OneDriveOfficial
        Remove-OneDriveFromExplorer
        Cleanup-OneDriveFoldersAllUsers

        Write-Ok "OneDrive removal (all users) completed."
        exit 0
    }

    if ($Mode -eq "Rollback") {
        # Rollback registry (policy + namespace). Folders can't be restored.
        Rollback-Backup
        Write-Warn "Rollback restored registry keys (policy/namespace). Folder deletions cannot be restored."
        exit 0
    }

    throw "Unknown Mode: $Mode"
}
catch {
    Write-Error $_
    exit 1
}
