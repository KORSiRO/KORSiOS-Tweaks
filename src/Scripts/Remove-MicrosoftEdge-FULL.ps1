# ==========================================================
# KORSiOS Tweaks - Remove Microsoft Edge (FULL CLEAN)
# Apply-only (no rollback)
# Output format: OK: / ERROR:
# ==========================================================
param(
    [ValidateSet("Apply","Rollback")]
    [string]$Mode = "Apply"
)

function Test-IsAdmin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p  = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Stop-IfRunning([string]$name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

if (-not (Test-IsAdmin)) {
    Write-Output "ERROR: Administrator rights are required."
    exit 5
}

if ($Mode -eq "Rollback") {
    Write-Output "ERROR: Rollback is not supported for FULL Edge removal."
    exit 3
}

try {
    # --- 1) Stop processes ---
    Stop-IfRunning "msedge"
    Stop-IfRunning "edgeupdate"
    Stop-IfRunning "edgeupdatem"
    Stop-IfRunning "msedgewebview2"

    # --- 2) Uninstall Edge (system-level) if installer exists ---
    $edgeAppPaths = @(
        "$env:ProgramFiles (x86)\Microsoft\Edge\Application",
        "$env:ProgramFiles\Microsoft\Edge\Application"
    )

    foreach ($path in $edgeAppPaths) {
        if (Test-Path $path) {
            $setup = Get-ChildItem "$path\*\Installer\setup.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($setup) {
                Start-Process $setup.FullName -ArgumentList "--uninstall --system-level --force-uninstall --verbose-logging" -Wait -ErrorAction Stop
            }
        }
    }

    # --- 3) Uninstall WebView2 Runtime (system-level) if installer exists ---
    $webViewAppPath = "$env:ProgramFiles (x86)\Microsoft\EdgeWebView\Application"
    if (Test-Path $webViewAppPath) {
        $wvSetup = Get-ChildItem "$webViewAppPath\*\Installer\setup.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($wvSetup) {
            Start-Process $wvSetup.FullName -ArgumentList "--uninstall --system-level --force-uninstall" -Wait -ErrorAction Stop
        }
    }

    # --- 4) Remove remaining folders ---
    $foldersToRemove = @(
        "$env:ProgramFiles (x86)\Microsoft\Edge",
        "$env:ProgramFiles\Microsoft\Edge",
        "$env:ProgramFiles (x86)\Microsoft\EdgeWebView",
        "$env:LocalAppData\Microsoft\Edge",
        "$env:LocalAppData\Microsoft\EdgeWebView",
        "$env:ProgramData\Microsoft\Edge",
        "$env:ProgramData\Microsoft\EdgeUpdate"
    )

    foreach ($folder in $foldersToRemove) {
        if (Test-Path $folder) {
            Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # --- 5) Remove Edge Update services ---
    foreach ($svc in @("edgeupdate", "edgeupdatem")) {
        if (Get-Service $svc -ErrorAction SilentlyContinue) {
            sc.exe delete $svc | Out-Null
        }
    }

    # --- 6) Remove scheduled tasks (EdgeUpdate) ---
    $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue
    if ($tasks) {
        $tasks |
        Where-Object {
            ($_.TaskPath -match "Microsoft\\EdgeUpdate") -or
            ($_.TaskName -match "EdgeUpdate")
        } |
        ForEach-Object {
            try {
                Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false -ErrorAction Stop
            } catch {
                # ignore single task failure
            }
        }
    }

    # --- 7) Block Edge reinstall via policy (EdgeUpdate) ---
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -PropertyType DWord -Value 0 -Force | Out-Null

    # --- 8) Remove AppX stubs safely (no -AllUsers on Remove-AppxPackage) ---
    $edgePkgs = Get-AppxPackage -AllUsers -Name "*MicrosoftEdge*" -ErrorAction SilentlyContinue
    if ($edgePkgs) {
        foreach ($pkg in $edgePkgs) {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
            } catch {
                # ignore
            }
        }
    }

    # Remove provisioned packages (future users)
    try {
        $prov = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*MicrosoftEdge*" }
        foreach ($p in $prov) {
            Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction SilentlyContinue | Out-Null
        }
    } catch {
        # ignore if cmdlets not available
    }

    Write-Output "OK: Microsoft Edge + WebView2 removed (FULL CLEAN)."
    exit 0
}
catch {
    $msg = $_.Exception.Message
    if ([string]::IsNullOrWhiteSpace($msg)) { $msg = $_.ToString() }
    Write-Output "ERROR: $msg"
    exit 1
}