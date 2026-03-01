# ==========================================================
# KORSiOS Tweaks - Remove Microsoft Edge (KEEP WebView2)
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
    Write-Output "ERROR: Rollback is not supported for Edge removal."
    exit 3
}

try {
    # --- 1) Stop processes (do NOT uninstall WebView2, only stop if running) ---
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

    # --- 3) Remove Edge remnants (KEEP WebView2) ---
    $foldersToRemove = @(
        "$env:ProgramFiles (x86)\Microsoft\Edge",
        "$env:ProgramFiles\Microsoft\Edge",
        "$env:LocalAppData\Microsoft\Edge",
        "$env:ProgramData\Microsoft\Edge",
        "$env:ProgramData\Microsoft\EdgeUpdate"
    )

    foreach ($folder in $foldersToRemove) {
        if (Test-Path $folder) {
            Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # --- 4) Remove Edge Update services ---
    foreach ($svc in @("edgeupdate", "edgeupdatem")) {
        if (Get-Service $svc -ErrorAction SilentlyContinue) {
            sc.exe delete $svc | Out-Null
        }
    }

    # --- 5) Remove scheduled tasks (EdgeUpdate only, safe) ---
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

    # --- 6) Block Edge reinstall via policy (EdgeUpdate) ---
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -PropertyType DWord -Value 0 -Force | Out-Null

    # --- 7) Remove AppX stubs safely (no -AllUsers on Remove-AppxPackage) ---
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

    # --- 8) WebView2 presence check (informative only) ---
    $webview = "$env:ProgramFiles (x86)\Microsoft\EdgeWebView\Application"
    if (-not (Test-Path $webview)) {
        # Not an error: some systems may not have it installed
        # Keep output minimal and KORSiOS-friendly
        Write-Output "OK: Microsoft Edge removed (WebView2 not found on system)."
        exit 0
    }

    Write-Output "OK: Microsoft Edge removed (WebView2 kept)."
    exit 0
}
catch {
    $msg = $_.Exception.Message
    if ([string]::IsNullOrWhiteSpace($msg)) { $msg = $_.ToString() }
    Write-Output "ERROR: $msg"
    exit 1
}