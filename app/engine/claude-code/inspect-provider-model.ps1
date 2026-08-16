param(
    [Parameter(Mandatory = $true)][string]$FixtureRoot,
    [Parameter(Mandatory = $true)][string]$SettingsPath,
    [Parameter(Mandatory = $true)][string]$GatewayBaseUrl,
    [Parameter(Mandatory = $true)][string]$ResultPath,
    [ValidateRange(100, 5000)][int]$TimeoutMs = 2000
)

$ErrorActionPreference='Stop'
$transactionPath=$null

function Fail { param([string]$Reason) throw $Reason }
function Has-Property { param([object]$Object,[string]$Name) return $null-ne $Object.PSObject.Properties[$Name] }
function Assert-NoReparseComponent { param([string]$Path,[string]$Boundary)
    $prefix=$Boundary.TrimEnd('\')+'\'
    if($Path-cne $Boundary-and !$Path.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){Fail 'path boundary violation'}
    $cursor=$Boundary
    if(Test-Path -LiteralPath $cursor){$item=Get-Item -LiteralPath $cursor -Force;if(($item.Attributes-band [IO.FileAttributes]::ReparsePoint)-ne 0){Fail 'reparse point rejected'}}
    if($Path-cne $Boundary){foreach($part in $Path.Substring($prefix.Length).Split([IO.Path]::DirectorySeparatorChar)){if(!$part){continue};$cursor=Join-Path $cursor $part;if(Test-Path -LiteralPath $cursor){$item=Get-Item -LiteralPath $cursor -Force;if(($item.Attributes-band [IO.FileAttributes]::ReparsePoint)-ne 0){Fail 'reparse point rejected'}}}}
}
function Assert-NoDuplicateKeys { param([string]$Raw)
    $contexts=New-Object Collections.Stack;$i=0
    while($i-lt $Raw.Length){$c=$Raw[$i];if([char]::IsWhiteSpace($c)){$i++;continue};if($c-eq '{'){$contexts.Push([pscustomobject]@{Type='object';ExpectKey=$true;Keys=(New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal))});$i++;continue};if($c-eq '['){$contexts.Push([pscustomobject]@{Type='array';ExpectKey=$false;Keys=$null});$i++;continue};if($c-eq '}'-or $c-eq ']'){if($contexts.Count){[void]$contexts.Pop()};$i++;continue};if($c-eq ','){if($contexts.Count-and $contexts.Peek().Type-eq 'object'){$contexts.Peek().ExpectKey=$true};$i++;continue};if($c-eq ':'){$i++;continue};if($c-eq '"'){$start=$i;$i++;$escaped=$false;while($i-lt $Raw.Length){$ch=$Raw[$i];if($escaped){$escaped=$false;$i++;continue};if($ch-eq '\'){$escaped=$true;$i++;continue};if($ch-eq '"'){$i++;break};$i++};$token=$Raw.Substring($start,$i-$start);try{$decoded=$token|ConvertFrom-Json}catch{Fail 'invalid JSON string token'};if($contexts.Count-and $contexts.Peek().Type-eq 'object'-and $contexts.Peek().ExpectKey){if(!$contexts.Peek().Keys.Add([string]$decoded)){Fail 'duplicate key'};$contexts.Peek().ExpectKey=$false};continue};while($i-lt $Raw.Length-and $Raw[$i]-notin @(',',']','}')){$i++}}
}
function Get-NonEmptyString { param([object]$Object,[string]$Name) if((Has-Property $Object $Name)-and $Object.$Name-is[string]-and ![string]::IsNullOrWhiteSpace($Object.$Name)){return [string]$Object.$Name};return $null }
function Write-NewUtf8 { param([string]$Path,[string]$Text) $stream=[IO.File]::Open($Path,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None);try{$bytes=[Text.UTF8Encoding]::new($false).GetBytes($Text);$stream.Write($bytes,0,$bytes.Length);$stream.Flush($true)}finally{$stream.Dispose()} }

try {
    try{$root=[IO.Path]::GetFullPath($FixtureRoot);$settings=[IO.Path]::GetFullPath($SettingsPath);$result=[IO.Path]::GetFullPath($ResultPath)}catch{Fail 'path invalid'}
    $temp=( [IO.Path]::GetFullPath([IO.Path]::GetTempPath()) ).TrimEnd('\');$tempPrefix=$temp+'\';if(!$root.StartsWith($tempPrefix,[StringComparison]::OrdinalIgnoreCase)){Fail 'fixture root outside temp'}
    Assert-NoReparseComponent $root $temp
    $rootPrefix=$root.TrimEnd('\')+'\';foreach($path in @($settings,$result)){if(!$path.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)){Fail 'path outside fixture root'};Assert-NoReparseComponent $path $temp}
    if(!(Test-Path -LiteralPath $settings -PathType Leaf)){Fail 'settings missing'};if(Test-Path -LiteralPath $result){Fail 'result exists'}
    $raw=[IO.File]::ReadAllText($settings);Assert-NoDuplicateKeys $raw;try{$document=$raw|ConvertFrom-Json}catch{Fail 'settings malformed JSON'};if(!($document-is[Management.Automation.PSCustomObject])){Fail 'settings root must be object'}
    if(Has-Property $document 'env'){if(!($document.env-is[Management.Automation.PSCustomObject])){Fail 'settings env must be object'};$env=$document.env}else{$env=[pscustomobject]@{}}

    $literalPattern='^ht'+'tp://(?<host>127\.0\.0\.1|\[::1\]):(?<port>[0-9]+)(?<path>/|/v1)?$'
    $literalMatch=[regex]::Match($GatewayBaseUrl,$literalPattern,[Text.RegularExpressions.RegexOptions]::CultureInvariant)
    if(!$literalMatch.Success){Fail 'gateway URL rejected'};$explicitPort=0;if(![int]::TryParse($literalMatch.Groups['port'].Value,[ref]$explicitPort)-or $explicitPort-lt 1-or $explicitPort-gt 65535){Fail 'gateway URL rejected'}
    $uri=$null;if(![Uri]::TryCreate($GatewayBaseUrl,[UriKind]::Absolute,[ref]$uri)-or $uri.Scheme-cne 'http'-or $uri.Port-ne $explicitPort-or $uri.UserInfo-or $uri.Query-or $uri.Fragment-or @('','/','/v1')-cnotcontains $uri.AbsolutePath){Fail 'gateway URL rejected'}
    $requestPath='/v1/models';$requestUri=if($uri.AbsolutePath-eq '/v1'){[Uri]::new($uri,'/v1/models')}else{[Uri]::new($uri,'/v1/models')}
    $requested=(Has-Property $env 'CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY')-and $env.CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY-is[string]-and $env.CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY-ceq '1'
    $blocked=(Has-Property $env 'CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC')-and $env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC-is[string]-and $env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC.Length-gt 0
    $effective=$requested-and !$blocked;$warning=if($requested-and $blocked){'DISCOVERY_BLOCKED_BY_NONESSENTIAL_TRAFFIC'}else{$null};$models=@()
    if($effective){
        $request=[Net.HttpWebRequest]::CreateHttp($requestUri);$request.Method='GET';$request.Accept='application/json';$request.AllowAutoRedirect=$false;$request.Proxy=$null;$request.Timeout=$TimeoutMs;$request.ReadWriteTimeout=$TimeoutMs
        try{$response=[Net.HttpWebResponse]$request.GetResponse()}catch{Fail 'gateway request failed'}
        try{if([int]$response.StatusCode-ne 200){Fail 'gateway status rejected'};$memory=New-Object IO.MemoryStream;$stream=$response.GetResponseStream();try{$buffer=New-Object byte[] 8192;while(($count=$stream.Read($buffer,0,$buffer.Length))-gt 0){$memory.Write($buffer,0,$count);if($memory.Length-gt 65536){Fail 'gateway body too large'}}}finally{$stream.Dispose()};$body=[Text.Encoding]::UTF8.GetString($memory.ToArray())}finally{$response.Dispose()}
        try{$modelDocument=$body|ConvertFrom-Json}catch{Fail 'gateway JSON invalid'};if(!($modelDocument-is[Management.Automation.PSCustomObject])-or !(Has-Property $modelDocument 'data')-or !($modelDocument.data-is[Array])-or $modelDocument.data.Count-eq 0){Fail 'gateway model list invalid'}
        foreach($entry in $modelDocument.data){if(!($entry-is[Management.Automation.PSCustomObject])){Fail 'gateway model entry invalid'};$id=Get-NonEmptyString $entry 'id';if(!$id-or (Get-NonEmptyString $entry 'type')-cne 'model'){Fail 'gateway model metadata invalid'};$display=Get-NonEmptyString $entry 'display_name';if(!$display){$display=$id};$models+=,[ordered]@{id=$id;type='model';displayName=$display}}
    }
    $settingsModel=Get-NonEmptyString $document 'model';$environmentModel=Get-NonEmptyString $env 'ANTHROPIC_MODEL';if($environmentModel){$effectiveModel=$environmentModel;$source='env.ANTHROPIC_MODEL'}elseif($settingsModel){$effectiveModel=$settingsModel;$source='settings.model'}else{$effectiveModel=$null;$source='none'};$notice=if($settingsModel-and $environmentModel-and $settingsModel-cne $environmentModel){'ANTHROPIC_MODEL overrides settings.model'}else{$null}
    $pins=@();foreach($pair in @(@('opus','ANTHROPIC_DEFAULT_OPUS_MODEL'),@('sonnet','ANTHROPIC_DEFAULT_SONNET_MODEL'),@('haiku','ANTHROPIC_DEFAULT_HAIKU_MODEL'),@('fable','ANTHROPIC_DEFAULT_FABLE_MODEL'))){$value=Get-NonEmptyString $env $pair[1];if($value){$pins+=,[ordered]@{alias=$pair[0];modelId=$value}}};$pins=@($pins|Sort-Object @{Expression={$_.alias}})
    $output=[ordered]@{contract='claude-code-gate3-provider-model-v1';discovery=[ordered]@{requested=$requested;effective=$effective;warningCode=$warning;requestPath=if($effective){$requestPath}else{$null}};models=@($models);selection=[ordered]@{settingsModel=$settingsModel;environmentModel=$environmentModel;effectiveModel=$effectiveModel;effectiveModelSource=$source;precedenceNotice=$notice};aliasPins=@($pins)}
    $transactionPath=Join-Path (Split-Path $result -Parent) ('.gate3-result-'+[guid]::NewGuid().ToString('N')+'.tmp');Write-NewUtf8 $transactionPath ($output|ConvertTo-Json -Depth 10);$verified=[IO.File]::ReadAllText($transactionPath)|ConvertFrom-Json;if($verified.contract-cne 'claude-code-gate3-provider-model-v1'){Fail 'result verification failed'};[IO.File]::Move($transactionPath,$result);$transactionPath=$null
} catch {
    Write-Output 'Gate 3 inspection failed'
    exit 1
} finally {if($transactionPath-and (Test-Path -LiteralPath $transactionPath)){Remove-Item -LiteralPath $transactionPath -Force}}
