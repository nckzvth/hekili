param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$repoRoot = Split-Path -Parent $PSScriptRoot
$libsRoot = Join-Path $repoRoot "Libs"
$tmpRoot = Join-Path $repoRoot ".tmp_lib_bootstrap"

New-Item -ItemType Directory -Force -Path $libsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

function Clone-Shallow {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Path
    )

    if (Test-Path $Path) {
        Remove-Item -Recurse -Force $Path
    }

    git clone --depth 1 $Url $Path | Out-Null
}

function Copy-Tree {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path $Source)) {
        throw "Missing source path: $Source"
    }

    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -Recurse -Force $Source $Destination
}

Write-Host "Bootstrapping addon libraries into $libsRoot ..."

# Ace3 bundle (includes LibStub + CallbackHandler).
$ace3Tmp = Join-Path $tmpRoot "Ace3"
Clone-Shallow -Url "https://github.com/WoWUIDev/Ace3.git" -Path $ace3Tmp

$ace3Dirs = @(
    "LibStub",
    "CallbackHandler-1.0",
    "AceAddon-3.0",
    "AceBucket-3.0",
    "AceComm-3.0",
    "AceConfig-3.0",
    "AceConsole-3.0",
    "AceDB-3.0",
    "AceDBOptions-3.0",
    "AceEvent-3.0",
    "AceGUI-3.0",
    "AceHook-3.0",
    "AceLocale-3.0",
    "AceSerializer-3.0",
    "AceTab-3.0",
    "AceTimer-3.0"
)

foreach ($dir in $ace3Dirs) {
    Copy-Tree -Source (Join-Path $ace3Tmp $dir) -Destination (Join-Path $libsRoot $dir)
}

$repos = @(
    @{ Name = "LibSharedMedia-3.0"; Url = "https://github.com/wowace-clone/LibSharedMedia-3.0.git"; Src = "." },
    @{ Name = "AceGUI-3.0-SharedMediaWidgets"; Url = "https://github.com/wowace-clone/AceGUI-3.0-SharedMediaWidgets.git"; Src = "." },
    @{ Name = "AceGUI-3.0_SFX-Widgets"; Url = "https://github.com/SFX-WoW/AceGUI-3.0_SFX-Widgets.git"; Src = "." },
    @{ Name = "LibSpellRange-1.0"; Url = "https://github.com/ascott18/LibSpellRange-1.0.git"; Src = "." },
    @{ Name = "LibRangeCheck-2.0"; Url = "https://github.com/WeakAuras/LibRangeCheck-2.0.git"; Src = "LibRangeCheck-2.0" },
    @{ Name = "LibDeflate"; Url = "https://github.com/SafeteeWoW/LibDeflate.git"; Src = "." },
    @{ Name = "LibDualSpec-1.0"; Url = "https://github.com/wowace-clone/LibDualSpec-1.0.git"; Src = "." },
    @{ Name = "LibItemBuffs-1.0"; Url = "https://github.com/AdiAddons/LibItemBuffs-1.0.git"; Src = "." },
    @{ Name = "LibCustomGlow-1.0"; Url = "https://github.com/Stanzilla/LibCustomGlow.git"; Src = "." },
    @{ Name = "LibChatAnims"; Url = "https://github.com/wowace-clone/LibChatAnims.git"; Src = "LibChatAnims" },
    @{ Name = "LibTranslit-1.0"; Url = "https://github.com/Vardex/LibTranslit.git"; Src = "." },
    @{ Name = "SpellFlashCore"; Url = "https://github.com/Tga123/SpellFlashCore.git"; Src = "." }
)

foreach ($r in $repos) {
    $tmp = Join-Path $tmpRoot $r.Name
    Clone-Shallow -Url $r.Url -Path $tmp
    $src = if ($r.Src -eq ".") { $tmp } else { Join-Path $tmp $r.Src }
    Copy-Tree -Source $src -Destination (Join-Path $libsRoot $r.Name)
}

# LibCompress mirror for legacy import compatibility.
$lcTmp = Join-Path $tmpRoot "LibCompress"
Clone-Shallow -Url "https://github.com/OpenPrograms/LibCompress.git" -Path $lcTmp
$lcDst = Join-Path $libsRoot "LibCompress"
New-Item -ItemType Directory -Force -Path $lcDst | Out-Null
Copy-Item -Force (Join-Path $lcTmp "LibCompress.lua") (Join-Path $lcDst "LibCompress.lua")

# Validate all embed references.
$embedFile = Join-Path $repoRoot "embeds.xml"
$missing = @()
Get-Content $embedFile | ForEach-Object {
    if ($_ -match 'file="([^"]+)"') {
        $path = Join-Path $repoRoot $Matches[1]
        if (-not (Test-Path $path)) { $missing += $Matches[1] }
    }
}

if ($missing.Count -gt 0) {
    Write-Warning "Library bootstrap completed with missing embed paths:"
    $missing | ForEach-Object { Write-Warning " - $_" }
    exit 1
}

Write-Host "Library bootstrap complete."

if (Test-Path $tmpRoot) {
    Remove-Item -Recurse -Force $tmpRoot
}
