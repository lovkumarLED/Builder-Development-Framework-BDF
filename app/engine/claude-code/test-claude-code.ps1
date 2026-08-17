$BuilderPath = Join-Path $PSScriptRoot "build-claude-code.ps1"
$CorePath = Join-Path $PSScriptRoot "claude-routing-core.psm1"
$ProductionPath = Join-Path $PSScriptRoot "build-claude-code-production.ps1"
$FixtureSource = Join-Path $PSScriptRoot "fixtures"
$SchemaSource = Join-Path (Split-Path $PSScriptRoot -Parent) "schemas\claude-code-routing.schema.json"
$TestResults = @()

function New-TestRoot {
    $root = Join-Path ([IO.Path]::GetTempPath()) ("bdf-claude-gate2-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path (Join-Path $root "schemas") -Force | Out-Null
    return $root
}
function Remove-TestRoot { param([string]$Root) if ($Root -and (Test-Path -LiteralPath $Root)) { Remove-Item -LiteralPath $Root -Recurse -Force } }
function Write-JsonFile { param([string]$Root,[string]$Relative,[object]$Value) $path=Join-Path $Root $Relative; $dir=Split-Path $path -Parent; if (!(Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}; [IO.File]::WriteAllText($path,($Value|ConvertTo-Json -Depth 100),[Text.UTF8Encoding]::new($false)) }
function Write-RawFile { param([string]$Root,[string]$Relative,[string]$Text,[byte[]]$Prefix=$null) $path=Join-Path $Root $Relative; $dir=Split-Path $path -Parent; if (!(Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}; $body=[Text.UTF8Encoding]::new($false).GetBytes($Text); if($null-eq $Prefix){[IO.File]::WriteAllBytes($path,$body)}else{$out=New-Object byte[] ($Prefix.Length+$body.Length);[Array]::Copy($Prefix,0,$out,0,$Prefix.Length);[Array]::Copy($body,0,$out,$Prefix.Length,$body.Length);[IO.File]::WriteAllBytes($path,$out)} }
function Assert-True { param([bool]$Condition,[string]$Message) if (!$Condition){throw $Message} }
function Run-Test { param([string]$Name,[scriptblock]$Body) try { & $Body; $script:TestResults += [pscustomobject]@{Name=$Name;Result="PASS"}; Write-Host "[+] $Name" } catch { $script:TestResults += [pscustomobject]@{Name=$Name;Result="FAIL"}; Write-Host "[x] $Name - $($_.Exception.Message)" } }
function Initialize-Root { param([string]$Root,[string]$Settings="settings-preservation.json",[string]$Routing="routing-api-key.json") Copy-Item (Join-Path $FixtureSource $Settings) (Join-Path $Root "settings.json"); Copy-Item (Join-Path $FixtureSource $Routing) (Join-Path $Root "routing.json"); Copy-Item $SchemaSource (Join-Path $Root "schemas\claude-code-routing.schema.json") }
function Invoke-Builder { param([string]$Root,[string]$RoutingPath=(Join-Path $Root "routing.json"),[string]$SettingsPath=(Join-Path $Root "settings.json"),[string]$SchemaPath=(Join-Path $Root "schemas\claude-code-routing.schema.json"),[string]$Failure="None",[string]$Builder=$BuilderPath) $output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Builder -FixtureRoot $Root -RoutingProfilePath $RoutingPath -SettingsPath $SettingsPath -SchemaPath $SchemaPath -TestFailureStage $Failure 2>&1 | Out-String; [pscustomobject]@{Code=$LASTEXITCODE;Output=$output} }

function Get-Hash { param([string]$Path) (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash }
function Assert-CleanRejection { param([string]$Root,[scriptblock]$Arrange,[string]$Label)
    Initialize-Root $Root; & $Arrange $Root
    $target=Join-Path $Root "settings.json"; $before=if(Test-Path $target){Get-Hash $target}else{"missing"}
    $result=Invoke-Builder $Root
    $after=if(Test-Path $target){Get-Hash $target}else{"missing"}
    Assert-True ($result.Code-ne 0) "$Label accepted"
    Assert-True ($result.Output-match "VALIDATION") "$Label omitted stage"
    Assert-True ($before-eq $after) "$Label changed target"
    Assert-True (@(Get-ChildItem $Root -File -Filter "settings.backup.*.json").Count-eq 0) "$Label created backup"
    Assert-True (@(Get-ChildItem $Root -File -Filter ".bdf-transaction-*.tmp").Count-eq 0) "$Label left temp"
    Assert-True (!$result.Output.Contains($env:BDF_CLAUDE_GATE2_API_KEY)) "$Label exposed value"
    Assert-True (!$result.Output.Contains($env:BDF_CLAUDE_GATE2_AUTH_TOKEN)) "$Label exposed token"
    Assert-True (!$result.Output.Contains("FAKE_EXISTING_SECRET_MARKER")) "$Label exposed existing marker"
}
function Set-Route { param([string]$Root,[scriptblock]$Change)
    $p=Get-Content (Join-Path $Root "routing.json") -Raw|ConvertFrom-Json; & $Change $p; Write-JsonFile $Root "routing.json" $p
}
function New-MutantWrapper { param([string]$Root,[string]$Name) $mutant=Join-Path $Root $Name; $wrapper=[IO.File]::ReadAllText($BuilderPath); [IO.File]::WriteAllText($mutant,$wrapper,[Text.UTF8Encoding]::new($false)); return $mutant }

$env:BDF_CLAUDE_GATE2_API_KEY="FAKE_GATE2_RUNTIME_VALUE_DO_NOT_USE"
$env:BDF_CLAUDE_GATE2_AUTH_TOKEN="FAKE_GATE2_RUNTIME_TOKEN_DO_NOT_USE"

Run-Test "G2-1 preservation fixture shape" {
    $o=Get-Content (Join-Path $FixtureSource "settings-preservation.json") -Raw|ConvertFrom-Json
    Assert-True ($null-ne $o.enabledPlugins) "enabled plugins missing"; Assert-True ($null-ne $o.extraKnownMarketplaces) "marketplace missing"
    Assert-True ($null-ne $o.mcpLikeData) "MCP-like data missing"; Assert-True ($o.unknownRoot.PSObject.Properties.Name-contains "nullValue") "null missing"
    Assert-True ($o.env.UNKNOWN_MARKER-eq "FAKE_EXISTING_SECRET_MARKER") "fake marker missing"
}
Run-Test "G2 safety non-temp root" { $outside=Join-Path ([Environment]::GetFolderPath("UserProfile")) ("."+"claude"); $r=Invoke-Builder -Root $outside -RoutingPath (Join-Path $outside "routing.json") -SettingsPath (Join-Path $outside "settings.json") -SchemaPath (Join-Path $outside "schema.json"); Assert-True ($r.Code-ne 0) "outside accepted"; Assert-True ($r.Output-match "VALIDATION") "stage absent" }
Run-Test "G2 safety escaped path before probe" { $root=New-TestRoot; try {Initialize-Root $root; $p=Join-Path (Split-Path $root -Parent) ("absent-"+[guid]::NewGuid().ToString("N")+".json"); $r=Invoke-Builder -Root $root -SettingsPath $p; Assert-True ($r.Code-ne 0) "escape accepted"; Assert-True (!(Test-Path $p)) "candidate appeared"}finally{Remove-TestRoot $root} }
Run-Test "G2 safety forbidden suffix" { $root=New-TestRoot; try {Initialize-Root $root; $p=Join-Path $root ("settings"+("."+"jsonc")); $r=Invoke-Builder -Root $root -SettingsPath $p; Assert-True ($r.Code-ne 0) "suffix accepted"; Assert-True (!(Test-Path $p)) "candidate appeared"}finally{Remove-TestRoot $root} }
Run-Test "G2 safety forbidden state filename" { $root=New-TestRoot; try {Initialize-Root $root; $p=Join-Path $root ("."+"claude"+".json"); $r=Invoke-Builder -Root $root -SettingsPath $p; Assert-True ($r.Code-ne 0) "state name accepted"; Assert-True (!(Test-Path $p)) "candidate appeared"}finally{Remove-TestRoot $root} }
Run-Test "G2 safety missing target" { $root=New-TestRoot; try {Initialize-Root $root; Remove-Item (Join-Path $root "settings.json"); $r=Invoke-Builder $root; Assert-True ($r.Code-ne 0) "missing accepted"; Assert-True ($r.Output-match "VALIDATION") "stage absent"}finally{Remove-TestRoot $root} }
Run-Test "G2 safety reparse ancestor rejected before descendant probe" { $base=New-TestRoot; try { $actual=Join-Path $base "actual"; $fixture=Join-Path $actual "fixture"; New-Item -ItemType Directory -Path (Join-Path $fixture "schemas") -Force|Out-Null; Initialize-Root $fixture; $link=Join-Path $base "junction"; New-Item -ItemType Junction -Path $link -Target $actual|Out-Null; $lexical=Join-Path $link "fixture"; $r=Invoke-Builder -Root $lexical; Assert-True ($r.Code-ne 0) "reparse ancestor accepted"; Assert-True ($r.Output-match "VALIDATION") "stage absent"; Assert-True (@(Get-ChildItem $fixture -Filter "settings.backup.*.json").Count-eq 0) "backup created through reparse" }finally{Remove-TestRoot $base} }

$validationCases=@(
 @("G2 validation malformed routing",{param($r) [IO.File]::WriteAllText((Join-Path $r "routing.json"),'{"target":',[Text.UTF8Encoding]::new($false))}),
 @("G2-5 malformed settings",{param($r) Copy-Item (Join-Path $FixtureSource "settings-malformed.json") (Join-Path $r "settings.json") -Force}),
 @("G2-5 duplicate keys",{param($r) $raw=Get-Content (Join-Path $FixtureSource "settings-duplicate-key.json") -Raw; Assert-True ([regex]::Matches($raw,'(?m)^\s*"duplicateProbe"\s*:').Count-eq 2) "lexical duplicate count"; Copy-Item (Join-Path $FixtureSource "settings-duplicate-key.json") (Join-Path $r "settings.json") -Force}),
 @("G2-5 escaped equivalent duplicate keys",{param($r) [IO.File]::WriteAllText((Join-Path $r "settings.json"),'{"model":"old","env":{},"same":1,"\u0073ame":2}',[Text.UTF8Encoding]::new($false))}),
 @("G2 validation unsupported target",{param($r) Set-Route $r {$args[0].target="other"}}),
 @("G2 validation unknown routing property",{param($r) Set-Route $r {$args[0]|Add-Member unexpected "value"}}),
 @("G2-5 unsupported scope",{param($r) Set-Route $r {$args[0].scope="project"}}),
 @("G2-3 both auth",{param($r) Set-Route $r {$args[0].endpoint.auth|Add-Member authTokenSecretRef "BDF_CLAUDE_GATE2_AUTH_TOKEN"}}),
 @("G2-3 neither auth",{param($r) Set-Route $r {$args[0].endpoint.auth.PSObject.Properties.Remove("apiKeySecretRef")}}),
 @("G2 validation bad secret ref",{param($r) Set-Route $r {$args[0].endpoint.auth.apiKeySecretRef="BAD-REF"}}),
 @("G2 validation missing secret",{param($r) Set-Route $r {$args[0].endpoint.auth.apiKeySecretRef="BDF_GATE2_MISSING_VALUE"}}),
 @("G2-5 invalid URL relative",{param($r) Set-Route $r {$args[0].endpoint.baseUrl="relative/path"}}),
 @("G2 validation invalid URL scheme",{param($r) Set-Route $r {$args[0].endpoint.baseUrl="ftp://fixture.invalid"}}),
 @("G2 validation URL userinfo",{param($r) Set-Route $r {$args[0].endpoint.baseUrl="https://user@fixture.invalid"}}),
 @("G2 validation URL query",{param($r) Set-Route $r {$args[0].endpoint.baseUrl="https://fixture.invalid/?x=1"}}),
 @("G2-5 invalid model whitespace",{param($r) Set-Route $r {$args[0].model.value=" "}}),
 @("G2 validation model wrong type",{param($r) Set-Route $r {$args[0].model.value=12}}),
 @("G2 validation model source",{param($r) Set-Route $r {$args[0].model.source="file"}}),
 @("G2-4 compact below",{param($r) Set-Route $r {$args[0].envPolicy.autoCompactWindow=99999}}),
 @("G2-4 compact above",{param($r) Set-Route $r {$args[0].envPolicy.autoCompactWindow=1000001}}),
 @("G2-4 compact decimal",{param($r) Set-Route $r {$args[0].envPolicy.autoCompactWindow=190000.5}}),
 @("G2-4 compact string",{param($r) Set-Route $r {$args[0].envPolicy.autoCompactWindow="190000"}})
)
foreach($case in $validationCases){ $name=$case[0]; $arrange=$case[1]; Run-Test $name { $root=New-TestRoot; try {Assert-CleanRejection $root $arrange $name}finally{Remove-TestRoot $root} }.GetNewClosure() }

Run-Test "G2-2 API key semantic patch and lower bound" { $root=New-TestRoot; try {Initialize-Root $root; Set-Route $root {$args[0].envPolicy.autoCompactWindow=100000}; $before=Get-Content (Join-Path $root "settings.json") -Raw; $r=Invoke-Builder $root; Assert-True ($r.Code-eq 0) "build failed"; $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json; Assert-True ($o.env.ANTHROPIC_API_KEY-eq $env:BDF_CLAUDE_GATE2_API_KEY) "API auth mismatch"; Assert-True (!($o.env.PSObject.Properties.Name-contains "ANTHROPIC_AUTH_TOKEN")) "opposite auth remains"; Assert-True ($o.model-eq "old/model") "top-level model changed"; Assert-True ($o.env.ANTHROPIC_MODEL-eq "gateway/native-model-id") "env model mismatch"; Assert-True ($o.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW-eq "100000") "compact mismatch"; Assert-True ($o.env.CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY-eq "1") "discovery mismatch"; Assert-True ($o.env.CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS-eq "1") "beta mismatch"; Assert-True (!($o.env.PSObject.Properties.Name-contains "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC")) "traffic off remained"; Assert-True ($o.unknownRoot.array[0]-eq "first") "unknown root changed"; Assert-True ($o.env.UNKNOWN_NESTED.array[0]-eq 3) "unknown env changed"; $backs=@(Get-ChildItem (Join-Path $root "backup") -File -Filter "settings.backup.*.json"); Assert-True ($backs.Count-eq 1) "backup count"; Assert-True ((Get-Hash $backs[0].FullName)-eq ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($before))).Replace("-",""))) "backup mismatch"; Assert-True (!$r.Output.Contains($env:BDF_CLAUDE_GATE2_API_KEY)) "output exposed value" }finally{Remove-TestRoot $root} }
Run-Test "G2-3 auth token semantic patch and upper bound" { $root=New-TestRoot; try {Initialize-Root $root -Routing "routing-auth-token.json"; $r=Invoke-Builder $root; Assert-True ($r.Code-eq 0) "build failed"; $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json; Assert-True ($o.env.ANTHROPIC_AUTH_TOKEN-eq $env:BDF_CLAUDE_GATE2_AUTH_TOKEN) "token mismatch"; Assert-True (!($o.env.PSObject.Properties.Name-contains "ANTHROPIC_API_KEY")) "opposite remains"; Assert-True ($o.env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC-eq "1") "traffic true mismatch"; Assert-True (!($o.env.PSObject.Properties.Name-contains "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY")) "discovery false remained"; Assert-True ($o.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW-eq "1000000") "upper mismatch"; foreach($secret in @($env:BDF_CLAUDE_GATE2_API_KEY,$env:BDF_CLAUDE_GATE2_AUTH_TOKEN,"FAKE_EXISTING_SECRET_MARKER")){Assert-True (!$r.Output.Contains($secret)) "bearer output exposed marker"} }finally{Remove-TestRoot $root} }
Run-Test "G2-4 middle compact and all policy flags absent" { $root=New-TestRoot; try {Initialize-Root $root; Set-Route $root {$args[0].envPolicy.gatewayDiscovery=$false;$args[0].envPolicy.disableExperimentalBetas=$false;$args[0].envPolicy.disableNonessentialTraffic=$false;$args[0].envPolicy.autoCompactWindow=190000}; $r=Invoke-Builder $root; Assert-True ($r.Code-eq 0) "build failed"; $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json; Assert-True ($o.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW-eq "190000") "middle mismatch"; foreach($n in @("CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY","CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS","CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC")){Assert-True (!($o.env.PSObject.Properties.Name-contains $n)) "off policy remained"} }finally{Remove-TestRoot $root} }
Run-Test "G2 schema is authoritative" { $root=New-TestRoot; try {Initialize-Root $root; $schema=Get-Content (Join-Path $root "schemas\claude-code-routing.schema.json") -Raw|ConvertFrom-Json; $schema.properties.target|Add-Member enum @("never-match"); Write-JsonFile $root "schemas\claude-code-routing.schema.json" $schema; $before=Get-Hash (Join-Path $root "settings.json"); $r=Invoke-Builder $root; Assert-True ($r.Code-ne 0) "schema violation accepted"; Assert-True ($r.Output-match "VALIDATION") "stage absent"; Assert-True ((Get-Hash (Join-Path $root "settings.json"))-eq $before) "schema rejection mutated target"; Assert-True (@(Get-ChildItem $root -Filter "settings.backup.*.json").Count-eq 0) "schema rejection created backup" }finally{Remove-TestRoot $root} }
Run-Test "G2 supported contract verifier rejects corrupt policy output" { $root=New-TestRoot; try {Initialize-Root $root; $mutant=New-MutantWrapper $root "mutant-builder.ps1"; $mutantCore=Join-Path $root "claude-routing-core.psm1"; $source=[IO.File]::ReadAllText($CorePath); $needle='function Verify-Contract { param([object]$Settings,[object]$Route,[object]$Auth,[string]$Unsupported)'; $replacement=$needle+"`r`n    if(`$Settings.env.PSObject.Properties['CLAUDE_CODE_AUTO_COMPACT_WINDOW']){`$Settings.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW='999999'}"; Assert-True ($source.Contains($needle)) "mutation seam absent"; [IO.File]::WriteAllText($mutantCore,$source.Replace($needle,$replacement),[Text.UTF8Encoding]::new($false)); $before=Get-Hash (Join-Path $root "settings.json"); $r=Invoke-Builder -Root $root -Builder $mutant; Assert-True ($r.Code-ne 0) "corrupt managed output verified"; Assert-True ((Get-Hash (Join-Path $root "settings.json"))-eq $before) "corrupt output replaced target" }finally{Remove-TestRoot $root} }
Run-Test "G2 replacement bookkeeping is conservative" { $source=[IO.File]::ReadAllText($CorePath); $replaceIndex=$source.IndexOf('[IO.File]::Replace($tempPath,$SettingsPath,$discard)'); $changedIndex=$source.IndexOf('$targetMayHaveChanged=$true'); Assert-True ($replaceIndex-ge 0-and $changedIndex-ge 0-and $changedIndex-lt $replaceIndex) "replacement bookkeeping follows replacement" }
Run-Test "G2 replacement boundary cleanup failure restores target" { $root=New-TestRoot; try {Initialize-Root $root; $mutant=New-MutantWrapper $root "boundary-builder.ps1"; $mutantCore=Join-Path $root "claude-routing-core.psm1"; $source=[IO.File]::ReadAllText($CorePath); $needle='[IO.File]::Replace($tempPath,$SettingsPath,$discard); if(Test-Path $discard){Remove-Item $discard -Force}' ; $replacement='[IO.File]::Replace($tempPath,$SettingsPath,$discard); throw "synthetic boundary cleanup failure"'; Assert-True ($source.Contains($needle)) "boundary seam absent"; [IO.File]::WriteAllText($mutantCore,$source.Replace($needle,$replacement),[Text.UTF8Encoding]::new($false)); $target=Join-Path $root "settings.json"; $before=Get-Hash $target; $r=Invoke-Builder -Root $root -Builder $mutant; Assert-True ($r.Code-ne 0) "boundary fault succeeded"; Assert-True ((Get-Hash $target)-eq $before) "boundary fault did not restore"; Assert-True ($r.Output-match "RECOVERY VERIFIED") "boundary recovery absent" }finally{Remove-TestRoot $root} }

Run-Test "G2-6 wrapper imports shared core" { Assert-True (Test-Path -LiteralPath $CorePath -PathType Leaf) "core module missing"; $wrapper=[IO.File]::ReadAllText($BuilderPath); Assert-True ($wrapper.Contains("claude-routing-core.psm1")) "wrapper does not reference core" }
Run-Test "G2-6 wrapper CLI contract preserved" { $out=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $BuilderPath 2>&1 | Out-String; Assert-True ($LASTEXITCODE-ne 0) "wrapper accepted missing mandatory parameters" }
Run-Test "G2-6 wrapper temp boundary preserved" { $wrapper=[IO.File]::ReadAllText($BuilderPath); Assert-True ($wrapper.Contains("GetTempPath")) "temp boundary check absent from wrapper"; $outside=Join-Path ([Environment]::GetFolderPath("UserProfile")) ("."+"claude"); $r=Invoke-Builder -Root $outside -RoutingPath (Join-Path $outside "routing.json") -SettingsPath (Join-Path $outside "settings.json") -SchemaPath (Join-Path $outside "schema.json"); Assert-True ($r.Code-ne 0) "outside accepted"; Assert-True ($r.Output-match "VALIDATION") "stage absent" }
Run-Test "G2-6 core module static safety" { foreach($p in @($CorePath,$ProductionPath)){ Assert-True (Test-Path -LiteralPath $p -PathType Leaf) "artifact missing: $p"; $bytes=[IO.File]::ReadAllBytes($p); Assert-True (!($bytes|Where-Object {$_-gt 127})) "non-ASCII core"; $text=[IO.File]::ReadAllText($p); $patterns=@('sk-[A-Za-z0-9]{12,}','Bearer\s+[A-Za-z0-9._-]{12,}','[A-Za-z]:\\Users\\[^\\]+\\\.claude(?:\\|\.json)',('\.'+'claude'+'\.json'),('\.'+'jsonc')); foreach($pattern in $patterns){Assert-True ($text-notmatch $pattern) "prohibited core pattern"} } }
Run-Test "G2-6 wrapper mutant references core safely" { $root=New-TestRoot; try {Initialize-Root $root; $mutant=New-MutantWrapper $root "isolated-builder.ps1"; $before=Get-Hash (Join-Path $root "settings.json"); $r=Invoke-Builder -Root $root -Builder $mutant; Assert-True ($r.Code-ne 0) "wrapper without core accepted"; Assert-True ($r.Output-match "VALIDATION") "core-missing failure not reported"; Assert-True ((Get-Hash (Join-Path $root "settings.json"))-eq $before) "core-missing mutated target"; Copy-Item $CorePath (Join-Path $root "claude-routing-core.psm1"); $r2=Invoke-Builder -Root $root -Builder $mutant; Assert-True ($r2.Code-eq 0) "wrapper with copied core failed" }finally{Remove-TestRoot $root} }

function Invoke-CoreApply { param([string]$Root,[string]$CoreModule) $settings=Join-Path $Root "settings.json"; $routing=Join-Path $Root "routing.json"; $schema=Join-Path $Root "schemas\claude-code-routing.schema.json"; $cmd="Import-Module '"+$CoreModule+"' -Force -DisableNameChecking; Invoke-ClaudeRoutingApply -SettingsPath '"+$settings+"' -RoutingProfilePath '"+$routing+"' -SchemaPath '"+$schema+"' -JsonOutput"; $output=& powershell.exe -NoProfile -Command $cmd 2>&1 | Out-String; [pscustomobject]@{Code=$LASTEXITCODE;Output=$output} }
Run-Test "G2-6 core verify-contract seam rejects corrupt output" { $root=New-TestRoot; try {Initialize-Root $root; $mutantCore=Join-Path $root "claude-routing-core.psm1"; $source=[IO.File]::ReadAllText($CorePath); $needle='function Verify-Contract { param([object]$Settings,[object]$Route,[object]$Auth,[string]$Unsupported)'; $replacement=$needle+"`r`n    if(`$Settings.env.PSObject.Properties['CLAUDE_CODE_AUTO_COMPACT_WINDOW']){`$Settings.env.CLAUDE_CODE_AUTO_COMPACT_WINDOW='999999'}"; Assert-True ($source.Contains($needle)) "mutation seam absent"; [IO.File]::WriteAllText($mutantCore,$source.Replace($needle,$replacement),[Text.UTF8Encoding]::new($false)); $before=Get-Hash (Join-Path $root "settings.json"); $r=Invoke-CoreApply $root $mutantCore; Assert-True ($r.Code-ne 0) "corrupt core output verified"; Assert-True ((Get-Hash (Join-Path $root "settings.json"))-eq $before) "corrupt core output replaced target"; Assert-True (!$r.Output.Contains($env:BDF_CLAUDE_GATE2_API_KEY)) "core output exposed value" }finally{Remove-TestRoot $root} }
Run-Test "G2-6 core replacement bookkeeping is conservative" { $source=[IO.File]::ReadAllText($CorePath); $replaceIndex=$source.IndexOf('[IO.File]::Replace($tempPath,$SettingsPath,$discard)'); $changedIndex=$source.IndexOf('$targetMayHaveChanged=$true'); Assert-True ($replaceIndex-ge 0-and $changedIndex-ge 0-and $changedIndex-lt $replaceIndex) "core bookkeeping follows replacement" }
Run-Test "G2-6 core boundary cleanup failure restores target" { $root=New-TestRoot; try {Initialize-Root $root; $mutantCore=Join-Path $root "claude-routing-core.psm1"; $source=[IO.File]::ReadAllText($CorePath); $needle='[IO.File]::Replace($tempPath,$SettingsPath,$discard); if(Test-Path $discard){Remove-Item $discard -Force}' ; $replacement='[IO.File]::Replace($tempPath,$SettingsPath,$discard); throw "synthetic boundary cleanup failure"'; Assert-True ($source.Contains($needle)) "boundary seam absent"; [IO.File]::WriteAllText($mutantCore,$source.Replace($needle,$replacement),[Text.UTF8Encoding]::new($false)); $target=Join-Path $root "settings.json"; $before=Get-Hash $target; $r=Invoke-CoreApply $root $mutantCore; Assert-True ($r.Code-ne 0) "core boundary fault succeeded"; Assert-True ((Get-Hash $target)-eq $before) "core boundary fault did not restore"; Assert-True ($r.Output-match "RECOVERY VERIFIED") "core boundary recovery absent" }finally{Remove-TestRoot $root} }

foreach($routing in @("routing-api-key.json","routing-auth-token.json")){foreach($stage in @("AfterBackup","AfterTempWrite","AfterReplace")){ Run-Test ("G2-5 recovery "+$routing+" "+$stage) { $root=New-TestRoot; try {Initialize-Root $root -Routing $routing; $target=Join-Path $root "settings.json"; $before=Get-Hash $target; $r=Invoke-Builder -Root $root -Failure $stage; Assert-True ($r.Code-ne 0) "fault succeeded"; Assert-True ((Get-Hash $target)-eq $before) "target not restored"; Get-Content $target -Raw|ConvertFrom-Json|Out-Null; Assert-True (@(Get-ChildItem (Join-Path $root "backup") -File -Filter "settings.backup.*.json").Count-eq 1) "backup absent"; Assert-True (@(Get-ChildItem $root -File -Filter ".bdf-transaction-*.tmp").Count-eq 0) "stale temp"; Assert-True ($r.Output-match "RECOVERY VERIFIED") "recovery not reported"; foreach($secret in @($env:BDF_CLAUDE_GATE2_API_KEY,$env:BDF_CLAUDE_GATE2_AUTH_TOKEN,"FAKE_EXISTING_SECRET_MARKER")){Assert-True (!$r.Output.Contains($secret)) "recovery output exposed marker"} }finally{Remove-TestRoot $root} }.GetNewClosure() }}

function Initialize-RawRoot { param([string]$Root,[string]$RawText,[string]$Routing="routing-api-key.json",[byte[]]$Prefix=$null) Write-RawFile $Root "settings.json" $RawText $Prefix; Copy-Item (Join-Path $FixtureSource $Routing) (Join-Path $Root "routing.json"); Copy-Item $SchemaSource (Join-Path $Root "schemas\claude-code-routing.schema.json") }
function Assert-RawManaged { param([string]$Root,[string[]]$Present=@(),[string[]]$Absent=@(),[hashtable]$Values=@{})
    $o=Get-Content (Join-Path $Root "settings.json") -Raw|ConvertFrom-Json
    foreach($name in $Present){Assert-True ($null-ne $o.env.PSObject.Properties[$name]) "missing managed: $name"}
    foreach($name in $Absent){Assert-True ($null-eq $o.env.PSObject.Properties[$name]) "present managed: $name"}
    foreach($key in $Values.Keys){Assert-True (($o.env.$key)-eq $Values[$key]) "value mismatch: $key"}
}

Run-Test "G2-7 env-only model precedence" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1" } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json
    Assert-True ($o.model-eq "old/model") "top-level model changed"
    Assert-True ($o.env.ANTHROPIC_MODEL-eq "gateway/native-model-id") "env model missing"
    Assert-True ($o.env.ANTHROPIC_BASE_URL-eq "http://127.0.0.1:20128/v1") "base URL mismatch"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 root bytes preserved" { $root=New-TestRoot; try {
    $raw='{ "model"  :  "old/model"  ,  "theme"  :  { "x"  :  1e2  ,  "n"  :  0.50  ,  "esc"  :  "\u0061\u0062"  }  ,  "env"  :  {  "ANTHROPIC_BASE_URL"  :  "http://old.invalid/v1"  }  }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"model"  :  "old/model"')) "model bytes changed"
    Assert-True ($out.Contains('"theme"  :  { "x"  :  1e2  ,  "n"  :  0.50  ,  "esc"  :  "\u0061\u0062"  }')) "theme bytes changed"
    Assert-True ($out.IndexOf('"theme"')-lt $out.IndexOf('"env"')) "root order changed"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 unmanaged env bytes preserved" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1", "Odd Key"  :  "va\u006cue"  ,  "another"  :  42  } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"Odd Key"  :  "va\u006cue"  ,  "another"  :  42')) "unmanaged env bytes changed"
    $o=$out|ConvertFrom-Json
    Assert-True ($o.env.'Odd Key'-eq "value") "unmanaged value changed"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 existing managed replacements surgical" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1", "ANTHROPIC_API_KEY": "old-secret", "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "150000" } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"ANTHROPIC_BASE_URL": "http://127.0.0.1:20128/v1"')) "base URL value not replaced in place"
    Assert-True ($out.Contains('"ANTHROPIC_API_KEY": "FAKE_GATE2_RUNTIME_VALUE_DO_NOT_USE"')) "API key not replaced"
    Assert-True ($out.Contains('"CLAUDE_CODE_AUTO_COMPACT_WINDOW": "190000"')) "compact not replaced"
    Assert-True ($out.Contains('"model": "old/model"')) "model changed"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 missing managed insertions surgical" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1" } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    Assert-RawManaged $root -Present @("ANTHROPIC_API_KEY","ANTHROPIC_MODEL","CLAUDE_CODE_AUTO_COMPACT_WINDOW","CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY","CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS") -Absent @("CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC")
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"ANTHROPIC_BASE_URL": "http://old.invalid/v1"')-eq $false) "base URL not replaced"
    Assert-True ($out.Contains('"ANTHROPIC_BASE_URL": "http://127.0.0.1:20128/v1"')) "base URL missing"
    Assert-True ($out.IndexOf('"ANTHROPIC_BASE_URL"')-lt $out.IndexOf('"ANTHROPIC_MODEL"')) "insertion reordered existing member"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 missing env insertion surgical" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "theme": { "x": 1 } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"model": "old/model"')) "model changed"
    Assert-True ($out.Contains('"theme": { "x": 1 }')) "theme changed"
    $o=$out|ConvertFrom-Json
    Assert-True ($null-ne $o.env) "env not inserted"
    Assert-True ($o.env.ANTHROPIC_MODEL-eq "gateway/native-model-id") "env model missing"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 disabled-option removal surgical" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1", "ANTHROPIC_API_KEY": "old-secret", "CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1", "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1", "KeepMe": "x" } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"KeepMe": "x"')) "unrelated member changed"
    Assert-True ($out.Contains('"CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY": "1"')) "enabled discovery removed"
    Assert-RawManaged $root -Absent @("CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC")
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 opposite auth removal surgical" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1", "ANTHROPIC_API_KEY": "old-secret", "ANTHROPIC_AUTH_TOKEN": "old-token", "KeepMe": 7 } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"KeepMe": 7')) "unrelated env member changed"
    Assert-True ($out.Contains('"ANTHROPIC_API_KEY": "FAKE_GATE2_RUNTIME_VALUE_DO_NOT_USE"')) "selected auth not set"
    Assert-True (!($out.Contains("old-token"))) "opposite auth value remained"
    Assert-RawManaged $root -Absent @("ANTHROPIC_AUTH_TOKEN")
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 UTF-8 BOM preserved" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1" } }'
    $bom=[byte[]]@(0xEF,0xBB,0xBF)
    Initialize-RawRoot $root $raw -Prefix $bom
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $bytes=[IO.File]::ReadAllBytes((Join-Path $root "settings.json"))
    Assert-True ($bytes.Length-ge 3-and $bytes[0]-eq 0xEF-and $bytes[1]-eq 0xBB-and $bytes[2]-eq 0xBF) "BOM lost"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 LF CRLF indentation and trailing-newline forms preserved" { $root=New-TestRoot; try {
    foreach($case in @(
        @{Name="LF";Raw="{
  ""model"": ""old/model"",
  ""env"": {
    ""ANTHROPIC_BASE_URL"": ""http://old.invalid/v1""
  }
}
"},
        @{Name="CRLF";Raw="{
  ""model"": ""old/model"",
  ""env"": {
    ""ANTHROPIC_BASE_URL"": ""http://old.invalid/v1""
  }
}
"},
        @{Name="NoTrailingNewline";Raw="{
  ""model"": ""old/model"",
  ""env"": {
    ""ANTHROPIC_BASE_URL"": ""http://old.invalid/v1""
  }
}"}
    )){
        $raw=($case.Raw -replace "`r`n","`n")
        if($case.Name-eq "CRLF"){$raw=$raw -replace "`n","`r`n"}
        $subRoot=New-TestRoot
        try{
            Initialize-RawRoot $subRoot $raw
            $r=Invoke-Builder $subRoot
            Assert-True ($r.Code-eq 0) ("build failed: "+$case.Name)
            $out=Get-Content (Join-Path $subRoot "settings.json") -Raw
            if($case.Name-eq "CRLF"){Assert-True ($out.Contains("`r`n")) "CRLF lost"}
            elseif($case.Name-eq "LF"){Assert-True ($out.Contains("`n")-and !($out.Contains("`r"))) "LF lost"}
            if($case.Name-ne "NoTrailingNewline"){Assert-True ($out.EndsWith("`n")) "trailing newline lost"}
            else{Assert-True (!($out.EndsWith("`n"))) "trailing newline added"}
            Assert-True ($out.Contains('  "model": "old/model"')) "indent lost"
        }finally{Remove-TestRoot $subRoot}
    }
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 conflict rejected before backup" { $root=New-TestRoot; try {
    Initialize-Root $root
    Set-Route $root {$args[0].envPolicy.gatewayDiscovery=$true;$args[0].envPolicy.disableNonessentialTraffic=$true}
    $target=Join-Path $root "settings.json"
    $before=Get-Hash $target
    $r=Invoke-Builder $root
    Assert-True ($r.Code-ne 0) "conflict accepted"
    Assert-True ($r.Output-match "VALIDATION") "conflict omitted stage"
    Assert-True ((Get-Hash $target)-eq $before) "conflict changed target"
    Assert-True (@(Get-ChildItem $root -File -Filter "settings.backup.*.json").Count-eq 0) "conflict created backup"
    Assert-True (@(Get-ChildItem $root -File -Filter ".bdf-transaction-*.tmp").Count-eq 0) "conflict left temp"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 top-level model corruption detected" { $root=New-TestRoot; try {
    Initialize-Root $root
    $mutant=New-MutantWrapper $root "model-mutant-builder.ps1"
    $mutantCore=Join-Path $root "claude-routing-core.psm1"
    $source=[IO.File]::ReadAllText($CorePath)
    $needle='$newText=Apply-SettingsTextEdits -Raw $settingsDoc.RawText -Edits $allEdits'
    $injection='`r`n        `$newText=`$newText.Replace([char]34+''old/model''+[char]34,[char]34+''hacked-model''+[char]34)'
    $replacement=$needle+$injection
    Assert-True ($source.Contains($needle)) "model seam absent"
    [IO.File]::WriteAllText($mutantCore,$source.Replace($needle,$replacement),[Text.UTF8Encoding]::new($false))
    $target=Join-Path $root "settings.json"
    $before=Get-Hash $target
    $r=Invoke-Builder -Root $root -Builder $mutant
    Assert-True ($r.Code-ne 0) "model corruption verified"
    Assert-True ((Get-Hash $target)-eq $before) "model corruption replaced target"
    $o=Get-Content $target -Raw|ConvertFrom-Json
    Assert-True ($o.model-eq "old/model") "model changed after recovery"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 unmanaged-byte corruption detected" { $root=New-TestRoot; try {
    Initialize-Root $root
    $mutant=New-MutantWrapper $root "unmanaged-mutant-builder.ps1"
    $mutantCore=Join-Path $root "claude-routing-core.psm1"
    $source=[IO.File]::ReadAllText($CorePath)
    $needle='$newText=Apply-SettingsTextEdits -Raw $settingsDoc.RawText -Edits $allEdits'
    $injection='`r`n        `$newText=`$newText.Replace(''preserve-me'',''corrupted'')'
    $replacement=$needle+$injection
    Assert-True ($source.Contains($needle)) "unmanaged seam absent"
    [IO.File]::WriteAllText($mutantCore,$source.Replace($needle,$replacement),[Text.UTF8Encoding]::new($false))
    $target=Join-Path $root "settings.json"
    $before=Get-Hash $target
    $r=Invoke-Builder -Root $root -Builder $mutant
    Assert-True ($r.Code-ne 0) "unmanaged corruption verified"
    Assert-True ((Get-Hash $target)-eq $before) "unmanaged corruption replaced target"
    $o=Get-Content $target -Raw|ConvertFrom-Json
    Assert-True ($o.env.UNKNOWN_TEXT-eq "preserve-me") "unmanaged value changed after recovery"
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 tier models applied" { $root=New-TestRoot; try {
    Initialize-Root $root
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    Assert-RawManaged $root -Values @{"ANTHROPIC_DEFAULT_OPUS_MODEL"="gateway/role-opus";"ANTHROPIC_DEFAULT_SONNET_MODEL"="gateway/role-sonnet";"ANTHROPIC_DEFAULT_HAIKU_MODEL"="gateway/role-haiku";"ANTHROPIC_DEFAULT_FABLE_MODEL"="gateway/role-fable"}
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 stale tier models removed" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1", "ANTHROPIC_DEFAULT_OPUS_MODEL": "stale/opus", "ANTHROPIC_DEFAULT_SONNET_MODEL": "stale/sonnet", "ANTHROPIC_DEFAULT_HAIKU_MODEL": "stale/haiku", "ANTHROPIC_DEFAULT_FABLE_MODEL": "stale/fable" } }'
    Initialize-RawRoot $root $raw "routing-auth-token.json"
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    Assert-RawManaged $root -Absent @("ANTHROPIC_DEFAULT_OPUS_MODEL","ANTHROPIC_DEFAULT_SONNET_MODEL","ANTHROPIC_DEFAULT_HAIKU_MODEL","ANTHROPIC_DEFAULT_FABLE_MODEL")
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 allowlist written" { $root=New-TestRoot; try {
    Initialize-Root $root
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json
    Assert-True ($o.enforceAvailableModels-eq $true) "enforce missing"
    Assert-True ((@($o.availableModels)-join '|')-eq "gateway/native-model-id|gateway/role-opus|gateway/role-sonnet|gateway/role-haiku|gateway/role-fable") "allowlist mismatch"
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 allowlist removed when off" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "availableModels": [ "old/a", "old/b" ], "enforceAvailableModels": true, "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1" } }'
    Initialize-RawRoot $root $raw "routing-auth-token.json"
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json
    Assert-True ($null-eq $o.PSObject.Properties["availableModels"]) "allowlist survived"
    Assert-True ($null-eq $o.PSObject.Properties["enforceAvailableModels"]) "enforce survived"
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 allowlist deduplicated" { $root=New-TestRoot; try {
    Initialize-Root $root
    Set-Route $root { $args[0].modelRoles.opus=$args[0].model.value }
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $o=Get-Content (Join-Path $root "settings.json") -Raw|ConvertFrom-Json
    Assert-True ((@($o.availableModels)-join '|')-eq "gateway/native-model-id|gateway/role-sonnet|gateway/role-haiku|gateway/role-fable") "dedup mismatch"
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 auto-compact optional removed" { $root=New-TestRoot; try {
    Initialize-Root $root "settings-preservation.json" "routing-auth-token.json"
    Set-Route $root { $args[0].envPolicy.PSObject.Properties.Remove("autoCompactWindow") }
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    Assert-RawManaged $root -Absent @("CLAUDE_CODE_AUTO_COMPACT_WINDOW")
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 unknown role rejected" { $root=New-TestRoot; try {
    Initialize-Root $root
    Set-Route $root { $args[0].modelRoles|Add-Member extrasmart "gateway/extra" }
    $r=Invoke-Builder $root
    Assert-True ($r.Code-ne 0) "unknown role accepted"
    Assert-True ($r.Output-match "VALIDATION") "stage absent"
}finally{Remove-TestRoot $root} }

