param(
    [Parameter(Mandatory=$true)][ValidateSet("Apply","Restore")][string]$Operation,
    [Parameter(Mandatory=$true)][string]$ProfileRoot,
    [Parameter(Mandatory=$true)][string]$SettingsPath,
    [string]$RoutingProfilePath="",
    [Parameter(Mandatory=$true)][string]$SchemaPath,
    [string]$BackupPath="",
    [string]$ExpectedBackupSha256="",
    [string]$TargetBindingSha256="",
    [switch]$AllowRealTarget,
    [ValidateSet("None","AfterBackup","AfterTempWrite","AfterReplace","AfterRecoveryCopy","AfterRecoveryReplace")][string]$TestFailureStage="None"
)

$ErrorActionPreference="Stop"

$corePath=Join-Path $PSScriptRoot "claude-routing-core.psm1"
if(!(Test-Path -LiteralPath $corePath -PathType Leaf)){[Console]::Error.WriteLine("VALIDATION FAILED; shared routing core missing"); exit 1}
Import-Module -Name $corePath -Force -DisableNameChecking

function Fail { param([string]$Reason) throw $Reason }

function Assert-TrustedLeaf { param([string]$Path,[string]$Label)
    $stateLeaf="."+"claude"+".json"; $commentSuffix="."+"jsonc"
    if([string]::IsNullOrEmpty($Path)){Fail "$Label required"}
    $full=Get-Canonical $Path
    if([IO.Path]::GetFileName($full)-ieq $stateLeaf){Fail "forbidden state filename"}
    if($full.EndsWith($commentSuffix,[StringComparison]::OrdinalIgnoreCase)){Fail "forbidden suffix"}
    Assert-NoReparseComponent $full $script:userProfile
    if(!(Test-Path -LiteralPath $full -PathType Leaf)){Fail "$Label must be an existing file"}
}

$boundParameters=$PSBoundParameters

function Assert-ParameterContract {
    if($Operation-eq "Apply"){
        if(!$boundParameters.ContainsKey("RoutingProfilePath")){Fail "routing profile required for Apply"}
        if($boundParameters.ContainsKey("BackupPath")-or $boundParameters.ContainsKey("ExpectedBackupSha256")-or $boundParameters.ContainsKey("TargetBindingSha256")){Fail "backup parameters forbidden for Apply"}
        return
    }
    if($boundParameters.ContainsKey("RoutingProfilePath")){Fail "routing profile forbidden for Restore"}
    if(!$boundParameters.ContainsKey("BackupPath")-or !$boundParameters.ContainsKey("ExpectedBackupSha256")-or !$boundParameters.ContainsKey("TargetBindingSha256")){Fail "backup parameters required for Restore"}
    if([string]::IsNullOrEmpty($BackupPath)-or [string]::IsNullOrEmpty($ExpectedBackupSha256)-or [string]::IsNullOrEmpty($TargetBindingSha256)){Fail "backup parameters must be non-empty for Restore"}
}

function Invoke-ProductionApply {
    $script:SettingsPath=Get-Canonical $SettingsPath
    $script:RoutingProfilePath=Get-Canonical $RoutingProfilePath
    $script:SchemaPath=Get-Canonical $SchemaPath
    if(!(Test-Path -LiteralPath $script:SettingsPath -PathType Leaf)){Fail "target must pre-exist"}
    Assert-TrustedLeaf $script:RoutingProfilePath "routing profile"
    Assert-TrustedLeaf $script:SchemaPath "schema"
    Invoke-ClaudeRoutingApply -SettingsPath $script:SettingsPath -RoutingProfilePath $script:RoutingProfilePath -SchemaPath $script:SchemaPath -JsonOutput -TestFailureStage $TestFailureStage
}

function Invoke-ProductionRestore {
    $script:SettingsPath=Get-Canonical $SettingsPath
    $script:BackupPath=Get-Canonical $BackupPath
    $script:SchemaPath=Get-Canonical $SchemaPath
    if(!(Test-Path -LiteralPath $script:SettingsPath -PathType Leaf)){Fail "target must pre-exist"}
    Assert-TrustedLeaf $script:BackupPath "backup"
    Assert-TrustedLeaf $script:SchemaPath "schema"
    $computed=(Get-Canonical (Join-Path (Join-Path $script:ProfileRoot ".claude") "settings.json")).ToLowerInvariant().Replace('\','/').TrimEnd('/')
    $binding=[Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($computed))
    $bindingHex=([BitConverter]::ToString($binding)).Replace("-","").ToLowerInvariant()
    if($bindingHex-cne $TargetBindingSha256.ToLowerInvariant()){Fail "target binding mismatch"}
    Invoke-ClaudeRoutingRestore -SettingsPath $script:SettingsPath -BackupPath $script:BackupPath -SchemaPath $script:SchemaPath -ExpectedBackupSha256 $ExpectedBackupSha256 -TargetBindingSha256 $TargetBindingSha256 -JsonOutput -TestFailureStage $TestFailureStage
}

try{
    $script:ProfileRoot=(Get-Canonical $ProfileRoot).TrimEnd('\')
    $script:userProfile=(Get-Canonical $env:USERPROFILE).TrimEnd('\')
    if($script:ProfileRoot-ieq $script:userProfile-and !$AllowRealTarget){Fail "real profile execution locked until Gate 5 approval"}
    Assert-NoReparseComponent $script:ProfileRoot $script:userProfile
    $expected=Join-Path (Join-Path $script:ProfileRoot ".claude") "settings.json"
    if((Get-Canonical $SettingsPath)-cne (Get-Canonical $expected)){Fail "settings path must equal profile root claude settings target"}
    Assert-ParameterContract
    if($Operation-eq "Apply"){Invoke-ProductionApply}else{Invoke-ProductionRestore}
}catch{
    [Console]::Error.WriteLine("VALIDATION FAILED; "+$_.Exception.Message)
    exit 1
}
