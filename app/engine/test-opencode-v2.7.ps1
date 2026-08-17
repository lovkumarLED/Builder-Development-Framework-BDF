# ============================================================
# OpenCode Configuration Builder V2.7 - Test Harness
# ============================================================
# Author  : Love + ChatGPT
# Purpose : Automated verification of the V2.7 builder
#           (JSON Schema Validation + hardening).
#
# Tests
# -----
# Kept (V2.5 suite, unchanged):
# 1.  All providers discovered (-Provider lists both)
# 2.  Malformed provider file fails, names the file, no output
# 3.  -NonInteractive uses the stored activeProviders list
# 4.  -Provider argument skips the prompt and persists order
# 5.  -Provider argument with an unknown id fails clearly
# 6.  Profile-level <provider>-models.json wins over folder models
# 7.  Non-active profile models are ignored
# 8.  settings.json activeProviders round-trips exactly
# 9.  settings.json backup is created with original content
# 10. Empty selection fails (empty stored list, -NonInteractive)
# 11. Duplicate model key in <provider>-models.json fails
# 12. Builder spec covers V2.5 tokens
# 13. Active provider without models is dropped
# New (V2.7 groups):
# 14. Schema: valid sources pass
# 15. Schema: settings missing required fails
# 16. Schema: wrong type fails
# 17. Schema: additionalProperties fails
# 18. Schema: real settings accepted
# 19. Schema: provider file violation fails
# 20. Schema: models file violation fails
# 21. Schema: no schema dir warns + continues
# 22. Pre-flight: missing provider file aborts
# 23. -WhatIf: nothing written, exit 0
# 24. -Doctor: clean config exits 0
# 25. -Doctor: corrupt config exits 1
# 26. Backup retention: -KeepBackups honored
# 27. Provenance: sidecar fields + sha correct
# 28. Diff summary: Added/Removed lines; identical input silent
# 29. Builder spec covers V2.7 tokens (F1-F7)
# 30. P2: dynamic target artifact (target.json -> claude.json)
# 31. P1 gate: no literal API keys in generated output
# New (V2.7 LSP group):
# 32. LSP enabled true -> generated lsp key
# 33. LSP enabled object -> lsp object round-trips
# 34. LSP disabled omits the lsp section
# 35. No lsp.json omits the lsp section
# 36. LSP false value omits the lsp section
# ============================================================

$BuilderPath = Join-Path $PSScriptRoot "build-opencode-v2.7.ps1"

$TestRootBase = Join-Path $env:TEMP "opencode-builder-tests"

$TestResults = @()

# ------------------------------------------------------------
# Test helpers (scaffolding copied verbatim from the V2.1 harness)
# ------------------------------------------------------------

function New-TestRoot {

    $Root = Join-Path $TestRootBase ([guid]::NewGuid().ToString("N"))

    New-Item -ItemType Directory -Path $Root | Out-Null

    return $Root
}

function Remove-TestRoot {

    param(
        [string]$Root
    )

    Remove-Item $Root -Recurse -Force -ErrorAction SilentlyContinue
}

function Write-JsonFile {

    param(
        [string]$Root,
        [string]$Relative,
        [string]$Content
    )

    $Path = Join-Path $Root $Relative
    $Dir  = Split-Path $Path

    New-Item -ItemType Directory -Path $Dir -Force | Out-Null

    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

function Write-JsonObject {

    param(
        [string]$Root,
        [string]$Relative,
        [object]$Object
    )

    $Json = $Object | ConvertTo-Json -Depth 100

    Write-JsonFile $Root $Relative $Json
}

function Assert-True {

    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {

        throw $Message
    }
}

function Read-Generated {

    param(
        [string]$Root
    )

    $Generated = Join-Path $Root "opencode.json"

    if (!(Test-Path $Generated)) {

        throw "opencode.json was not generated."
    }

    return Get-Content $Generated -Raw | ConvertFrom-Json
}

# ------------------------------------------------------------
# Test runner (verbatim from the V2.1 harness)
# ------------------------------------------------------------

function Run-Test {

    param(
        [string]$Name,
        [scriptblock]$Body
    )

    try {

        & $Body

        $script:TestResults += [pscustomobject]@{ Name = $Name; Result = "PASS" }

        Write-Host "[+] $Name" -ForegroundColor Green
    }
    catch {

        $script:TestResults += [pscustomobject]@{
            Name   = $Name
            Result = "FAIL"
            Error  = $_.Exception.Message
        }

        Write-Host "[x] $Name - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# Invoke-Builder adapted for build-opencode-v2.5.ps1
# Always passes -ConfigRoot and -Profile plus exactly the
# flags the calling test needs. No test may require real stdin.
# ------------------------------------------------------------

function Invoke-Builder {

    param(
        [string]$Root,
        [string]$Profile = "default",
        [string]$Provider = $null,
        [switch]$NonInteractive,
        [switch]$WhatIf,
        [switch]$Doctor,
        [int]$KeepBackups = 0
    )

    $BuilderArgs = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $BuilderPath,
        "-Profile", $Profile,
        "-ConfigRoot", $Root
    )

    # Forward -Provider only when a non-empty value is supplied. An empty
    # argument would cross the native boundary and be re-tokenized by
    # powershell.exe as a value-less -Provider switch.
    if ($PSBoundParameters.ContainsKey('Provider') -and $Provider) {

        $BuilderArgs += @("-Provider", $Provider)
    }

    if ($NonInteractive) { $BuilderArgs += "-NonInteractive" }
    if ($WhatIf)         { $BuilderArgs += "-WhatIf" }
    if ($Doctor)         { $BuilderArgs += "-Doctor" }

    if ($KeepBackups -gt 0) { $BuilderArgs += @("-KeepBackups", "$KeepBackups") }

    $Output = & powershell.exe $BuilderArgs 2>&1 | Out-String

    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output   = $Output
    }
}

# ------------------------------------------------------------
# V2.5 fixture helpers
# ------------------------------------------------------------

function New-V25Root {

    # Temp root with profiles\<profile>\ and providers\ ready for the builder.

    param(
        [string]$Profile = "default"
    )

    $Root = New-TestRoot

    New-Item -ItemType Directory -Path (Join-Path $Root "profiles\$Profile") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $Root "providers") -Force | Out-Null

    return $Root
}

