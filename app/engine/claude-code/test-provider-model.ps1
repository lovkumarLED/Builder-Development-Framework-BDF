param(
    [Parameter(Mandatory=$true)][Alias('PythonExe')][ValidateNotNullOrEmpty()][string]$SuppliedPythonExe
)

$ErrorActionPreference='Stop'

function ConvertTo-WindowsCommandLineArgument {
    param([AllowEmptyString()][Parameter(Mandatory=$true)][string]$Value)
    if($Value.Length-eq 0){return '""'}
    if($Value-notmatch '[\s"]'){return $Value}
    $builder=New-Object Text.StringBuilder
    [void]$builder.Append('"')
    $slashes=0
    foreach($character in $Value.ToCharArray()){
        if($character-eq '\'){$slashes++;continue}
        if($character-eq '"'){
            $escapedSlashCount=($slashes*2)+1
            if($escapedSlashCount-gt 0){[void]$builder.Append((('\' * $escapedSlashCount)-join ''))}
            [void]$builder.Append('"')
            $slashes=0
            continue
        }
        if($slashes-gt 0){[void]$builder.Append((('\' * $slashes)-join ''));$slashes=0}
        [void]$builder.Append($character)
    }
    $trailingSlashCount=$slashes*2
    if($trailingSlashCount-gt 0){[void]$builder.Append((('\' * $trailingSlashCount)-join ''))}
    [void]$builder.Append('"')
    return $builder.ToString()
}

function Join-WindowsCommandLineArguments {
    param([AllowEmptyString()][Parameter(Mandatory=$true)][string[]]$Arguments)
    return (($Arguments|ForEach-Object{ConvertTo-WindowsCommandLineArgument -Value $_})-join ' ')
}

function Invoke-WithIsolatedPythonEnvironment {
    param([Parameter(Mandatory=$true)][scriptblock]$Body)
    $fixedNames=@('PYTHONPATH','PYTHONHOME','PYTHONNOUSERSITE','PYTHONDONTWRITEBYTECODE','HTTP_PROXY','HTTPS_PROXY','ALL_PROXY','http_proxy','https_proxy','all_proxy')
    $isolatedNames=@((Get-ChildItem Env:|Where-Object{$_.Name-like 'PYTHON*'}|ForEach-Object Name)+$fixedNames|Select-Object -Unique)
    $savedEnvironment=@{}
    foreach($name in $isolatedNames){
        if($savedEnvironment.ContainsKey($name)){continue}
        $savedEnvironment[$name]=[Environment]::GetEnvironmentVariable($name,'Process')
        [Environment]::SetEnvironmentVariable($name,$null,'Process')
    }
    try {
        [Environment]::SetEnvironmentVariable('PYTHONNOUSERSITE','1','Process')
        [Environment]::SetEnvironmentVariable('PYTHONDONTWRITEBYTECODE','1','Process')
        & $Body
    } finally {
        foreach($name in $isolatedNames){[Environment]::SetEnvironmentVariable($name,$savedEnvironment[$name],'Process')}
    }
}

function Invoke-Gate3Python {
    param(
        [Parameter(Mandatory=$true)][ValidateSet('Direct','Process')][string]$Mode,
        [AllowEmptyString()][Parameter(Mandatory=$true)][string[]]$Arguments
    )
    if($Arguments.Count-lt 2-or $Arguments[0]-cne '-I'-or $Arguments[1]-cne '-S'){throw 'Python isolation arguments missing'}
    if($Mode-eq 'Direct'){
        return Invoke-WithIsolatedPythonEnvironment { & $script:PythonExe @Arguments }
    }
    $serialized=Join-WindowsCommandLineArguments -Arguments $Arguments
    return Invoke-WithIsolatedPythonEnvironment {
        Start-Process -FilePath $script:PythonExe -ArgumentList $serialized -PassThru -WindowStyle Hidden
    }
}

if(![IO.Path]::IsPathRooted($SuppliedPythonExe)){throw 'PythonExe must be absolute'}
try{$canonicalPython=[IO.Path]::GetFullPath($SuppliedPythonExe)}catch{throw 'PythonExe path invalid'}
if(!(Test-Path -LiteralPath $canonicalPython -PathType Leaf)){throw 'PythonExe leaf missing'}
$pythonItem=Get-Item -LiteralPath $canonicalPython -Force
if($pythonItem.PSIsContainer-or (($pythonItem.Attributes-band [IO.FileAttributes]::ReparsePoint)-ne 0)){throw 'PythonExe leaf invalid'}
if($null-ne (Get-Variable -Name PythonExe -Scope Script -ErrorAction SilentlyContinue)){throw 'PythonExe already initialized'}
$script:PythonExe=$canonicalPython

$validationCode=@'
import ast, http.server, json, pathlib, signal, sys, threading
result = {
    'executable': str(pathlib.Path(sys.executable).resolve()),
    'isolated': sys.flags.isolated,
    'no_site': sys.flags.no_site,
    'no_user_site': sys.flags.no_user_site,
    'ignore_environment': sys.flags.ignore_environment,
    'site_loaded': 'site' in sys.modules,
    'stdlib_ok': True,
}
print(json.dumps(result, sort_keys=True, separators=(',', ':')))
'@
$validationOutput=@(Invoke-Gate3Python -Mode Direct -Arguments @('-I','-S','-c',$validationCode))
if($LASTEXITCODE-ne 0-or $validationOutput.Count-ne 1){throw 'Python child validation failed'}
try{$validation=$validationOutput[0]|ConvertFrom-Json}catch{throw 'Python child validation output invalid'}
try{$childExecutable=[IO.Path]::GetFullPath([string]$validation.executable)}catch{throw 'Python child executable invalid'}
if(!$childExecutable.Equals($script:PythonExe,[StringComparison]::OrdinalIgnoreCase)){throw 'Python child identity mismatch'}
if($validation.isolated-ne 1-or $validation.no_site-ne 1-or $validation.no_user_site-ne 1-or $validation.ignore_environment-ne 1-or $validation.site_loaded-ne $false-or $validation.stdlib_ok-ne $true){throw 'Python isolation or standard-library contract failed'}

$InspectorPath=Join-Path $PSScriptRoot 'inspect-provider-model.ps1'
$ServerSource=Join-Path $PSScriptRoot 'gate3-fixtures\fake-anthropic-gateway.py'
$ResponseSource=Join-Path $PSScriptRoot 'gate3-fixtures\gateway-models-response.json'
$BuilderPath=Join-Path $PSScriptRoot 'build-claude-code.ps1'
$Gate2FixtureSource=Join-Path $PSScriptRoot 'fixtures\settings-preservation.json'
$RoutingSource=Join-Path $PSScriptRoot 'fixtures\routing-api-key.json'
$SchemaSource=Join-Path (Split-Path $PSScriptRoot -Parent) 'schemas\claude-code-routing.schema.json'
$LoopbackPrefix='ht'+'tp://127.0.0.1'
$TestResults=@()
$Criteria=[ordered]@{'G3-1'=$true;'G3-2'=$true;'G3-3'=$true;'G3-4'=$true;'G3-5'=$true}

function Assert-True { param([bool]$Condition,[string]$Message) if(!$Condition){throw $Message} }
function Run-Test { param([string]$Name,[string]$Criterion,[scriptblock]$Body) try{& $Body;$script:TestResults+=[pscustomobject]@{Name=$Name;Result='PASS';Criterion=$Criterion};Write-Host "[+] $Name"}catch{$script:TestResults+=[pscustomobject]@{Name=$Name;Result='FAIL';Criterion=$Criterion;Reason=$_.Exception.Message};if($Criterion){$script:Criteria[$Criterion]=$false};Write-Host "[x] $Name - $($_.Exception.Message)"} }
function New-Root { param([string]$Prefix='bdf-claude-gate3-') $root=Join-Path ([IO.Path]::GetTempPath()) ($Prefix+[guid]::NewGuid().ToString('N'));New-Item -ItemType Directory -Path $root -Force|Out-Null;return $root }
function Remove-Root { param([string]$Root) if($Root-and (Test-Path -LiteralPath $Root)){Remove-Item -LiteralPath $Root -Recurse -Force} }
function Wait-Ready { param([Diagnostics.Process]$Process,[string]$Ready) $limit=[DateTime]::UtcNow.AddSeconds(5);while([DateTime]::UtcNow-lt $limit){if(Test-Path -LiteralPath $Ready){try{$text=[IO.File]::ReadAllText($Ready);if($text-match '^\d+$'){return [int]$text}}catch [IO.IOException]{}};$Process.Refresh();if($Process.HasExited){throw 'gateway exited before ready'};Start-Sleep -Milliseconds 50};throw 'gateway ready timeout' }
function Stop-Server { param([Diagnostics.Process]$Process,[int]$Port,[string]$Log) if(!$Process){return};if(!$Process.HasExited){$Process.CloseMainWindow()|Out-Null;if(!$Process.WaitForExit(2000)){$Process.Kill();$Process.WaitForExit()}};$Process.Refresh();Assert-True $Process.HasExited 'exact child did not exit';$probeLimit=[DateTime]::UtcNow.AddSeconds(2);$released=$false;while([DateTime]::UtcNow-lt $probeLimit){$listener=$null;try{$listener=New-Object Net.Sockets.TcpListener ([Net.IPAddress]::Parse('127.0.0.1')),$Port;$listener.Start();$released=$true;break}catch{Start-Sleep -Milliseconds 100}finally{if($listener){$listener.Stop()}}};Assert-True $released 'gateway port not released';if(Test-Path $Log){$stream=[IO.File]::Open($Log,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None);$stream.Dispose()} }
function Start-Server { param([string]$Root,[string]$Server,[string]$Response,[string]$Evidence,[string[]]$Extra=@()) $ready=Join-Path $Evidence 'ready file.txt';$log=Join-Path $Evidence 'request log.txt';$arguments=@('-I','-S',$Server,'--fixture-root',$Root,'--response-file',$Response,'--ready-file',$ready,'--request-log',$log)+$Extra;$process=$null;try{$process=Invoke-Gate3Python -Mode Process -Arguments $arguments;$port=Wait-Ready $process $ready;return [pscustomobject]@{Process=$process;Port=$port;Log=$log;Ready=$ready}}catch{if($process-and !$process.HasExited){$process.Kill();$process.WaitForExit()};throw} }
function Complete-ServerTestCleanup { param([string]$Root,[object]$ServerInfo,[scriptblock]$StopAction) try{if($ServerInfo){if($StopAction){& $StopAction $ServerInfo}else{Stop-Server $ServerInfo.Process $ServerInfo.Port $ServerInfo.Log}}}finally{Remove-Root $Root} }
function Write-Json { param([string]$Path,[object]$Value) [IO.File]::WriteAllText($Path,($Value|ConvertTo-Json -Depth 100),[Text.UTF8Encoding]::new($false)) }
function New-Pipeline { param([scriptblock]$SettingsChange,[scriptblock]$RouteChange)
    $root=New-Root;New-Item -ItemType Directory -Path (Join-Path $root 'schemas') -Force|Out-Null;Copy-Item $Gate2FixtureSource (Join-Path $root 'settings.json');Copy-Item $RoutingSource (Join-Path $root 'routing.json');Copy-Item $SchemaSource (Join-Path $root 'schemas\claude-code-routing.schema.json');$settings=[IO.File]::ReadAllText((Join-Path $root 'settings.json'))|ConvertFrom-Json;if($SettingsChange){& $SettingsChange $settings};Write-Json (Join-Path $root 'settings.json') $settings;$route=[IO.File]::ReadAllText((Join-Path $root 'routing.json'))|ConvertFrom-Json;if($RouteChange){& $RouteChange $route};Write-Json (Join-Path $root 'routing.json') $route;$env:BDF_CLAUDE_GATE2_API_KEY='FAKE_GATE3_SECRET_DO_NOT_USE';$build=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $BuilderPath -FixtureRoot $root -RoutingProfilePath (Join-Path $root 'routing.json') -SettingsPath (Join-Path $root 'settings.json') -SchemaPath (Join-Path $root 'schemas\claude-code-routing.schema.json') 2>&1|Out-String;Assert-True ($LASTEXITCODE-eq 0-and $build.Contains('SUCCESS POST-WRITE VERIFICATION')) 'Gate 2 pipeline failed';return $root
}
function Invoke-Inspector { param([string]$Root,[string]$Url,[int]$Timeout=2000,[string]$Settings='settings.json',[string]$Result='result.json') $output=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $InspectorPath -FixtureRoot $Root -SettingsPath (Join-Path $Root $Settings) -GatewayBaseUrl $Url -ResultPath (Join-Path $Root $Result) -TimeoutMs $Timeout 2>&1|Out-String;[pscustomobject]@{Code=$LASTEXITCODE;Output=$output;Path=(Join-Path $Root $Result)} }
function Request-Count { param([string]$Path) if(Test-Path $Path){return @([IO.File]::ReadAllLines($Path)).Count};return 0 }

Run-Test 'Python initialization and child isolation' '' { Assert-True ($validation.stdlib_ok-eq $true) 'validation absent' }
Run-Test 'PowerShell argument serializer static contract' '' {
    $source=[IO.File]::ReadAllText($PSCommandPath)
    $assignmentLine='$script:'+'PythonExe=$canonicalPython';Assert-True (@($source-split "`r?`n"|Where-Object{$_.Trim()-ceq $assignmentLine}).Count-eq 1) 'Python assignment count'
    Assert-True ($source.Contains("`$escapedSlashCount-gt 0")-and $source.Contains("`$slashes-gt 0")-and $source.Contains("`$trailingSlashCount-gt 0")) 'positive-count guard absent'
    Assert-True ([regex]::Matches($source,"Append\(\(\('\\' \* ").Count-eq 3) 'repetition path count'
    Assert-True ([regex]::Matches($source,"Append\(\(\('\\' \* [^\r\n]+\)-join ''\)\)").Count-eq 3) 'explicit join absent'
}
Run-Test 'Criterion ownership maps precedence and every opaque ID boundary' '' {
    $source=[IO.File]::ReadAllText($PSCommandPath)
    $declarations=@([regex]::Matches($source,"(?m)^Run-Test '([^']+)' '([^']*)'"))
    $precedence=@($declarations|Where-Object{$_.Groups[1].Value-ceq 'G3-4 differing models precedence pipeline' -and $_.Groups[2].Value-ceq 'G3-4'})
    $opaque=@($declarations|Where-Object{$_.Groups[1].Value-ceq 'G3-3 pipeline opaque IDs including discovery response' -and $_.Groups[2].Value-ceq 'G3-3'})
    Assert-True ($precedence.Count-eq 1) 'differing precedence not owned by G3-4'
    Assert-True ($opaque.Count-eq 1) 'opaque boundaries not owned by G3-3'
}
Run-Test 'PowerShell argument serializer round-trip' '' {
    $root=New-Root;try{$capture=Join-Path $root 'capture arguments.py';$output=Join-Path $root 'captured arguments.json';$code="import json, pathlib, sys`npathlib.Path(sys.argv[1]).write_text(json.dumps(sys.argv[2:]), encoding='ascii')`n";[IO.File]::WriteAllText($capture,$code,[Text.UTF8Encoding]::new($false));$expected=@('','plain','two words',"tab`tvalue",'quote"value','slash\"quote','ends with slash\','\','"');$process=Invoke-Gate3Python -Mode Process -Arguments (@('-I','-S',$capture,$output)+$expected);$process.WaitForExit();Assert-True ($process.ExitCode-eq 0) 'capture child failed';$actual=@(([IO.File]::ReadAllText($output)|ConvertFrom-Json));Assert-True ($actual.Count-eq $expected.Count) ("argument count expected {0} observed {1}" -f $expected.Count,$actual.Count);for($i=0;$i-lt $expected.Count;$i++){Assert-True ([string]$actual[$i]-ceq $expected[$i]) "argument $i changed"}}finally{Remove-Root $root}
}
Run-Test 'Fake gateway path-with-spaces lifecycle' '' {
    $root=New-Root; $serverInfo=$null;try{$space=Join-Path $root 'Gate 3 path with spaces';$evidence=Join-Path $space 'server evidence with spaces';New-Item -ItemType Directory -Path $evidence -Force|Out-Null;$server=Join-Path $space 'fake gateway.py';$response=Join-Path $space 'response fixture.json';Copy-Item $ServerSource $server;Copy-Item $ResponseSource $response;$serverInfo=Start-Server $space $server $response $evidence;$client=New-Object Net.WebClient;$client.Proxy=$null;$body=$client.DownloadString("$LoopbackPrefix`:$($serverInfo.Port)/v1/models");$client.Dispose();Assert-True ($body|ConvertFrom-Json).data[0].id.Equals('gateway/native-model-id') 'space-path response mismatch';Assert-True ([IO.File]::ReadAllLines($serverInfo.Log).Count-eq 1) 'space-path request count'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}
}
Run-Test 'G3-1 pipeline fake response and display-name contract' 'G3-1' {
    $root=$null;$serverInfo=$null;try{$root=New-Pipeline {$args[0].env.PSObject.Properties.Remove('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC')} {$args[0].envPolicy.gatewayDiscovery=$true;$args[0].envPolicy.disableNonessentialTraffic=$false};$evidence=Join-Path $root 'server';New-Item -ItemType Directory -Path $evidence|Out-Null;Copy-Item $ResponseSource (Join-Path $root 'response.json');$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";Assert-True ($r.Code-eq 0) 'inspector failed';$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.models.Count-eq 1-and $o.models[0].id-ceq 'gateway/native-model-id'-and $o.models[0].displayName-ceq 'Gate 3 Native Model') 'model response mismatch';Assert-True ((Request-Count $serverInfo.Log)-eq 1) 'request count mismatch'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}
}
Run-Test 'G3-1 display-name fallback variants standalone' 'G3-1' {
    foreach($variant in @('__ABSENT__',$null,'','   ',$false,12,@('x'),[pscustomobject]@{x=1})){$root=New-Root;$serverInfo=$null;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'}});$entry=[ordered]@{id='gateway/fallback-id';type='model'};if($variant-cne '__ABSENT__'){$entry.display_name=$variant};Write-Json (Join-Path $root 'response.json') ([ordered]@{data=@($entry)});$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";Assert-True ($r.Code-eq 0) 'fallback inspection failed';$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.models[0].displayName-ceq 'gateway/fallback-id') 'fallback changed ID'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}}
}
Run-Test 'G3-2 pipeline discovery absent sends no request' 'G3-2' {
    $root=$null;$serverInfo=$null;try{$root=New-Pipeline {$args[0].env.PSObject.Properties.Remove('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC')} {$args[0].envPolicy.gatewayDiscovery=$false;$args[0].envPolicy.disableNonessentialTraffic=$false};$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;Copy-Item $ResponseSource (Join-Path $root 'response.json');$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True (!$o.discovery.requested-and !$o.discovery.effective-and $null-eq $o.discovery.warningCode-and $o.models.Count-eq 0-and (Request-Count $serverInfo.Log)-eq 0) 'absent discovery contract'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}
}
Run-Test 'G3-2 pipeline and standalone traffic presence blocks discovery' 'G3-2' {
    foreach($value in @('1','0','false')){$root=New-Root;$serverInfo=$null;try{if($value-eq '1'){Remove-Root $root;$root=New-Pipeline {} {$args[0].envPolicy.gatewayDiscovery=$true;$args[0].envPolicy.disableNonessentialTraffic=$false};$settings=$root|Join-Path -ChildPath 'settings.json';$doc=[IO.File]::ReadAllText($settings)|ConvertFrom-Json;$doc.env|Add-Member -NotePropertyName CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC -NotePropertyValue '1' -Force;Write-Json $settings $doc}else{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1';CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=$value}})};$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;Copy-Item $ResponseSource (Join-Path $root 'response.json');$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.discovery.requested-and !$o.discovery.effective-and $o.discovery.warningCode-ceq 'DISCOVERY_BLOCKED_BY_NONESSENTIAL_TRAFFIC'-and (Request-Count $serverInfo.Log)-eq 0) "traffic $value not blocked"}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}}
}
Run-Test 'G3-4 differing models precedence pipeline' 'G3-4' {
    $root=$null;try{$root=New-Pipeline {} {$args[0].model.value='applied/env/model';$args[0].envPolicy.gatewayDiscovery=$false;$args[0].envPolicy.disableNonessentialTraffic=$false};$r=Invoke-Inspector $root ($LoopbackPrefix+':9');$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.selection.settingsModel-ceq 'old/model'-and $o.selection.environmentModel-ceq 'applied/env/model'-and $o.selection.effectiveModel-ceq 'applied/env/model'-and $o.selection.effectiveModelSource-ceq 'env.ANTHROPIC_MODEL'-and $o.selection.precedenceNotice-ceq 'ANTHROPIC_MODEL overrides settings.model') 'precedence mismatch'}finally{Remove-Root $root}
}
Run-Test 'G3-3 pipeline opaque IDs including discovery response' 'G3-3' {
    $root=$null;$serverInfo=$null;try{$root=New-Pipeline {} {$args[0].model.value='applied/opaque/model';$args[0].envPolicy.gatewayDiscovery=$true;$args[0].envPolicy.disableNonessentialTraffic=$false};Write-Json (Join-Path $root 'response.json') ([ordered]@{data=@([ordered]@{id='gateway/discovered/id';type='model'})});$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.selection.settingsModel-ceq 'old/model') 'settings ID changed';Assert-True ($o.selection.environmentModel-ceq 'applied/opaque/model') 'environment ID changed';Assert-True ($o.models[0].id-ceq 'gateway/discovered/id') 'discovered ID changed'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}
}
Run-Test 'G3-4 pipeline settings fallback and standalone none' 'G3-4' {
    $root=$null;try{$root=New-Pipeline {} {$args[0].model.value='applied/only/model';$args[0].envPolicy.gatewayDiscovery=$false;$args[0].envPolicy.disableNonessentialTraffic=$false};$r=Invoke-Inspector $root ($LoopbackPrefix+':9');$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.selection.effectiveModel-ceq 'applied/only/model'-and $o.selection.effectiveModelSource-ceq 'env.ANTHROPIC_MODEL'-and $o.selection.precedenceNotice-ceq 'ANTHROPIC_MODEL overrides settings.model') 'applied env fallback mismatch'}finally{Remove-Root $root};$root=New-Root;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{model='plain/settings/model';env=[pscustomobject]@{}});$r=Invoke-Inspector $root ($LoopbackPrefix+':9');$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($o.selection.effectiveModel-ceq 'plain/settings/model'-and $o.selection.effectiveModelSource-ceq 'settings.model'-and $null-eq $o.selection.precedenceNotice) 'settings fallback mismatch'}finally{Remove-Root $root};$root=New-Root;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{}});$r=Invoke-Inspector $root ($LoopbackPrefix+':9');$o=[IO.File]::ReadAllText($r.Path)|ConvertFrom-Json;Assert-True ($null-eq $o.selection.effectiveModel-and $o.selection.effectiveModelSource-ceq 'none') 'none selection mismatch'}finally{Remove-Root $root}
}
Run-Test 'G3-5 pipeline alias sorting without providers' 'G3-5' {
    $root=$null;try{$root=New-Root;Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{ANTHROPIC_DEFAULT_SONNET_MODEL='gateway/pin/sonnet';ANTHROPIC_DEFAULT_HAIKU_MODEL='gateway/pin/haiku'}});$r=Invoke-Inspector $root ($LoopbackPrefix+':9');$raw=[IO.File]::ReadAllText($r.Path);$o=$raw|ConvertFrom-Json;Assert-True (($o.aliasPins.alias-join ',')-ceq 'haiku,sonnet') 'alias order';Assert-True ($o.models.Count-eq 0) 'pins became models';foreach($name in @('providers','providerList','activeProviders')){Assert-True ($null-eq $o.PSObject.Properties[$name]) 'provider property emitted'}}finally{Remove-Root $root}
}
Run-Test 'Safety non-temp root and escaped paths rejected' '' {
    $outside=Join-Path ([Environment]::GetFolderPath('UserProfile')) ('gate3-'+[guid]::NewGuid().ToString('N'));$r=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $InspectorPath -FixtureRoot $outside -SettingsPath (Join-Path $outside 'settings.json') -GatewayBaseUrl ($LoopbackPrefix+':9') -ResultPath (Join-Path $outside 'result.json') 2>&1|Out-String;Assert-True ($LASTEXITCODE-ne 0-and !(Test-Path $outside)) 'non-temp root accessed';$root=New-Root;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{}});$escaped=Join-Path (Split-Path $root -Parent) ('escaped-'+[guid]::NewGuid().ToString('N')+'.json');$r=Invoke-Inspector $root ($LoopbackPrefix+':9') -Result $escaped;Assert-True ($r.Code-ne 0-and !(Test-Path $escaped)) 'escaped result accepted'}finally{Remove-Root $root}
}
Run-Test 'Safety reparse ancestor rejected' '' {
    $base=New-Root;try{$actual=Join-Path $base 'actual';New-Item -ItemType Directory $actual|Out-Null;Write-Json (Join-Path $actual 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{}});$link=Join-Path $base 'link';New-Item -ItemType Junction -Path $link -Target $actual|Out-Null;$r=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $InspectorPath -FixtureRoot $link -SettingsPath (Join-Path $link 'settings.json') -GatewayBaseUrl ($LoopbackPrefix+':9') -ResultPath (Join-Path $link 'result.json') 2>&1|Out-String;Assert-True ($LASTEXITCODE-ne 0-and !(Test-Path (Join-Path $actual 'result.json'))) 'reparse accepted'}finally{Remove-Root $base}
}
Run-Test 'Safety invalid URLs rejected without traffic' '' {
    $root=New-Root;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'}});$scheme='ht'+'tp';$secureScheme=$scheme+'s';foreach($url in @($scheme+'://example.invalid:80',$scheme+'://localhost:80',$secureScheme+'://127.0.0.1:9',$scheme+'://127.0.0.1',$scheme+'://user@127.0.0.1:9',$scheme+'://127.0.0.1:9/?x=1',$scheme+'://127.0.0.1:9/#x',$scheme+'://127.0.0.1:9/other')){$r=Invoke-Inspector $root $url -Result ("result-"+[guid]::NewGuid().ToString('N')+'.json');Assert-True ($r.Code-ne 0) "invalid URL accepted"}}finally{Remove-Root $root}
}
Run-Test 'Safety explicit default port and IPv6 loopback URL accepted' '' {
    $root=New-Root;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{}});$scheme='ht'+'tp';$caseIndex=0;foreach($url in @("$scheme`://127.0.0.1:80","$scheme`://[::1]:8080")){$caseIndex++;$r=Invoke-Inspector $root $url -Result ("result-"+[guid]::NewGuid().ToString('N')+'.json');Assert-True ($r.Code-eq 0) "permitted explicit-port loopback case $caseIndex rejected"}}finally{Remove-Root $root}
}
Run-Test 'Fake gateway redacts query and logs unsupported methods as 404' '' {
    $root=New-Root;$serverInfo=$null;try{Copy-Item $ResponseSource (Join-Path $root 'response.json');$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$queryMarker='QUERY_VALUE_MUST_NOT_APPEAR';$methods=@('GET','HEAD','PUT','PATCH','DELETE','OPTIONS','TRACE','PROPFIND');foreach($method in $methods){$request=[Net.HttpWebRequest]::CreateHttp("$LoopbackPrefix`:$($serverInfo.Port)/unsupported?$queryMarker");$request.Method=$method;$request.Proxy=$null;$request.AllowAutoRedirect=$false;try{$response=$request.GetResponse();$status=[int]$response.StatusCode;$response.Dispose()}catch [Net.WebException]{$response=$_.Exception.Response;$status=if($response){[int]$response.StatusCode}else{0};if($response){$response.Dispose()}};Assert-True ($status-eq 404) "$method status was not 404"};$lines=@([IO.File]::ReadAllLines($serverInfo.Log));Assert-True ($lines.Count-eq $methods.Count) 'method request count';for($i=0;$i-lt $methods.Count;$i++){Assert-True ($lines[$i]-ceq ($methods[$i]+' /unsupported')) 'method/path log mismatch'};Assert-True (!([IO.File]::ReadAllText($serverInfo.Log).Contains($queryMarker))) 'query leaked to request log'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}
}
Run-Test 'Cleanup removes root even when server shutdown verification fails' '' {
    $root=New-Root;$caught=$false;try{Complete-ServerTestCleanup -Root $root -ServerInfo ([pscustomobject]@{}) -StopAction {throw 'synthetic shutdown verification failure'}}catch{$caught=$true};Assert-True $caught 'synthetic cleanup failure absent';Assert-True (!(Test-Path -LiteralPath $root)) 'owned root survived shutdown failure';$source=[IO.File]::ReadAllText($PSCommandPath);Assert-True ([regex]::Matches($source,'finally\{if\(\$serverInfo\)\{Stop-Server[^\r\n]+;Remove-Root').Count-eq 0) 'server cleanup can skip owned root removal'
}
Run-Test 'Safety redirect is not followed' '' {
    $root=New-Root;$serverInfo=$null;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'}});Copy-Item $ResponseSource (Join-Path $root 'response.json');$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence @('--redirect-location','/second');$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";Assert-True ($r.Code-ne 0-and !(Test-Path $r.Path)-and (Request-Count $serverInfo.Log)-eq 1) 'redirect followed'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}
}
Run-Test 'Safety malformed model response matrix leaves no result' '' {
    $variants=@('{',('{"x":1}'),('{"data":{}}'),('{"data":[{"id":"","type":"model"}]}'),('{"data":[{"id":"x","type":"other"}]}'),('{"data":[]}'))
    foreach($body in $variants){$root=New-Root;$serverInfo=$null;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'}});[IO.File]::WriteAllText((Join-Path $root 'response.json'),$body,[Text.UTF8Encoding]::new($false));$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)";Assert-True ($r.Code-ne 0-and !(Test-Path $r.Path)-and @(Get-ChildItem $root -Filter '.gate3-result-*.tmp').Count-eq 0) 'invalid response accepted'}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}}
}
Run-Test 'Safety oversized and timeout failures leave no artifact' '' {
    foreach($mode in @('oversized','timeout')){$root=New-Root;$serverInfo=$null;try{Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY='1'}});$payload=if($mode-eq 'oversized'){'{"data":[{"id":"'+('x'*66000)+'","type":"model"}]}'}else{'{"data":[{"id":"x","type":"model"}]}'};[IO.File]::WriteAllText((Join-Path $root 'response.json'),$payload,[Text.UTF8Encoding]::new($false));$evidence=Join-Path $root 'server';New-Item -ItemType Directory $evidence|Out-Null;$extra=@();if($mode-eq 'timeout'){$extra=@('--delay-ms','500')};$serverInfo=Start-Server $root $ServerSource (Join-Path $root 'response.json') $evidence $extra;$r=Invoke-Inspector $root "$LoopbackPrefix`:$($serverInfo.Port)" 100;Assert-True ($r.Code-ne 0-and !(Test-Path $r.Path)-and !$r.Output.Contains('FAKE_GATE3_SECRET_DO_NOT_USE')) "$mode accepted"}finally{Complete-ServerTestCleanup -Root $root -ServerInfo $serverInfo}}
}
Run-Test 'Safety duplicate settings and existing result rejected' '' {
    $root=New-Root;try{[IO.File]::WriteAllText((Join-Path $root 'settings.json'),'{"env":{},"same":1,"\u0073ame":2}',[Text.UTF8Encoding]::new($false));$r=Invoke-Inspector $root ($LoopbackPrefix+':9');Assert-True ($r.Code-ne 0-and !(Test-Path $r.Path)) 'duplicate accepted';Write-Json (Join-Path $root 'settings.json') ([pscustomobject]@{env=[pscustomobject]@{}});[IO.File]::WriteAllText((Join-Path $root 'result.json'),'sentinel');$r=Invoke-Inspector $root ($LoopbackPrefix+':9');Assert-True ($r.Code-ne 0-and [IO.File]::ReadAllText($r.Path)-ceq 'sentinel') 'existing result overwritten'}finally{Remove-Root $root}
}
Run-Test 'Safety Python environment restored exactly' '' {
    $names=@('PYTHONPATH','PYTHONHOME','PYTHONHOSTILE_GATE3','HTTP_PROXY','HTTPS_PROXY','ALL_PROXY');$saved=@{};$expected=@{};try{foreach($name in $names){$saved[$name]=[Environment]::GetEnvironmentVariable($name,'Process');[Environment]::SetEnvironmentVariable($name,"gate3-$name",'Process')};foreach($name in $names){$expected[$name]=[Environment]::GetEnvironmentVariable($name,'Process')};$out=@(Invoke-Gate3Python -Mode Direct -Arguments @('-I','-S','-c',"import os; print('OK' if all(os.environ.get(k) is None for k in ('PYTHONPATH','PYTHONHOME','PYTHONHOSTILE_GATE3','HTTP_PROXY','HTTPS_PROXY','ALL_PROXY','http_proxy','https_proxy','all_proxy')) else 'BAD')"));Assert-True ($LASTEXITCODE-eq 0-and $out[0]-ceq 'OK') 'child environment not isolated';foreach($name in $names){$observed=[Environment]::GetEnvironmentVariable($name,'Process');Assert-True ([string]::Equals($observed,$expected[$name],[StringComparison]::Ordinal)) "environment not restored: $name"}}finally{foreach($name in $names){[Environment]::SetEnvironmentVariable($name,$saved[$name],'Process')}}
}
Run-Test 'Safety static initialization and Python launch contract' '' {
    $source=[IO.File]::ReadAllText($PSCommandPath);Assert-True ($source.Contains("[Alias('PythonExe')]")-and $source.Contains('$SuppliedPythonExe')) 'public binding absent';foreach($bad in @(('Get-'+'Command'),('python'+'.exe'),('python'+'3'),('py'+'.exe'))){Assert-True (!$source.Contains($bad)) 'harness-side discovery present'};$assign=$source.IndexOf('$script:PythonExe=$canonicalPython');$checks=$source.IndexOf("if(![IO.Path]::IsPathRooted(`$SuppliedPythonExe))");$firstCall=$source.IndexOf('Invoke-Gate3Python -Mode Direct');Assert-True ($checks-ge 0-and $assign-gt $checks-and $firstCall-gt $assign) 'initialization order';$processCommand='Start-'+'Process';Assert-True ([regex]::Matches($source,$processCommand).Count-eq 1) 'ad hoc process launch';$assignLine='$script:'+'PythonExe=$canonicalPython';Assert-True (@($source-split "`r?`n"|Where-Object{$_.Trim()-ceq $assignLine}).Count-eq 1) 'Python reassignment'
}

$criterionText=[ordered]@{
 'G3-1'='fake Anthropic-compatible local /v1/models response'
 'G3-2'='discovery opt-in and blocked by nonessential traffic'
 'G3-3'='gateway-native model ID unchanged'
 'G3-4'='ANTHROPIC_MODEL precedence displayed honestly'
 'G3-5'='alias pinning is not a provider list'
}
foreach($key in $criterionText.Keys){$status=if($Criteria[$key]){'PASS'}else{'FAIL'};Write-Host "$key $status - $($criterionText[$key])"}
$failed=@($TestResults|Where-Object Result -eq 'FAIL');if($failed.Count){foreach($item in $failed){Write-Host "FAILURE $($item.Name): $($item.Reason)"};Write-Host "SAFETY FAIL - $($failed.Count) failed";exit 1}
Write-Host 'SAFETY PASS - 0 failed';Write-Host 'OVERALL PASS - Gate 3 provider/model evidence';exit 0
