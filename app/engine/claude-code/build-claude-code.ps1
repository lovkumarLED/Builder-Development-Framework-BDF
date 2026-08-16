param(
    [Parameter(Mandatory=$true)][string]$FixtureRoot,
    [Parameter(Mandatory=$true)][string]$RoutingProfilePath,
    [Parameter(Mandatory=$true)][string]$SettingsPath,
    [string]$SchemaPath="",
    [ValidateSet("None","AfterBackup","AfterTempWrite","AfterReplace")][string]$TestFailureStage="None"
)

$ErrorActionPreference="Stop"
$stage="VALIDATION"
$backupPath=$null
$tempPath=$null
$targetMayHaveChanged=$false

$corePath=Join-Path $PSScriptRoot "claude-routing-core.psm1"
if(!(Test-Path -LiteralPath $corePath -PathType Leaf)){Write-Output "VALIDATION FAILED; shared routing core missing"; exit 1}
Import-Module -Name $corePath -Force -DisableNameChecking

function Assert-SafePaths {
    $script:FixtureRoot=Get-Canonical $FixtureRoot
    $tempBoundary=(Get-Canonical ([IO.Path]::GetTempPath())).TrimEnd('\'); $tempRoot=$tempBoundary+'\'
    if(!$script:FixtureRoot.StartsWith($tempRoot,[StringComparison]::OrdinalIgnoreCase)){Fail "fixture root outside temp"}
    Assert-NoReparseComponent $script:FixtureRoot $tempBoundary
    $rootPrefix=$script:FixtureRoot.TrimEnd('\')+'\'
    $stateLeaf="."+"claude"+".json"; $commentSuffix="."+"jsonc"
    foreach($name in @("RoutingProfilePath","SettingsPath","SchemaPath")){
        $value=Get-Variable $name -ValueOnly
        if($name-eq "SchemaPath" -and [string]::IsNullOrEmpty($value)){$value=Join-Path $script:FixtureRoot "schemas\claude-code-routing.schema.json"}
        $full=Get-Canonical $value
        if(!$full.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)){Fail "path boundary violation"}
        if([IO.Path]::GetFileName($full)-ieq $stateLeaf){Fail "forbidden state filename"}
        if($full.EndsWith($commentSuffix,[StringComparison]::OrdinalIgnoreCase)){Fail "forbidden suffix"}
        Assert-NoReparseComponent $full $tempBoundary
        Set-Variable -Scope Script -Name $name -Value $full
    }
    if(!(Test-Path -LiteralPath $script:SettingsPath -PathType Leaf)){Fail "target must pre-exist"}
    foreach($p in @($script:RoutingProfilePath,$script:SchemaPath)){if(!(Test-Path -LiteralPath $p -PathType Leaf)){Fail "required fixture missing"}}
}

try{
    Assert-SafePaths
}catch{
    Write-Output "VALIDATION FAILED; $($_.Exception.Message)"
    exit 1
}
Invoke-ClaudeRoutingApply -SettingsPath $script:SettingsPath -RoutingProfilePath $script:RoutingProfilePath -SchemaPath $script:SchemaPath -OutputLabel "fixture target" -TestFailureStage $TestFailureStage
