<#
.SYNOPSIS
Builds the Windows ARM64 versions of pedalboard's external test plugins.

.DESCRIPTION
The x64 test plugins in tests/plugins/*/Windows were built with each plugin's own
Projucer project, which can't target ARM64. This script instead builds the same
releases from source against pedalboard's JUCE submodule (which supports Windows
on ARM), and copies the results into each bundle's Contents/arm64-win folder:

  - CHOWTapeModel 2.7.0 (https://github.com/jatinchowdhury18/AnalogTapeModel, GPLv3)
  - Magical8bitPlug2 1.0.1 (https://github.com/yokemura/Magical8bitPlug2, MIT)

Run this on a Windows ARM64 machine with Visual Studio 2022 (or newer) and CMake,
after initializing pedalboard's submodules.
#>
param(
    [string]$BuildDir = (Join-Path $PSScriptRoot "build")
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$SourceDir = Join-Path $BuildDir "src"
$CMakeBuildDir = Join-Path $BuildDir "cmake"

function Invoke-Checked {
    & $args[0] $args[1..($args.Count - 1)]
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $($args -join ' ')"
    }
}

$ChowDir = Join-Path $SourceDir "AnalogTapeModel"
if (-not (Test-Path $ChowDir)) {
    Invoke-Checked git clone --depth 1 --branch v2.7.0 https://github.com/jatinchowdhury18/AnalogTapeModel.git $ChowDir
    Invoke-Checked git -C $ChowDir submodule update --init --depth 1 Plugin/foleys_gui_magic
}

$M8bpDir = Join-Path $SourceDir "Magical8bitPlug2"
if (-not (Test-Path $M8bpDir)) {
    Invoke-Checked git clone --depth 1 --branch v1.0.1 https://github.com/yokemura/Magical8bitPlug2.git $M8bpDir
}

Invoke-Checked cmake -S $PSScriptRoot -B $CMakeBuildDir -A ARM64 `
    "-DPEDALBOARD_JUCE_DIR=$RepoRoot\JUCE" `
    "-DCHOW_SOURCE_DIR=$ChowDir" `
    "-DM8BP_SOURCE_DIR=$M8bpDir"
Invoke-Checked cmake --build $CMakeBuildDir --config Release --target CHOWTapeModel_VST3 Magical8bitPlug2_VST3

$Plugins = @(
    @{ Name = "CHOWTapeModel"; Type = "effect" },
    @{ Name = "Magical8bitPlug2"; Type = "instrument" }
)
foreach ($Plugin in $Plugins) {
    $Name = $Plugin.Name
    # JUCE 6's CMake support always names the architecture folder x86_64-win on 64-bit Windows:
    $Built = Join-Path $CMakeBuildDir "${Name}_artefacts\Release\VST3\$Name.vst3\Contents\x86_64-win\$Name.vst3"
    $Destination = Join-Path $RepoRoot "tests\plugins\$($Plugin.Type)\Windows\$Name.vst3\Contents\arm64-win"
    New-Item -ItemType Directory -Force $Destination | Out-Null
    Copy-Item $Built (Join-Path $Destination "$Name.vst3")
    Write-Host "Updated $Destination\$Name.vst3"
}
