# ============================================================
# scaffold-agent.ps1 - Universal Coding-Agent Scaffold  (V3)
# ============================================================
# Author  : Love (owner)
#           ChatGPT (early planning/blueprints)
#           OpenCode / deepseek-v4-flash-free (primary implementation)
# Purpose : V3 UNIVERSAL behavioral core. The framework's ONE job, the SAME
#           for ANY open-source coding agent (OpenCode, KiloCode, Aider, Goose,
#           Codex-Cli, ...). Claude Code is registered for DISCOVERY ONLY and is
#           NOT a scaffold target (dropped 2026-08-08 - see planning/DECISIONS.md).
#
# THE CONTRACT (V3):
#   1. DISCOVER which coding agents are installed on this machine.
#      Only open-source agents with local .json configs are scanned.
#      Closed-source agents are never touched.
#   2. If no known agent is found, the framework ASKS the user for the
#      location of their coding agent (a config folder).
#   3. Scan the agent's OWN main .json config FIRST, read-only.
#      The main config is the agent's own file (kilo.json for KiloCode,
#      opencode.json for OpenCode, ...). NEVER another agent's config.
#   4. Split the main config into sections: mcp / plugin / settings.
#      (The provider section is DETECTED for guidance only - see rule 7.)
#   5. Create the profile folders - ALWAYS these three:
#         profiles/coding/       (the MAIN profile, always coding)
#         profiles/experimental/
#         profiles/minimal/
#      Each profile contains exactly three files:
#         settings.json   - written by the framework (schema + shape)
#         mcp.json        - coding: seeded from the main config's mcp section;
#                           experimental/minimal: created EMPTY, never filled
#         plugins.json    - coding: seeded from the main config's plugin section;
#                           experimental/minimal: created EMPTY, never filled
#   6. NEVER overwrite mcp.json / plugins.json once they exist - the user
#      owns those files. The framework only writes settings.json.
#   7. NEVER write provider or model JSON files - the framework creates the
#      providers/ folder (like the profile folders), but provider and model
#      files inside it are 100% user-owned; the framework prints guidance.
#   8. Never touch .jsonc / non-.json without explicit user consent.
#   9. Everything is generated from the agent's OWN main config. No work is
#      done BEFORE scanning. Errors are always user-reportable + fixable.
# ============================================================

[CmdletBinding()]
param(
    [string]$Agent = "",               # explicit agent name (registry or custom)
    [string]$ConfigRoot = "",          # explicit config dir (custom agents)
    [switch]$NonInteractive,
    [switch]$List,                     # list discovered agents only
    [switch]$Bootstrap,                # after scaffold, also bootstrap a builder
    [string]$BuilderSource = ""        # source builder to adapt (bootstrap)
)

$ErrorActionPreference = "Stop"

# ---- V3 error self-fix: any error becomes a diagnosed, fixable report ----
trap {
    Write-Host ""
    Write-Host "[!] Scaffold error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Diagnosis (V3 rule): check that"
    Write-Host "      1. the config path is correct and contains a .json main file,"
    Write-Host "      2. the agent you named is in `AgentRegistry` (or pass -ConfigRoot),"
    Write-Host "      3. you aren't pointing at a .jsonc-only folder (framework needs consent)."
    Write-Host "    Re-run after fixing; the generated builder also supports -Doctor."
    Write-Host ""
    Write-Host "[x] Framework did NOT complete. Fix the reported error and rerun." -ForegroundColor Red
    exit 1
}

function Show-Credits {
    Write-Host ""
    Write-Host "  Framework : OpenCode / deepseek-v4-flash-free (primary implementation)"
    Write-Host "  Planning  : ChatGPT"
    Write-Host "  Owner     : Love"
}