Run-Test "G2-8 allowlist surgical preserve" { $root=New-TestRoot; try {
    $raw='{ "model": "old/model", "theme": { "x": 1 }, "env": { "ANTHROPIC_BASE_URL": "http://old.invalid/v1" } }'
    Initialize-RawRoot $root $raw
    $r=Invoke-Builder $root
    Assert-True ($r.Code-eq 0) "build failed"
    $out=Get-Content (Join-Path $root "settings.json") -Raw
    Assert-True ($out.Contains('"theme": { "x": 1 }')) "unmanaged root bytes changed"
    Assert-True ($out.Contains('"availableModels"')) "allowlist missing"
    Assert-True ($out -match '"enforceAvailableModels"\s*:\s*true') "enforce missing"
    Assert-True ($out.IndexOf('"theme"')-lt $out.IndexOf('"availableModels"')) "root order changed"
}finally{Remove-TestRoot $root} }

Run-Test "G2-7 no full-document serializer" { $source=[IO.File]::ReadAllText($CorePath)
    Assert-True (!($source.Contains("Object|ConvertTo-Json"))) "settings-object ConvertTo-Json pipeline present"
    Assert-True (!($source.Contains("ConvertTo-Json -Depth"))) "full-document serializer present"
    Assert-True ($source.Contains("New-SettingsEnvEdits")) "surgical edit entry missing"
    Assert-True ($source.Contains("Apply-SettingsTextEdits")) "surgical apply entry missing"
    Assert-True ($source.Contains("Assert-SettingsTextPreserved")) "preservation assert missing"
}

Run-Test "G2 static source safety" { $paths=@($BuilderPath,$PSCommandPath,$SchemaSource,$CorePath,$ProductionPath)+@(Get-ChildItem $FixtureSource -Filter "*.json"|ForEach-Object FullName); Assert-True ($paths.Count-eq 10) "artifact count"; $patterns=@('sk-[A-Za-z0-9]{12,}','Bearer\s+[A-Za-z0-9._-]{12,}','[A-Za-z]:\\Users\\[^\\]+\\\.claude(?:\\|\.json)',('\.'+'claude'+'\.json'),('\.'+'jsonc')); foreach($p in $paths){$bytes=[IO.File]::ReadAllBytes($p); Assert-True (!($bytes|Where-Object {$_-gt 127})) "non-ASCII source"; $text=[IO.File]::ReadAllText($p); foreach($pattern in $patterns){Assert-True ($text-notmatch $pattern) "prohibited source pattern"}} }

$failed=@($TestResults|Where-Object Result -eq "FAIL")
Write-Host ("Summary: {0} passed, {1} failed" -f ($TestResults.Count-$failed.Count),$failed.Count)
if($failed.Count){exit 1}; exit 0