function Write-ValidProvider {

    # Writes a provider file that satisfies Assert-ProviderDefinition:
    # {"id": <id>, "provider": {<id>: {"name": ..., "npm": ...}}}.

    param(
        [string]$Root,
        [string]$Id,
        [string]$Name,
        [string]$Npm = "@ai-sdk/openai-compatible"
    )

    Write-JsonObject $Root "providers\$Id.json" @{
        id       = $Id
        provider = @{
            $Id = @{
                name = $Name
                npm  = $Npm
            }
        }
    }
}

function Write-ProfileSettings {

    # settings.json with "$schema" + activeProviders (empty allowed only for
    # tests that intend an empty stored list).

    param(
        [string]$Root,
        [string[]]$Active,
        [string]$Profile = "default",
        [bool]$WithSchema = $true
    )

    $Settings = @{}

    if ($WithSchema) { $Settings['$schema'] = "https://opencode.ai/config.schema.json" }

    $Settings['activeProviders'] = @($Active)

    Write-JsonObject $Root "profiles\$Profile\settings.json" $Settings
}

function Write-ProfileModels {

    param(
        [string]$Root,
        [string]$Profile,
        [hashtable]$Models
    )

    Write-JsonObject $Root "profiles\$Profile\models.json" @{ models = $Models }
}

function Write-ProfileProviderModels {

    # Profile-level models for one provider: profiles\<profile>\<id>-models.json

    param(
        [string]$Root,
        [string]$Profile,
        [string]$ProviderId,
        [hashtable]$Models
    )

    Write-JsonObject $Root "profiles\$Profile\$ProviderId-models.json" @{ models = $Models }
}

function Write-ProviderModelsFolder {

    # Provider-folder models: providers\<id>\models.json

    param(
        [string]$Root,
        [string]$ProviderId,
        [hashtable]$Models
    )

    Write-JsonObject $Root "providers\$ProviderId\models.json" @{ models = $Models }
}

# ------------------------------------------------------------
# Test 1 - All providers discovered
# ------------------------------------------------------------