# ------------------------------------------------------------
# V3 OPEN-SOURCE AGENT REGISTRY - add any open-source coding agent here.
# Each entry: Name, Home (config dir relative to HOME), Main (JSON file names),
# PluginKey (JSON keys that hold plugins), Schema (settings schema url).
# Closed-sourced agents are intentionally NOT in this registry.
# ------------------------------------------------------------
$AgentRegistry = @(
    @{ Name = "opencode";   Home = ".config\opencode"; Main = @("opencode.json");       PlugKeys = @("plugin");       Schema = "https://opencode.ai/config.schema.json" }
    @{ Name = "kilo";       Home = ".config\kilo";     Main = @("kilo.json", "kilo.jsonc"); PlugKeys = @("plugin", "skills.urls"); Schema = "https://app.kilo.ai/config.json" }
    @{ Name = "claudecode"; Home = ".claude";          Main = @(".claude.json", "settings.json"); PlugKeys = @("plugins"); Schema = "" }  # discovery only - NOT a scaffold target (dropped 2026-08-08)
    @{ Name = "aider";      Home = ".aider";           Main = @(".aider.conf.json");    PlugKeys = @("plugins"); Schema = "" }
    @{ Name = "goose";      Home = ".config\goose";    Main = @("config.json");         PlugKeys = @("plugins"); Schema = "" }
    @{ Name = "codex-cli";  Home = ".codex";           Main = @("config.toml");         PlugKeys = @("plugins"); Schema = "" }
)

# ---- discover installed open-source coding agents ----
function Find-DiscoveredAgents {
    $Found = @()
    foreach ($Reg in $AgentRegistry) {
        $Dir = Join-Path $HOME $Reg.Home
        if (-not (Test-Path $Dir)) { continue }
        $MainHit = @($Reg.Main | Where-Object { Test-Path (Join-Path $Dir $_) } | Select-Object -First 1)
        if ($MainHit.Count -gt 0) {
            $Found += [pscustomobject]@{ Name = $Reg.Name; Dir = $Dir; Main = $MainHit[0] }
        }
    }
    return $Found
}

if ($List) {
    $D = @(Find-DiscoveredAgents)
    if ($D.Count -eq 0) { Write-Host "[i] No known open-source coding agents found in standard locations." }
    else {
        Write-Host "[+] Discovered open-source coding agents:"
        foreach ($A in $D) { Write-Host ("    - {0,-12} {1}  ({2})" -f $A.Name, $A.Dir, $A.Main) }
    }
    exit 0
}

