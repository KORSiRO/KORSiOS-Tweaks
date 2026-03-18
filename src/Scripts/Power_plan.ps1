<# 
KORSiOS Tweaks
ID: POWER_PLAN_KORSIOS
TITLE: • Plan • KORSiOS Haute performance
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Apply","Rollback","Status")]
    [string]$Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Dir([string]$p){
    if (-not (Test-Path -LiteralPath $p)){
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}

function Invoke-PowerCfg {
    param([Parameter(Mandatory=$true)][string[]]$Args)
    $out = & powercfg @Args 2>&1
    $code = $LASTEXITCODE
    return [pscustomobject]@{
        Code = $code
        Out  = ($out -join "`n")
    }
}

function Extract-Guid([string]$text){
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    $m = [regex]::Match($text,"(\{)?([0-9a-fA-F\-]{36})(\})?")
    if ($m.Success){ return $m.Groups[2].Value.ToLowerInvariant() }
    return $null
}

function Get-ActiveSchemeGuid{
    $r = Invoke-PowerCfg -Args @("-getactivescheme")
    if ($r.Code -ne 0){ return $null }
    return (Extract-Guid $r.Out)
}

function Find-SchemeByName([string]$name){
    $r = Invoke-PowerCfg -Args @("-list")
    if ($r.Code -ne 0){ return $null }

    foreach($line in ($r.Out -split "`r?`n")){
        $guid = Extract-Guid $line
        if (-not $guid){ continue }

        if ($line -match "\((.+)\)"){
            $n = $Matches[1].Trim()
            if ($n -ieq $name){ return $guid }
        }
    }
    return $null
}

$BackupDir  = Join-Path $env:LOCALAPPDATA "KORSiOS\TweakBackups\POWER_PLAN"
$BackupJson = Join-Path $BackupDir "backup.json"

function Backup-Once([hashtable]$state){
    if (Test-Path -LiteralPath $BackupJson){ return }

    Ensure-Dir $BackupDir

    $obj = [pscustomobject]$state
    ($obj | ConvertTo-Json -Depth 8) | Out-File -LiteralPath $BackupJson -Encoding UTF8
}

function Load-Backup{
    if (-not (Test-Path -LiteralPath $BackupJson)){ return $null }
    return (Get-Content -LiteralPath $BackupJson -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Apply{

    $planName = "KORSiOS High Performance"

    $activeBefore = Get-ActiveSchemeGuid
    if (-not $activeBefore){ throw "Unable to read active scheme." }

    $existing = Find-SchemeByName $planName
    $createdNew = $false
    $planGuid = $existing

    if (-not $existing){

        $rDup = Invoke-PowerCfg -Args @("-duplicatescheme","SCHEME_MIN")
        if ($rDup.Code -ne 0){
            $rDup = Invoke-PowerCfg -Args @("-duplicatescheme","8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c")
        }
        if ($rDup.Code -ne 0){ throw "duplicatescheme failed: $($rDup.Out)" }

        $planGuid = Extract-Guid $rDup.Out
        if (-not $planGuid){ throw "Unable to parse GUID." }

        $rName = Invoke-PowerCfg -Args @("-changename",$planGuid,$planName)
        if ($rName.Code -ne 0){ throw "changename failed: $($rName.Out)" }

        $createdNew = $true
    }

    Backup-Once -state @{
        created      = (Get-Date).ToString("s")
        activeBefore = $activeBefore
        planName     = $planName
        planGuid     = $planGuid
        createdNew   = $createdNew
    }

    $rAct = Invoke-PowerCfg -Args @("-setactive",$planGuid)
    if ($rAct.Code -ne 0){ throw "setactive failed: $($rAct.Out)" }

    "OK"
}

function Rollback{

    $b = Load-Backup
    if (-not $b){ throw "No backup found." }

    if ($b.activeBefore){
        $r = Invoke-PowerCfg -Args @("-setactive",$b.activeBefore)
        if ($r.Code -ne 0){ throw "restore setactive failed: $($r.Out)" }
    }
    else{
        Invoke-PowerCfg -Args @("-setactive","SCHEME_BALANCED") | Out-Null
    }

    if ($b.createdNew -and $b.planGuid){
        Invoke-PowerCfg -Args @("-delete",$b.planGuid) | Out-Null
    }

    "OK"
}

function Status{

    $planName = "KORSiOS High Performance"
    $guid = Find-SchemeByName $planName

    if (-not $guid){ "ABSENT"; return }

    $active = Get-ActiveSchemeGuid

    if ($active -and ($active -eq $guid)){
        "ACTIVE"
    }
    else{
        "PRESENT"
    }
}

try{

    if ($Mode -eq "Status"){ Status | Out-Null; exit 0 }

    if ($Mode -eq "Apply"){ Apply | Out-Null; exit 0 }

    if ($Mode -eq "Rollback"){ Rollback | Out-Null; exit 0 }

    throw "Unknown mode"
}
catch{
    Write-Error $_
    exit 1
}