function Test-AllProvidersDiscovered {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")

        Write-ValidProvider $Root "modal" "Modal"
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        # Global fallback models source for both active providers.
        Write-ProfileModels $Root "default" @{
            "m-1" = @{ name = "Model One" }
            "m-2" = @{ name = "Model Two" }
        }

        $Run = Invoke-Builder $Root -Provider "modal,omniroute"

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Generated = Read-Generated $Root

        Assert-True ($null -ne $Generated.provider.modal) "Provider 'modal' missing from output."

        Assert-True ($null -ne $Generated.provider.omniroute) "Provider 'omniroute' missing from output."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 2 - Malformed provider definition fails
# ------------------------------------------------------------

function Test-MalformedProviderFails {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("x")

        # Missing "provider" section => fails Assert-ProviderDefinition.
        Write-JsonFile $Root "providers\x.json" '{ "id": "x" }'

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder should have failed on the malformed provider file."

        Assert-True ($Run.Output.Contains("x.json")) "Error must name the bad file. Output: $($Run.Output)"

        Assert-True (!(Test-Path (Join-Path $Root "opencode.json"))) `
            "opencode.json should not be written after a failed build."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 3 - Non-interactive mode uses the stored list
# ------------------------------------------------------------

function Test-NonInteractiveUsesStored {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")

        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-ProviderModelsFolder $Root "omniroute" @{ "om-1" = @{ name = "Omni One" } }

        $SettingsPath = Join-Path $Root "profiles\default\settings.json"
        $BeforeHash = (Get-FileHash $SettingsPath).Hash

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Generated = Read-Generated $Root

        $Names = @($Generated.provider.PSObject.Properties.Name)

        Assert-True (($Names -join ",") -eq "omniroute") `
            "Expected only omniroute, got: $($Names -join ',')"

        $AfterHash = (Get-FileHash $SettingsPath).Hash

        Assert-True ($BeforeHash -eq $AfterHash) `
            "settings.json must be byte-identical when the stored list is reused."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 4 - -Provider argument skips the prompt
# ------------------------------------------------------------

function Test-ProviderArgSkipsPrompt {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")

        Write-ValidProvider $Root "modal" "Modal"
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-ProfileModels $Root "default" @{
            "m-1" = @{ name = "Model One" }
            "m-2" = @{ name = "Model Two" }
        }

        $Run = Invoke-Builder $Root -Provider "omniroute,modal"

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Generated = Read-Generated $Root

        Assert-True ($null -ne $Generated.provider.modal) "Provider 'modal' missing from output."

        Assert-True ($null -ne $Generated.provider.omniroute) "Provider 'omniroute' missing from output."

        $Settings = Get-Content (Join-Path $Root "profiles\default\settings.json") -Raw | ConvertFrom-Json

        $Stored = @($Settings.activeProviders)

        Assert-True (($Stored -join ",") -eq "omniroute,modal") `
            "settings.json must be rewritten to the -Provider order. Got: $($Stored -join ',')"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 5 - Unknown -Provider argument fails clearly
# ------------------------------------------------------------

function Test-ProviderArgUnknownFails {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")

        Write-ValidProvider $Root "omniroute" "OmniRoute"

        $Run = Invoke-Builder $Root -Provider "ghost"

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail for unknown provider 'ghost'."

        Assert-True ($Run.Output.Contains("Provider not found: ghost")) `
            "Missing clear error. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 6 - Profile-level models have highest precedence
# ------------------------------------------------------------

function Test-ProfileModelsHighestPrecedence {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("modal")

        Write-ValidProvider $Root "modal" "Modal"

        # Both a profile-level file and a provider-folder file exist.
        Write-ProfileProviderModels $Root "default" "modal" @{ "kimi-k3" = @{ name = "Kimi K3" } }

        Write-ProviderModelsFolder $Root "modal" @{ "folder-model" = @{ name = "Folder Model" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Generated = Read-Generated $Root

        $Models = $Generated.provider.modal.models

        Assert-True ($null -ne $Models."kimi-k3") `
            "Profile-level model 'kimi-k3' must win the merge."

        Assert-True ($null -eq $Models."folder-model") `
            "Provider-folder model must NOT override profile-level models."

        $Count = @($Models.PSObject.Properties).Count

        Assert-True ($Count -eq 1) "Expected exactly 1 model, got $Count."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 6b - apiModelId aliases the output model key
# ------------------------------------------------------------

function Test-ApiModelIdAliasesOutputKey {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("modal")

        Write-ValidProvider $Root "modal" "Modal"

        Write-ProfileProviderModels $Root "default" "modal" @{
            "display/modal-id" = @{ name = "Modal Display"; apiModelId = "upstream/modal-id"; variants = @{ max = @{ reasoningEffort = "max" } } }
            "display/plain-id" = @{ name = "Plain Display" }
        }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Generated = Read-Generated $Root

        $Models = $Generated.provider.modal.models

        Assert-True ($null -ne $Models."upstream/modal-id") `
            "apiModelId 'upstream/modal-id' must become the output model key."

        Assert-True ($null -eq $Models."display/modal-id") `
            "Display key 'display/modal-id' must not remain in the output."

        Assert-True ($null -ne $Models."display/plain-id") `
            "A model without apiModelId keeps its key."

        Assert-True ($null -eq $Models."upstream/modal-id".PSObject.Properties['apiModelId']) `
            "apiModelId must not leak into the generated output."

        Assert-True ($Models."upstream/modal-id".name -eq "Modal Display") `
            "Display name must be preserved under the aliased key."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 7 - Non-active profile models are ignored
# ------------------------------------------------------------

function Test-NonActiveProfileModelsIgnored {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("modal")

        # groq.json must still be a valid provider file (discovery validates ALL).
        Write-ValidProvider $Root "groq" "Groq"
        Write-ValidProvider $Root "modal" "Modal"

        Write-ProviderModelsFolder $Root "modal" @{ "modal-1" = @{ name = "Modal One" } }

        # groq-models.json exists in the profile but groq is NOT active.
        Write-ProfileProviderModels $Root "default" "groq" @{ "groq-1" = @{ name = "Groq One" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Raw = Get-Content (Join-Path $Root "opencode.json") -Raw
        $Generated = $Raw | ConvertFrom-Json

        $Names = @($Generated.provider.PSObject.Properties.Name)

        Assert-True (($Names -join ",") -eq "modal") `
            "Expected only modal in output, got: $($Names -join ',')"

        Assert-True ($Raw.IndexOf("groq", [System.StringComparison]::OrdinalIgnoreCase) -eq -1) `
            "groq (provider or models) leaked into the output: $Raw"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 8 - settings.json persist round-trip
# ------------------------------------------------------------

function Test-SettingsPersistRoundTrip {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")

        Write-ValidProvider $Root "modal" "Modal"
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -Provider "modal,omniroute"

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Settings = Get-Content (Join-Path $Root "profiles\default\settings.json") -Raw | ConvertFrom-Json

        Assert-True (($Settings.activeProviders -join ",") -eq "modal,omniroute") `
            "activeProviders round-trip wrong. Got: $($Settings.activeProviders -join ',')"

        Assert-True ($Settings.'$schema' -eq "https://opencode.ai/config.schema.json") `
            "'$schema' must be preserved. Got: $($Settings.'$schema')"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 9 - settings.json backup is created
# ------------------------------------------------------------

function Test-SettingsBackupCreated {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")

        Write-ValidProvider $Root "modal" "Modal"
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-ProviderModelsFolder $Root "omniroute" @{ "om-1" = @{ name = "Omni One" } }
        Write-ProviderModelsFolder $Root "modal" @{ "mo-1" = @{ name = "Modal One" } }

        $SettingsPath = Join-Path $Root "profiles\default\settings.json"
        $OriginalRaw = Get-Content $SettingsPath -Raw

        # List differs from stored => settings.json is rewritten => backup taken.
        $Run = Invoke-Builder $Root -Provider "modal,omniroute"

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $BackupDir = Join-Path $Root "backup"

        Assert-True (Test-Path $BackupDir) "backup directory was not created."

        $Backups = @(Get-ChildItem -Path $BackupDir -Filter "settings_default_*.json" -File)

        Assert-True ($Backups.Count -ge 1) "No settings backup file was created under backup\."

        $BackupRaw = Get-Content $Backups[0].FullName -Raw

        Assert-True ($BackupRaw -eq $OriginalRaw) `
            "Backup content must match the original settings.json."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 10 - Empty selection fails
# ------------------------------------------------------------

function Test-EmptySelectionFails {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @()

        Write-ValidProvider $Root "modal" "Modal"

        $Run = Invoke-Builder $Root -Provider "" -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail on an empty provider selection."

        Assert-True ($Run.Output.Contains("activeProviders")) `
            "Expected an activeProviders error. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 11 - Duplicate model key in <provider>-models.json fails
# ------------------------------------------------------------

function Test-ProfileModelsDupKeyFails {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("modal")

        Write-ValidProvider $Root "modal" "Modal"

        # Raw JSON with a duplicate model id (ConvertTo-Json would dedupe, raw text keeps it).
        Write-JsonFile $Root "profiles\default\modal-models.json" @"
{
    "models": {
        "kimi-k3": { "name": "Kimi K3" },
        "kimi-k3": { "name": "Kimi K3 Dup" }
    }
}
"@

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail on a duplicate model key."

        Assert-True ($Run.Output.Contains("Duplicate")) `
            "Expected a duplicate-key validation error. Output: $($Run.Output)"

        Assert-True (!(Test-Path (Join-Path $Root "opencode.json"))) `
            "opencode.json should not be written after a failed build."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 12 - Real BUILDER_SPEC.md covers the V2.5 tokens
# EXPECTED FAIL until the docs sync task is done.
# ------------------------------------------------------------

function Test-BuilderSpecCoversV25 {

    # Resolve relative to the harness so bootstrapped copies (scaffold-agent)
    # never inherit a hardcoded machine path. The doc is project-owned and
    # optional: when absent, the token coverage check is skipped, not failed.

    $SpecPath = Join-Path (Split-Path $PSScriptRoot -Parent) "docs\BUILDER_SPEC.md"

    if (-not (Test-Path $SpecPath)) {

        Write-Host "[i] BUILDER_SPEC.md not present - skipping spec token coverage (project doc optional)."
        return
    }

    $Spec = Get-Content $SpecPath -Raw

    foreach ($Token in @(
        "Discover-Providers",
        "Select-ActiveProviders",
        "Persist-ActiveProviders",
        "Get-ProfileProviderModels",
        "-NonInteractive",
        "<provider>-models.json"
    )) {

        Assert-True $Spec.Contains($Token) "BUILDER_SPEC.md is missing the token: $Token"
    }
}

# ------------------------------------------------------------
# Test 13 - Active provider without models is dropped
# ------------------------------------------------------------

function Test-ActiveProviderNoModelsDropped {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("modal", "ghostprov")

        Write-ValidProvider $Root "modal" "Modal"

        Write-ValidProvider $Root "ghostprov" "Ghost Prov"

        # modal has a models source; ghostprov intentionally has none.
        Write-ProviderModelsFolder $Root "modal" @{ "m1" = @{ name = "M1" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Generated = Read-Generated $Root

        Assert-True ($null -eq $Generated.provider.ghostprov) `
            "Provider without models must be dropped from the generated configuration."

        Assert-True ($null -ne $Generated.provider.modal) `
            "Provider with models must remain in the generated configuration."

        $Stored = (Get-Content (Join-Path $Root "profiles\default\settings.json") -Raw | ConvertFrom-Json).activeProviders

        Assert-True (@($Stored) -notcontains "ghostprov") `
            "Dropped provider must be removed from settings.json activeProviders."

        Assert-True ($Run.Output -match "models not found") `
            "Expected a 'models not found' warning in the builder output."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# V2.7 fixture helpers
# ------------------------------------------------------------

function Write-Schemas {

    # Writes the six schema files into <Root>\schemas so the builder's
    # default -SchemaDir picks them up. Uses only the feature subset the
    # builder implements (type/required/properties/additionalProperties).

    param(
        [string]$Root
    )

    $Schemas = @{
        "schema.json" = @{
            type     = "object"
            properties = @{ provider = @{ type = "object" } }
            required = @("provider")
        }
        "settings.schema.json" = @{
            type                 = "object"
            properties           = @{
                '$schema'         = @{ type = "string" }
                activeProviders   = @{ type = "array"; items = @{ type = "string" } }
                instructions      = @{ type = "array"; items = @{ type = "string" } }
            }
            required             = @("activeProviders")
            additionalProperties = $false
        }
        "provider.schema.json" = @{
            type                 = "object"
            properties           = @{
                id       = @{ type = "string" }
                provider = @{ type = "object" }
            }
            required             = @("id", "provider")
            additionalProperties = $false
        }
        "models.schema.json" = @{
            type                 = "object"
            properties           = @{ models = @{ type = "object" } }
            required             = @("models")
            additionalProperties = $false
        }
        "plugins.schema.json" = @{
            type                 = "object"
            properties           = @{ plugin = @{ type = "array"; items = @{ type = "string" } } }
            required             = @("plugin")
            additionalProperties = $false
        }
        "mcp.schema.json" = @{
            type                 = "object"
            properties           = @{ mcp = @{ type = "object" } }
            required             = @("mcp")
            additionalProperties = $false
        }
        "targets.schema.json" = @{
            type                 = "object"
            properties           = @{ artifact = @{ type = "string" } }
            required             = @("artifact")
            additionalProperties = $false
        }
    }

    foreach ($SchemaName in $Schemas.Keys) {

        Write-JsonObject $Root "schemas\$SchemaName" $Schemas[$SchemaName]
    }
}

function Assert-GeneratedExists {

    param(
        [string]$Root,
        [bool]$ShouldExist
    )

    $Generated = Join-Path $Root "opencode.json"

    $Exists = Test-Path $Generated

    if ($ShouldExist -and -not $Exists) { throw "opencode.json was not generated." }
    if (-not $ShouldExist -and $Exists) { throw "opencode.json should NOT have been generated." }
}

# ------------------------------------------------------------
# Test 14 - Schema validation: valid sources pass
# ------------------------------------------------------------

function Test-SchemaValidPasses {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        Assert-True ($Run.Output.Contains("All sources pass schema validation")) `
            "Expected schema validation success. Output: $($Run.Output)"

        Assert-GeneratedExists $Root $true
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 15 - Schema validation: settings missing required fails
# ------------------------------------------------------------

function Test-SchemaSettingsMissingRequiredFails {

    $Root = New-V25Root

    try {

        Write-Schemas $Root

        Write-JsonFile $Root "profiles\default\settings.json" @'
{
    "$schema": "https://opencode.ai/config.schema.json"
}
'@

        # A valid provider file so discovery passes; settings is what fails.
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail when settings is missing activeProviders."

        Assert-True ($Run.Output.Contains("Schema 'settings.schema.json'")) `
            "Expected a settings schema failure. Output: $($Run.Output)"

        Assert-True ($Run.Output.Contains("activeProviders is required")) `
            "Expected a required-field message. Output: $($Run.Output)"

        Assert-GeneratedExists $Root $false
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 16 - Schema validation: wrong type fails
# ------------------------------------------------------------

function Test-SchemaWrongTypeFails {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-JsonFile $Root "profiles\default\settings.json" @'
{
    "$schema": "https://opencode.ai/config.schema.json",
    "activeProviders": "omniroute"
}
'@

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail on a wrong activeProviders type."

        Assert-True ($Run.Output.Contains("type mismatch")) `
            "Expected a type-mismatch message. Output: $($Run.Output)"

        Assert-True ($Run.Output.Contains("Schema 'settings.schema.json'")) `
            "Expected a settings schema failure. Output: $($Run.Output)"

        Assert-True ($Run.Output.Contains("Schema 'settings.schema.json'")) `
            "Expected a settings schema failure. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 17 - Schema validation: additionalProperties fails
# ------------------------------------------------------------

function Test-SchemaAdditionalPropertyFails {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-JsonFile $Root "profiles\default\settings.json" @'
{
    "$schema": "https://opencode.ai/config.schema.json",
    "activeProviders": ["omniroute"],
    "extra": 1
}
'@

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail on an unexpected settings property."

        Assert-True ($Run.Output.Contains("extra is not defined")) `
            "Expected an additionalProperties message. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 17b - Schema validation: real-world settings.json accepted
# ------------------------------------------------------------

function Test-SchemaRealSettingsAccepted {

    # A real profile settings.json carries $schema, activeProviders AND
    # instructions (e.g. ["AGENTS.md"]) - the instructions key is part of
    # the OpenCode settings shape and must pass schema compliance (F1).

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-JsonFile $Root "profiles\default\settings.json" @'
{
    "$schema": "https://opencode.ai/config.schema.json",
    "activeProviders": ["omniroute"],
    "instructions": ["AGENTS.md"]
}
'@

        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder must accept a real-world settings.json with instructions. Output: $($Run.Output)"

        Assert-True ($Run.Output.Contains("All sources pass schema validation")) `
            "Expected schema validation success. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 18 - Schema validation: provider violation fails
# ------------------------------------------------------------

function Test-SchemaProviderViolationFails {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute")

        Write-JsonFile $Root "providers\omniroute.json" @'
{
    "id": "omniroute",
    "provider": { "omniroute": { "name": "OmniRoute" } },
    "extra": 1
}
'@

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail on an unexpected provider property."

        Assert-True ($Run.Output.Contains("Schema 'provider.schema.json'")) `
            "Expected a provider schema failure. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 19 - Schema validation: models violation fails
# ------------------------------------------------------------

function Test-SchemaModelsViolationFails {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        Write-JsonFile $Root "profiles\default\models.json" @'
{
    "models": { "m-1": { "name": "One" } },
    "extra": 1
}
'@

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail on an unexpected models property."

        Assert-True ($Run.Output.Contains("Schema 'models.schema.json'")) `
            "Expected a models schema failure. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 20 - Schema validation: no schema dir warns + continues
# ------------------------------------------------------------

function Test-SchemaMissingDirWarnsAndContinues {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder must continue without a schema dir. Exit: $($Run.ExitCode)"

        Assert-True ($Run.Output.Contains("skipping schema validation")) `
            "Expected a skip warning. Output: $($Run.Output)"

        Assert-GeneratedExists $Root $true
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 21 - Pre-flight: missing provider file aborts
# ------------------------------------------------------------

function Test-PreflightMissingProviderAborts {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("ghost")
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -ne 0) "Builder must fail pre-flight on a missing provider file."

        Assert-True ($Run.Output.Contains("Pre-flight failed")) `
            "Expected a pre-flight failure. Output: $($Run.Output)"

        Assert-True ($Run.Output.Contains("ghost.json")) `
            "Pre-flight must name the missing provider file. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 22 - -WhatIf dry run writes nothing
# ------------------------------------------------------------

function Test-WhatIfWritesNothing {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -NonInteractive -WhatIf

        Assert-True ($Run.ExitCode -eq 0) "WhatIf must exit 0. Exit: $($Run.ExitCode): $($Run.Output)"

        Assert-True ($Run.Output.Contains("Would write opencode.json")) `
            "Expected the dry-run notice. Output: $($Run.Output)"

        Assert-GeneratedExists $Root $false
        Assert-True (!(Test-Path (Join-Path $Root "opencode.provenance.json"))) `
            "WhatIf must not write the provenance sidecar."

        $Backups = @(Get-ChildItem -Path (Join-Path $Root "backup") -Filter "opencode_*.json" -File -ErrorAction SilentlyContinue)

        Assert-True ($Backups.Count -eq 0) "WhatIf must not create backup files."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 23 - -Doctor clean config exits 0
# ------------------------------------------------------------

function Test-DoctorCleanExitsZero {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"

        $Run = Invoke-Builder $Root -Doctor

        Assert-True ($Run.ExitCode -eq 0) "Doctor must exit 0 on clean config. Exit: $($Run.ExitCode): $($Run.Output)"

        Assert-True ($Run.Output.Contains("configuration is clean")) `
            "Expected a clean report. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 24 - -Doctor corrupt config exits 1
# ------------------------------------------------------------

function Test-DoctorCorruptExitsOne {

    $Root = New-V25Root

    try {

        Write-ProfileSettings -Root $Root -Active "not-a-provider"

        $Run = Invoke-Builder $Root -Doctor

        Assert-True ($Run.ExitCode -eq 1) "Doctor must exit 1 on a corrupt config. Exit: $($Run.ExitCode): $($Run.Output)"

        Assert-True ($Run.Output.Contains("issue")) `
            "Expected issue diagnostics. Output: $($Run.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 25 - Backup retention honors -KeepBackups
# ------------------------------------------------------------

function Test-BackupRetentionHonordsKeepBackups {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active "omniroute"
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        for ($i = 0; $i -lt 4; $i++) {

            $Run = Invoke-Builder $Root -NonInteractive -KeepBackups 2

            Assert-True ($Run.ExitCode -eq 0) "Build $i failed: $($Run.Output)"
        }

        $Backups = @(Get-ChildItem -Path (Join-Path $Root "backup") -Filter "opencode_*.json" -File)

        Assert-True ($Backups.Count -le 2) "Retention must keep at most 2 backups, found $($Backups.Count)."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 26 - Provenance sidecar fields + sha
# ------------------------------------------------------------

function Test-ProvenanceSidecarCorrect {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active "omniroute"
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        Assert-True (Test-Path (Join-Path $Root "opencode.provenance.json")) `
            "Provenance sidecar must exist after a real build."

        $Prov = Get-Content (Join-Path $Root "opencode.provenance.json") -Raw | ConvertFrom-Json

        Assert-True ($Prov.builderVersion -eq "V2.7") "Wrong builderVersion: $($Prov.builderVersion)"

        Assert-True ($Prov.profile -eq "default") "Wrong profile: $($Prov.profile)"

        Assert-True (@($Prov.providers) -join "," -eq "omniroute") `
            "Wrong providers list: $($Prov.providers -join ',')"

        $Raw = Get-Content (Join-Path $Root "opencode.json") -Raw

        $Sha = [System.Security.Cryptography.SHA256]::Create()
        $Hex = [System.BitConverter]::ToString($Sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Raw))).Replace("-", "").ToLower()

        Assert-True ($Prov.outputSha256 -eq $Hex) `
            "outputSha256 mismatch. Prov: $($Prov.outputSha256) File: $Hex"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 27 - Diff summary Added/Removed lines; identical silent
# ------------------------------------------------------------

function Test-DiffSummaryLinesAndSilence {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active "omniroute"
        Write-ValidProvider $Root "modal" "Modal"
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        # Identical second run => no Added/Removed lines.
        $Run1 = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run1.ExitCode -eq 0) "Build 1 failed: $($Run1.Output)"

        $Run2 = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run2.ExitCode -eq 0) "Build 2 failed: $($Run2.Output)"

        Assert-True ($Run2.Output.Contains("No changes detected")) `
            "Identical input must produce no diff lines. Output: $($Run2.Output)"

        # Provider change => Added lines.
        $Run3 = Invoke-Builder $Root -NonInteractive -Provider "modal"

        Assert-True ($Run3.ExitCode -eq 0) "Build 3 failed: $($Run3.Output)"

        Assert-True ($Run3.Output.Contains("Added provider: modal")) `
            "Expected 'Added provider: modal'. Output: $($Run3.Output)"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 28 - Real BUILDER_SPEC.md covers the V2.7 tokens (F1-F7)
# ------------------------------------------------------------

function Test-BuilderSpecCoversV27 {

    # Resolve relative to the harness so bootstrapped copies (scaffold-agent)
    # never inherit a hardcoded machine path. The doc is project-owned and
    # optional: when absent, the token coverage check is skipped, not failed.

    $SpecPath = Join-Path (Split-Path $PSScriptRoot -Parent) "docs\BUILDER_SPEC.md"

    if (-not (Test-Path $SpecPath)) {

        Write-Host "[i] BUILDER_SPEC.md not present - skipping spec token coverage (project doc optional)."
        return
    }

    $Spec = Get-Content $SpecPath -Raw

    foreach ($Token in @(
        "Test-SchemaCompliance",
        "Assert-InputFilesExist",
        "Write-ProvenanceFile",
        "Compare-BackupDiff",
        "-SchemaDir",
        "-KeepBackups",
        "-WhatIf",
        "-Doctor",
        "-ProvenancePath"
    )) {

        Assert-True $Spec.Contains($Token) "BUILDER_SPEC.md is missing the token: $Token"
    }
}

# ------------------------------------------------------------
# Test 29 - Dynamic target artifact (P2): profiles/<profile>/target.json
# ------------------------------------------------------------

function Test-DynamicTargetArtifact {

    $Root = New-V25Root -Profile "alt"

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute") -Profile "alt"
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "alt" @{ "m-1" = @{ name = "Model One" } }

        # Non-opencode artifact proves config-driven resolution.
        Write-JsonFile $Root "profiles\alt\target.json" '{ "artifact": "claude.json" }'

        # WhatIf advertises the dynamic artifact, not the default.
        $RunWhatIf = Invoke-Builder $Root -WhatIf -Profile "alt"

        Assert-True ($RunWhatIf.ExitCode -eq 0) "WhatIf failed: $($RunWhatIf.Output)"

        Assert-True ($RunWhatIf.Output.Contains("claude.json")) `
            "WhatIf must name the dynamic artifact. Output: $($RunWhatIf.Output)"

        Assert-True ($RunWhatIf.Output.Contains("claude.provenance.json")) `
            "WhatIf must name the dynamic provenance. Output: $($RunWhatIf.Output)"

        $Run = Invoke-Builder $Root -NonInteractive -Profile "alt"

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        Assert-True (Test-Path (Join-Path $Root "claude.json")) `
            "Dynamic artifact 'claude.json' was not generated."

        Assert-True (!(Test-Path (Join-Path $Root "opencode.json"))) `
            "Default 'opencode.json' must not be generated for a dynamic target."

        Assert-True (Test-Path (Join-Path $Root "claude.provenance.json")) `
            "Dynamic provenance 'claude.provenance.json' must exist."

        Assert-True (!(Test-Path (Join-Path $Root "opencode.provenance.json"))) `
            "Default provenance must not be generated for a dynamic target."

        # Second real build so a backup of the pre-existing claude.json exists.
        $Run2 = Invoke-Builder $Root -NonInteractive -Profile "alt"

        Assert-True ($Run2.ExitCode -eq 0) "Second build failed: $($Run2.Output)"

        $Backups = @(Get-ChildItem -Path (Join-Path $Root "backup") -Filter "claude_*.json" -File -ErrorAction SilentlyContinue)

        Assert-True ($Backups.Count -gt 0) "Backup must use the dynamic prefix 'claude_*'."

        $LegacyBackups = @(Get-ChildItem -Path (Join-Path $Root "backup") -Filter "opencode_*.json" -File -ErrorAction SilentlyContinue)

        Assert-True ($LegacyBackups.Count -eq 0) "Backup must NOT use the legacy 'opencode_*' prefix."

        $Generated = Get-Content (Join-Path $Root "claude.json") -Raw | ConvertFrom-Json

        Assert-True ($null -ne $Generated.provider.omniroute) "Provider 'omniroute' missing from dynamic output."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 30 - No literal API keys in generated output (P1 gate)
# ------------------------------------------------------------

function Test-NoLiteralKeysInOutput {

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        # Provider carries a placeholder key (the only sanctioned form).
        Write-JsonFile $Root "providers\omniroute.json" @'
{
    "id": "omniroute",
    "provider": {
        "omniroute": {
            "name": "OmniRoute",
            "apiKey": "{env:OMNIROUTE_API_KEY_TEST}"
        }
    }
}
'@

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder exited with code $($Run.ExitCode): $($Run.Output)"

        $Raw = Get-Content (Join-Path $Root "opencode.json") -Raw

        Assert-True ($Raw.Contains("{env:OMNIROUTE_API_KEY_TEST}")) `
            "Env placeholder must flow into the generated output."

        Assert-True ($Raw -notmatch '"apiKey"\s*:\s*"(?!\{env:)') `
            "Generated output contains an apiKey that is not an {env:...} placeholder."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 21 - Reasoning-format variant shapes pass + merge
# ------------------------------------------------------------

function Test-ReasoningFormatVariantsMerge {

    # The app writes per-provider reasoning formats: openai (reasoningEffort),
    # claude (thinking.budgetTokens), gemini (thinkingConfig.thinkingBudget).
    # The provider file may carry the optional reasoningFormat field. All of
    # these must pass schema validation and merge into the built config.

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("gpt")

        Write-JsonObject $Root "providers\gpt.json" @{
            id       = "gpt"
            provider = @{
                gpt = @{
                    name            = "GPT"
                    reasoningFormat = "openai"
                    npm             = "@ai-sdk/openai-compatible"
                }
            }
        }

        Write-ProfileProviderModels $Root "default" "gpt" @{
            "gpt-5.5"       = @{
                name     = "GPT 5.5"
                variants = @{
                    low   = @{ reasoningEffort = "low" }
                    high  = @{ reasoningEffort = "high" }
                    xhigh = @{ reasoningEffort = "xhigh" }
                }
            }
            "claude-sonnet" = @{
                name     = "Claude Sonnet"
                variants = @{
                    low  = @{ thinking = @{ type = "enabled"; budgetTokens = 8000 } }
                    high = @{ thinking = @{ type = "enabled"; budgetTokens = 16000 } }
                    max  = @{ thinking = @{ type = "enabled"; budgetTokens = 32000 } }
                }
            }
            "gemini-flash"  = @{
                name     = "Gemini Flash"
                variants = @{
                    medium = @{ thinkingConfig = @{ thinkingBudget = 16384 } }
                }
            }
        }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder must accept reasoning-format variant shapes. Exit: $($Run.ExitCode): $($Run.Output)"

        Assert-True ($Run.Output.Contains("All sources pass schema validation")) `
            "Expected schema validation success. Output: $($Run.Output)"

        $Final = Read-Generated $Root
        $Models = $Final.provider.gpt.models

        Assert-True ($Models."gpt-5.5".variants.xhigh.reasoningEffort -eq "xhigh") `
            "OpenAI reasoningEffort variant must survive the merge."

        Assert-True ($Models."claude-sonnet".variants.high.thinking.budgetTokens -eq 16000) `
            "Claude budgetTokens variant must survive the merge."

        Assert-True ($Models."gemini-flash".variants.medium.thinkingConfig.thinkingBudget -eq 16384) `
            "Gemini thinkingBudget variant must survive the merge."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 22 - Reasoning format enforcement: only truly unknown levels dropped
# ------------------------------------------------------------

function Test-ReasoningFormatEnforcement {

    # Non-interactive: a provider with reasoningFormat=openai and a models
    # file carrying a 'max' variant (not an openai level, but valid in the
    # opencode format) must keep 'max' - levels valid in ANY known format
    # survive the merge. Only levels valid in NO known format are dropped.

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("gpt")

        Write-JsonObject $Root "providers\gpt.json" @{
            id       = "gpt"
            provider = @{
                gpt = @{
                    name            = "GPT"
                    reasoningFormat = "openai"
                    npm             = "@ai-sdk/openai-compatible"
                }
            }
        }

        Write-ProfileProviderModels $Root "default" "gpt" @{
            "gpt-5.5" = @{
                name     = "GPT 5.5"
                variants = @{
                    low      = @{ reasoningEffort = "low" }
                    max      = @{ reasoningEffort = "max" }   # valid in opencode format
                    high     = @{ reasoningEffort = "high" }
                    madeup   = @{ reasoningEffort = "madeup" } # invalid everywhere
                }
            }
        }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder must succeed. Exit: $($Run.ExitCode): $($Run.Output)"

        Assert-True ($Run.Output.Contains("variant 'madeup' dropped")) `
            "Expected a dropped-variant warning for 'madeup'. Output: $($Run.Output)"

        $Final = Read-Generated $Root
        $Variants = $Final.provider.gpt.models."gpt-5.5".variants

        Assert-True ($Variants.PSObject.Properties.Name -contains "low") "low must survive."
        Assert-True ($Variants.PSObject.Properties.Name -contains "high") "high must survive."
        Assert-True ($Variants.PSObject.Properties.Name -contains "max") "max must survive - it is a valid level in the opencode format."
        Assert-True ($Variants.PSObject.Properties.Name -notcontains "madeup") "madeup must be dropped from the generated config."
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Test 23 - Output parity: every source variant survives the merge
# ------------------------------------------------------------

function Test-SourceVariantParity {

    # A provider with a non-opencode level set (high/low/medium/xhigh) must
    # carry EVERY source variant in the generated config - the build must
    # never silently drop model data. Guards the any-format filter.

    $Root = New-V25Root

    try {

        Write-Schemas $Root
        Write-ProfileSettings $Root -Active @("gpt")

        Write-JsonObject $Root "providers\gpt.json" @{
            id       = "gpt"
            provider = @{
                gpt = @{
                    name            = "GPT"
                    reasoningFormat = "opencode"
                    npm             = "@ai-sdk/openai-compatible"
                }
            }
        }

        Write-ProfileProviderModels $Root "default" "gpt" @{
            "gpt-5.5" = @{
                name     = "GPT 5.5"
                variants = @{
                    high   = @{ reasoningEffort = "high" }
                    low    = @{ reasoningEffort = "low" }
                    medium = @{ reasoningEffort = "medium" }
                    xhigh  = @{ reasoningEffort = "xhigh" }
                }
            }
        }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "Builder must succeed. Exit: $($Run.ExitCode): $($Run.Output)"
        Assert-True (-not $Run.Output.Contains("dropped")) "No source variant may be dropped. Output: $($Run.Output)"

        $Variants = (Read-Generated $Root).provider.gpt.models."gpt-5.5".variants

        foreach ($Level in @("high", "low", "medium", "xhigh")) {

            Assert-True ($Variants.PSObject.Properties.Name -contains $Level) "variant '$Level' must survive the merge."
        }
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# V2.7 LSP group: lsp.json -> generated lsp key
# ------------------------------------------------------------

function Write-LspFixture {

    # Minimal valid profile fixture shared by the LSP tests:
    # one active provider with models so the build reaches the
    # merge/verification stages, plus profiles\<profile>\lsp.json.

    param(
        [string]$Root,
        [string]$LspJson
    )

    Write-ProfileSettings $Root -Active @("omniroute")
    Write-ValidProvider $Root "omniroute" "OmniRoute"
    Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

    Write-JsonFile $Root "profiles\default\lsp.json" $LspJson
}

function Test-LspEnabledTrue {

    $Root = New-V25Root

    try {

        Write-LspFixture $Root '{ "lsp": true, "enabled": true }'

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "builder failed: $($Run.Output)"

        $Out = Read-Generated $Root

        Assert-True ($Out.lsp -eq $true) "lsp true not emitted"
    }
    finally {

        Remove-TestRoot $Root
    }
}

function Test-LspEnabledObject {

    $Root = New-V25Root

    try {

        Write-LspFixture $Root '{ "lsp": { "typescript": { "command": ["typescript-language-server","--stdio"], "extensions": [".ts"] } }, "enabled": true }'

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "builder failed: $($Run.Output)"

        $Out = Read-Generated $Root

        Assert-True ($Out.lsp.typescript.command -join " " -eq "typescript-language-server --stdio") "lsp object not round-tripped"
    }
    finally {

        Remove-TestRoot $Root
    }
}

function Test-LspDisabled {

    $Root = New-V25Root

    try {

        Write-LspFixture $Root '{ "lsp": true, "enabled": false }'

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "builder failed: $($Run.Output)"

        $Out = Read-Generated $Root

        Assert-True ($Out.PSObject.Properties['lsp'] -and $Out.lsp -eq $false) "lsp must be present as false while disabled"
    }
    finally {

        Remove-TestRoot $Root
    }
}

function Test-LspFileAbsent {

    $Root = New-V25Root

    try {

        Write-ProfileSettings $Root -Active @("omniroute")
        Write-ValidProvider $Root "omniroute" "OmniRoute"
        Write-ProfileModels $Root "default" @{ "m-1" = @{ name = "Model One" } }

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "builder failed: $($Run.Output)"

        $Out = Read-Generated $Root

        Assert-True ($null -eq $Out.PSObject.Properties['lsp']) "lsp emitted without lsp.json"
    }
    finally {

        Remove-TestRoot $Root
    }
}

function Test-LspFalseValue {

    $Root = New-V25Root

    try {

        Write-LspFixture $Root '{ "lsp": false, "enabled": true }'

        $Run = Invoke-Builder $Root -NonInteractive

        Assert-True ($Run.ExitCode -eq 0) "builder failed: $($Run.Output)"

        $Out = Read-Generated $Root

        Assert-True ($Out.PSObject.Properties['lsp'] -and $Out.lsp -eq $false) "explicit false value must emit lsp false"
    }
    finally {

        Remove-TestRoot $Root
    }
}

# ------------------------------------------------------------
# Run tests
# ------------------------------------------------------------

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   OpenCode Config Builder v2.7 Test Harness" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Run-Test "All providers discovered"             { Test-AllProvidersDiscovered }
Run-Test "Malformed provider fails"             { Test-MalformedProviderFails }
Run-Test "Non-interactive uses stored"          { Test-NonInteractiveUsesStored }
Run-Test "Provider arg skips prompt"            { Test-ProviderArgSkipsPrompt }
Run-Test "Provider arg unknown fails"           { Test-ProviderArgUnknownFails }
Run-Test "Profile models highest precedence"    { Test-ProfileModelsHighestPrecedence }
Run-Test "apiModelId aliases output key"        { Test-ApiModelIdAliasesOutputKey }
Run-Test "Non-active profile models ignored"    { Test-NonActiveProfileModelsIgnored }
Run-Test "Settings persist round-trip"          { Test-SettingsPersistRoundTrip }
Run-Test "Settings backup created"              { Test-SettingsBackupCreated }
Run-Test "Empty selection fails"                { Test-EmptySelectionFails }
Run-Test "Profile models dup key fails"         { Test-ProfileModelsDupKeyFails }
Run-Test "Builder spec covers V2.5"             { Test-BuilderSpecCoversV25 }
Run-Test "Active provider no models dropped"    { Test-ActiveProviderNoModelsDropped }
Run-Test "Schema valid sources pass"            { Test-SchemaValidPasses }
Run-Test "Schema settings missing required fails" { Test-SchemaSettingsMissingRequiredFails }
Run-Test "Schema wrong type fails"              { Test-SchemaWrongTypeFails }
Run-Test "Schema additional property fails"     { Test-SchemaAdditionalPropertyFails }
Run-Test "Schema real settings accepted"        { Test-SchemaRealSettingsAccepted }
Run-Test "Schema provider violation fails"      { Test-SchemaProviderViolationFails }
Run-Test "Schema models violation fails"        { Test-SchemaModelsViolationFails }
Run-Test "Schema missing dir warns + continues" { Test-SchemaMissingDirWarnsAndContinues }
Run-Test "Pre-flight missing provider aborts"   { Test-PreflightMissingProviderAborts }
Run-Test "WhatIf writes nothing"                { Test-WhatIfWritesNothing }
Run-Test "Doctor clean exits 0"                 { Test-DoctorCleanExitsZero }
Run-Test "Doctor corrupt exits 1"               { Test-DoctorCorruptExitsOne }
Run-Test "Backup retention honors keep"         { Test-BackupRetentionHonordsKeepBackups }
Run-Test "Provenance sidecar correct"           { Test-ProvenanceSidecarCorrect }
Run-Test "Diff summary lines + silence"         { Test-DiffSummaryLinesAndSilence }
Run-Test "Builder spec covers V2.7"             { Test-BuilderSpecCoversV27 }
Run-Test "Dynamic target artifact"              { Test-DynamicTargetArtifact }
Run-Test "No literal keys in output"            { Test-NoLiteralKeysInOutput }
Run-Test "Reasoning-format variants merge"      { Test-ReasoningFormatVariantsMerge }
Run-Test "Reasoning-format enforcement"         { Test-ReasoningFormatEnforcement }
Run-Test "Output parity: source variants survive" { Test-SourceVariantParity }
Run-Test "LSP enabled true"                   { Test-LspEnabledTrue }
Run-Test "LSP enabled object round-trip"      { Test-LspEnabledObject }
Run-Test "LSP disabled emits false"           { Test-LspDisabled }
Run-Test "No lsp.json omits section"          { Test-LspFileAbsent }
Run-Test "LSP false value emits false"        { Test-LspFalseValue }

$Stopwatch.Stop()

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

$Passed = @($TestResults | Where-Object { $_.Result -eq "PASS" }).Count
$Failed = @($TestResults | Where-Object { $_.Result -eq "FAIL" }).Count

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "             TEST RESULTS" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

foreach ($Result in $TestResults) {

    $Line = "{0,-34} {1}" -f $Result.Name, $Result.Result

    if ($Result.Result -eq "PASS") {

        Write-Host $Line -ForegroundColor Green
    }
    else {

        Write-Host $Line -ForegroundColor Red
    }
}

Write-Host ""

# Print failure details
foreach ($Result in $TestResults) {

    if ($Result.Result -eq "FAIL" -and $Result.Error) {

        Write-Host "Failure details for '$($Result.Name)':" -ForegroundColor Red
        Write-Host "    $($Result.Error)" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Tests      : " -NoNewline
Write-Host "$Passed/$($TestResults.Count) Passed" -ForegroundColor Green

Write-Host "Failed     : " -NoNewline
Write-Host $Failed -ForegroundColor Red

Write-Host "Build Time : " -NoNewline
Write-Host "$($Stopwatch.ElapsedMilliseconds) ms" -ForegroundColor Cyan

Write-Host ""

if ($Failed -gt 0) {

    Write-Host "[x] $Failed test(s) failed." -ForegroundColor Red

    exit 1
}

Write-Host "[+] All tests passed." -ForegroundColor Green

exit 0