# ---- resolve the target agent (explicit > discover > ask) ----
if ($Agent -eq "") {
    $Discovered = @(Find-DiscoveredAgents)
    if ($Discovered.Count -eq 1) {
        $Agent      = $Discovered[0].Name
        $ConfigRoot = if ($ConfigRoot -eq "") { $Discovered[0].Dir } else { $ConfigRoot }
        Write-Host "[i] Agent auto-detected: $Agent (only open-source coding agent present)."
    }
    elseif ($Discovered.Count -gt 1) {
        if ($NonInteractive) {
            $Agent      = $Discovered[0].Name
            $ConfigRoot = $Discovered[0].Dir
            Write-Host "[i] Multiple agents found; -NonInteractive picked first: $Agent"
        }
        else {
            Write-Host "[?] Multiple open-source coding agents found:"
            for ($i = 0; $i -lt $Discovered.Count; $i++) {
                Write-Host ("    [{0}] {1} ({2})" -f $i, $Discovered[$i].Name, $Discovered[$i].Main)
            }
            try { $Choice = Read-Host "    Choose one (0-$($Discovered.Count-1))" } catch { $Choice = "0" }
            $idx = 0
            if ([int]::TryParse($Choice, [ref]$idx)) {
                if ($idx -lt 0 -or $idx -ge $Discovered.Count) { $idx = 0 }
            }
            $Agent      = $Discovered[$idx].Name
            $ConfigRoot = $Discovered[$idx].Dir
        }
    }
    if ($Agent -eq "") {
        # No known agent found on system -> ask the user for location
        Write-Host "[?] The framework could not find a coding agent automatically on this machine."
        try { $Answer = Read-Host "    Give me the location of your coding agents (config folder)" } catch { $Answer = "" }
        if ([string]::IsNullOrWhiteSpace($Answer) -or -not (Test-Path $Answer)) {
            throw "No coding agent found and no valid location given. Framework aborted (user guided)."
        }
        $ConfigRoot = $Answer
        $Agent      = [System.IO.Path]::GetFileName($ConfigRoot.TrimEnd('\'))
        Write-Host "[i] Custom agent location accepted: $ConfigRoot (agent: $Agent)"
    }
}
else {
    if ($ConfigRoot -eq "") {
        $Reg = $AgentRegistry | Where-Object Name -eq $Agent | Select-Object -First 1
        if ($Reg) { $ConfigRoot = Join-Path $HOME $Reg.Home }
        else      { throw "Unknown agent '$Agent'. Pass -ConfigRoot or add it to the registry." }
    }
}

$ProfilesRoot = Join-Path $ConfigRoot "profiles"
$Reg2 = $AgentRegistry | Where-Object Name -eq $Agent | Select-Object -First 1
$PluginKeys     = if ($Reg2) { $Reg2.PlugKeys } else { @("plugin", "skills.urls") }
$SchemaUrl      = if ($Reg2 -and $Reg2.Schema) { $Reg2.Schema } else { "" }

# ---- 1. locate the agent's OWN main config file (READ-ONLY, first) ----
# V3 rule: only the agent's OWN primary main config is scanned - never another
# agent's config, never profile files, never backup/provenance/system files.
# Only the FIRST main file in registry order is the source of truth, so a
# polluted/duplicate secondary file can never leak into the profiles.
$MainFiles = @()
$CandidateNames = if ($Reg2) { $Reg2.Main } else { @("*.json") }
foreach ($Pattern in $CandidateNames) {
    if ($MainFiles.Count -gt 0) { break }
    if ($Pattern -like "*.*") {
        $Pj = Join-Path $ConfigRoot $Pattern
        if (Test-Path -LiteralPath $Pj) { $MainFiles += $Pj }
    }
}
if ($MainFiles.Count -eq 0) {
    # fallback (custom agents / glob): any top-level .json that is NOT a
    # system/profile file. Expand the glob first - never pass '*' to a reader.
    $GlobHits = @(Get-ChildItem $ConfigRoot -File -Filter *.json -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch "^(package|package-lock|tsconfig|changelog|release|settings|mcp|plugins|target|.*models|.*provenance)" } |
        Sort-Object Name)
    if ($GlobHits.Count -gt 0) { $MainFiles += $GlobHits[0].FullName }
}
$MainFiles = @($MainFiles | Select-Object -Unique)

# ---- non-.json? ONLY WITH USER CONSENT (never touch jsonc alone) ----
$NonJson = @(Get-ChildItem $ConfigRoot -File -Filter *.jsonc -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch "^(package|package-lock)" } |
    Select-Object -ExpandProperty FullName)
if ($NonJson.Count -gt 0) {
    if ($NonInteractive) {
        Write-Host "[.] Non-Interactive mode - non-.json files untouched: $([System.IO.Path]::GetFileName($NonJson) -join ', ')"
    }
    else {
        Write-Host "[?] Found non-.json config files: $([System.IO.Path]::GetFileName($NonJson) -join ', ')"
        try { $Answer = Read-Host "    Let me also read them? (y/N)" } catch { $Answer = "n" }
        if ($Answer -and $Answer.Trim() -match "^(y|yes)$") { $MainFiles += $NonJson } else { Write-Host "    O.K. - leaving them untouched." }
    }
}
if ($MainFiles.Count -eq 0) {
    throw "No main .json config found in '$ConfigRoot'. The framework never scans .jsonc on its own."
}

