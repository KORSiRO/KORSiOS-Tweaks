# ==========================================================
# KORSiOS Tweaks - Edge Debloat (SAFE)
# Apply/Rollback with local backup (exact values)
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

$Root = Join-Path $env:ProgramData "KORSiOS\States\EdgeDebloat\SAFE"
$BackupFile = Join-Path $Root "backup.json"
New-Item -ItemType Directory -Path $Root -Force | Out-Null

$Policies = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"; Name = "CreateDesktopShortcutDefault"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "PersonalizationReportingEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "ShowRecommendationsEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "HideFirstRunExperience"; Type = "DWord"; Value = 1 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "UserFeedbackAllowed"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "ConfigureDoNotTrack"; Type = "DWord"; Value = 1 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "AlternateErrorPagesEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "EdgeCollectionsEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "EdgeShoppingAssistantEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "MicrosoftEdgeInsiderPromotionEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "ShowMicrosoftRewards"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "WebWidgetAllowed"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "EdgeAssetDeliveryServiceEnabled"; Type = "DWord"; Value = 0 },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "WalletDonationEnabled"; Type = "DWord"; Value = 0 },
	@{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "DiagnosticData"; Type = "DWord"; Value = 0 },
	@{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "SmartScreenEnabled"; Type = "DWord"; Value = 0 },
	@{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "SmartScreenPuaEnabled"; Type = "DWord"; Value = 0 }
)


function Get-ExistingValue($path, $name) {
    try {
        $prop = Get-ItemProperty -Path $path -Name $name -ErrorAction Stop
        return @{
            Exists = $true
            Value  = $prop.$name
        }
    } catch {
        return @{
            Exists = $false
            Value  = $null
        }
    }
}

function Ensure-Key($path) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

function Set-PolicyValue($p) {
    Ensure-Key $p.Path
    if ($p.Type -eq "DWord") {
        New-ItemProperty -Path $p.Path -Name $p.Name -PropertyType DWord -Value ([int]$p.Value) -Force | Out-Null
    } elseif ($p.Type -eq "String") {
        New-ItemProperty -Path $p.Path -Name $p.Name -PropertyType String -Value ([string]$p.Value) -Force | Out-Null
    } else {
        throw "Unsupported Type: $($p.Type)"
    }
}

function Save-Backup() {
    $items = @()
    foreach ($p in $Policies) {
        $ex = Get-ExistingValue $p.Path $p.Name
        $items += [PSCustomObject]@{
            Path     = $p.Path
            Name     = $p.Name
            Type     = $p.Type
            HadValue = [bool]$ex.Exists
            OldValue = $ex.Value
        }
    }

    $obj = [PSCustomObject]@{
        Version   = 1
        CreatedAt = (Get-Date).ToString("s")
        Pack      = "SAFE"
        Items     = $items
    }

    $json = $obj | ConvertTo-Json -Depth 6
    Set-Content -Path $BackupFile -Value $json -Encoding UTF8
}

function Load-Backup() {
    if (-not (Test-Path $BackupFile)) {
        Write-Output "ERROR: Backup not found: $BackupFile"
        exit 2
    }
    $raw = Get-Content -Path $BackupFile -Raw -ErrorAction Stop
    return ($raw | ConvertFrom-Json -ErrorAction Stop)
}

try {
    if ($Mode -eq "Apply") {
        Save-Backup
        foreach ($p in $Policies) {
            Set-PolicyValue $p
        }
        Write-Output "OK: Edge Debloat SAFE applied."
        exit 0
    } else {
        $backup = Load-Backup
        foreach ($item in $backup.Items) {
            if ($item.HadValue -eq $true) {
                Ensure-Key $item.Path
                if ($item.Type -eq "DWord") {
                    New-ItemProperty -Path $item.Path -Name $item.Name -PropertyType DWord -Value ([int]$item.OldValue) -Force | Out-Null
                } elseif ($item.Type -eq "String") {
                    New-ItemProperty -Path $item.Path -Name $item.Name -PropertyType String -Value ([string]$item.OldValue) -Force | Out-Null
                } else {
                    Remove-ItemProperty -Path $item.Path -Name $item.Name -ErrorAction SilentlyContinue
                }
            } else {
                Remove-ItemProperty -Path $item.Path -Name $item.Name -ErrorAction SilentlyContinue
            }
        }
        Write-Output "OK: Edge Debloat SAFE rolled back."
        exit 0
    }
} catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 10
}