Write-Host ""
Write-Host "=============================================="
Write-Host "   Universal Agent Scaffold (agent: $Agent)"
Write-Host "=============================================="
Show-Credits

# ---- 2. scan + split the agent's own main config (read-only, merged) ----
$MergedMcp      = [ordered]@{}
$MergedPlugins  = [System.Collections.Generic.List[string]]::new()
$ProviderSeen   = [System.Collections.Generic.List[string]]::new()

foreach ($TF in $MainFiles) {
    Write-Host "[*] Scanning main config: $TF"
    $Main = [System.IO.File]::ReadAllText($TF) | ConvertFrom-Json
    # mcp section
    if ($Main.mcp) { foreach ($Prop in $Main.mcp.PSObject.Properties) { $MergedMcp[$Prop.Name] = $Prop.Value } }
    # plugin section (both common shapes)
    foreach ($Key in $PluginKeys) {
        $Split = $Key -split "\."
        $Node = $Main
        foreach ($Seg in $Split) { if ($null -ne $Node) { $Node = $Node.$Seg } }
        foreach ($P in @($Node)) { if ($P) { $MergedPlugins.Add([string]$P) } }
    }
    # provider section presence (never written - guidance only, user-owned)
    foreach ($P in @($Main.provider.PSObject.Properties)) { if ($P) { $ProviderSeen.Add($P.Name) } }
    # settings schema (use the config's own $schema when present)
    if ($SchemaUrl -eq "" -and $Main.schema)       { $SchemaUrl = [string]$Main.schema }
    if ($SchemaUrl -eq "" -and $Main.'$schema')    { $SchemaUrl = [string]$Main.'$schema' }
}
$MergedPlugins = @($MergedPlugins | Sort-Object -Unique)

function Backup-ProfileFile {
    param([string]$Path, [string]$Tag)
    if (-not (Test-Path $Path)) { return }
    $BkDir = Join-Path $ConfigRoot "backup"
    if (-not (Test-Path $BkDir)) { New-Item -ItemType Directory -Path $BkDir -Force | Out-Null }
    $Ts = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $Bk = Join-Path $BkDir "$Tag`_$Ts.json"
    Copy-Item $Path $Bk
    Write-Host "  [~] backed up previous -> backup\$([System.IO.Path]::GetFileName($Bk))"
}

function Write-ProfileJson {
    param([string]$Path, [string]$Name, [string]$Content)
    Backup-ProfileFile $Path $Name
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  [ ] $Name written"
}

# ---- create-if-missing: mcp.json / plugins.json are user-owned after creation.
#      The framework NEVER overwrites them (V3 rule 6). ----
function Seed-IfMissing {
    param([string]$Path, [string]$Name, [string]$Content)
    if (Test-Path $Path) {
        Write-Host "  [ ] $Name exists - user-owned, left untouched"
        return
    }
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  [ ] $Name created"
}

function Merge-SettingsSections {
    param([string]$Path)
    # V3 rule: settings.json is a MINIMAL settings file, shaped like the
    # reference implementation's (e.g. OpenCode: $schema + activeProviders).
    # The framework NEVER copy-pastes the whole agent config into settings.
    if (-not (Test-Path $Path)) {
        $Safe = if ($SchemaUrl) { $SchemaUrl } else { "https://schema.example.com/config.json" }
        $Obj = [ordered]@{ '$schema' = $Safe; 'activeProviders' = [string[]]$ProviderSeen }
        $Json = ConvertTo-Json $Obj -Depth 20
        [System.IO.File]::WriteAllText($Path, $Json, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "  [ ] $(Split-Path $Path -Leaf) created (schema + activeProviders)"
        return
    }
    # Existing settings.json is user-owned; only ensure the two framework
    # keys exist. Never clobber any user key, never paste the agent shape.
    $Existing = [System.IO.File]::ReadAllText($Path) | ConvertFrom-Json
    $Merged = [ordered]@{}
    foreach ($P in $Existing.PSObject.Properties) { $Merged[$P.Name] = $P.Value }
    $Added = @()
    if (-not $Merged.Contains('$schema')) { $Merged['$schema'] = $Safe; $Added += '$schema' }
    if (-not $Merged.Contains('activeProviders')) { $Merged['activeProviders'] = [string[]]$ProviderSeen; $Added += 'activeProviders' }
    if ($Added.Count -gt 0) {
        $Json = ConvertTo-Json $Merged -Depth 20
        [System.IO.File]::WriteAllText($Path, $Json, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "  [~] $(Split-Path $Path -Leaf): added missing keys: $($Added -join ', ')"
    } else {
        Write-Host "  [ ] $(Split-Path $Path -Leaf): up to date (user-owned, untouched)"
    }
}

# ---- 3. create the profile folders - ALWAYS coding / experimental / minimal ----
$Profiles = @("coding", "experimental", "minimal")
foreach ($Profile in $Profiles) {
    $Dir = Join-Path $ProfilesRoot $Profile
    if (-not (Test-Path $Dir)) { New-Item -ItemType Directory -Path $Dir -Force | Out-Null }
}

# coding (MAIN profile) = mcp + plugins seeded from the agent's own main config.
foreach ($Profile in $Profiles) {
    $Dir = Join-Path $ProfilesRoot $Profile
    if ($Profile -eq "coding") {
        # main profile: seed from the scanned main config
        if ($MergedMcp.Count -gt 0) {
            $McpJson = [ordered]@{ mcp = $MergedMcp } | ConvertTo-Json -Depth 10
            Seed-IfMissing (Join-Path $Dir "mcp.json") "mcp.json" $McpJson
        } else {
            Seed-IfMissing (Join-Path $Dir "mcp.json") "mcp.json" '{ "mcp": { } }'
        }
        if ($MergedPlugins.Count -gt 0) {
            Seed-IfMissing (Join-Path $Dir "plugins.json") "plugins.json" ('{ "plugin": ' + (ConvertTo-Json $MergedPlugins -Depth 5) + ' }')
        } else {
            Seed-IfMissing (Join-Path $Dir "plugins.json") "plugins.json" '{ "plugin": [ ] }'
        }
    }
    else {
        # experimental / minimal: create EMPTY mcp/plugins - NEVER filled by the
        # framework. The user owns the content of these files (V3 rule 6).
        Seed-IfMissing (Join-Path $Dir "mcp.json") "mcp.json" '{ "mcp": { } }'
        Seed-IfMissing (Join-Path $Dir "plugins.json") "plugins.json" '{ "plugin": [ ] }'
    }
    Merge-SettingsSections (Join-Path $Dir "settings.json")
}

# ---- 4. providers/ folder: created by the framework, files are USER-owned ----
# The framework creates the providers/ folder (like the profile folders), but
# NEVER writes provider or model JSON files inside it - the user owns those.
$ProvidersRoot = Join-Path $ConfigRoot "providers"
if (-not (Test-Path $ProvidersRoot)) { New-Item -ItemType Directory -Path $ProvidersRoot -Force | Out-Null; Write-Host "[ ] providers/ folder created (files are user-owned)" }
Write-Host ""
Write-Host "[i] Provider section detected in main config: $($ProviderSeen -join ', ')"
Write-Host "    Provider and model JSON files are 100% USER-owned. The framework"
Write-Host "    creates the providers/ folder but NEVER writes files inside it."
Write-Host "    Create them yourself when you need them:"
Write-Host "      providers/<id>.json                  (e.g. omniroute.json)"
Write-Host "      profiles/<profile>/<id>-models.json  (e.g. omniroute-models.json)"

# ---- 5. builder bootstrap (optional): adapt a source builder for this agent ----
if ($Bootstrap) {
    # Self-contained source resolution: the app bundles the engine (this
    # script + builders + kilo adapter + schemas) in its own folder, so any
    # downloaded copy can generate builders for any agent without touching
    # the developer's machine. kilo agents get the K1 adapter (writes
    # kilo.json), everything else the V2.7 opencode builder (writes
    # opencode.json via target.json).
    $Source = if ($BuilderSource) { $BuilderSource }
              elseif ($Agent -eq "kilo") { Join-Path $PSScriptRoot "kilo\build-kilo-v1.ps1" }
              else { Join-Path $PSScriptRoot "build-opencode-v2.7.ps1" }
    if (-not (Test-Path $Source)) { $Source = Join-Path $PSScriptRoot "build-opencode-v2.7.ps1" }
    if (-not (Test-Path $Source)) { $Source = Join-Path $PSScriptRoot "build-opencode.ps1" }
    if (Test-Path $Source) {
        $TargetDir = Join-Path $ConfigRoot "scripts"
        if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }
        $Built = Join-Path $TargetDir "build-$Agent.ps1"
        Write-Host "[+] Bootstrapping builder for '$Agent' from '$Source'"
        $src = Get-Content $Source -Raw
        $src = $src -replace "KiloCode Configuration Builder", "$Agent Configuration Builder"
        $src = $src -replace "kilo\.jsonc", "config.json"
        $src = $src -replace "\.config\\kilo", $ConfigRoot
        [System.IO.File]::WriteAllText($Built, $src, (New-Object System.Text.UTF8Encoding($false)))
        $SourceBase = [System.IO.Path]::GetFileNameWithoutExtension($Source).Replace("build-", "")
        $CandidateTests = @()
        foreach ($Pat in @("test-$SourceBase.ps1", "test-kilo-v1.ps1", "test-opencode-v2.7.ps1", "test-opencode-v2.ps1")) {
            $Cand = Join-Path (Split-Path $Source) $Pat
            if (Test-Path $Cand) { $CandidateTests += $Cand }
        }
        $T = Join-Path $TargetDir "test-$Agent.ps1"
        if ($CandidateTests.Count -gt 0) {
            $tSrc = Get-Content $CandidateTests[0] -Raw
            $tSrc = $tSrc -replace "KiloCode Configuration Builder", "$Agent Configuration Builder"
            $tSrc = $tSrc -replace "kilo\.jsonc", "config.json"
            $tSrc = $tSrc -replace "\.config\\kilo", $ConfigRoot
            $tSrc = $tSrc -replace "build-kilo-v1\.ps1", "build-$Agent.ps1"
            $tSrc = $tSrc -replace "build-opencode-v2\.7\.ps1", "build-$Agent.ps1"
            $tSrc = $tSrc -replace "test-kilo-v1\.ps1", "test-$Agent.ps1"
            $tSrc = $tSrc -replace "test-opencode-v2\.7\.ps1", "test-$Agent.ps1"
            [System.IO.File]::WriteAllText($T, $tSrc, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host "[+] Bootstrapped: $T"
        }
        $S = Join-Path $TargetDir "scaffold-$Agent.ps1"
        $sSrc = @"
# scaffold-$Agent.ps1 - wrapper for the universal scaffold
[CmdletBinding()]
param(
    [string]`$ConfigRoot = "$ConfigRoot",
    [switch]`$NonInteractive
)
& (Join-Path (Split-Path `$PSScriptRoot -Parent) "..\opencode\scripts\scaffold-agent.ps1") -Agent "$Agent" -ConfigRoot `$ConfigRoot -NonInteractive:`$NonInteractive
"@
        [System.IO.File]::WriteAllText($S, $sSrc, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "[+] Bootstrapped: $Built / $T / $S"
        Write-Host "    Run '$Built -Profile coding' after setting up providers."
    } else {
        Write-Host "[!] No source builder found to adapt."
    }
}

Write-Host ""
Write-Host "[+] Scaffold complete. Main profile: $Agent/coding. Providers/models are user-owned."
Write-Host "=========================================================="
