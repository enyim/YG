param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [ValidateSet("x64", "arm64")]
    [string]$Arch = "x64"
)

$ErrorActionPreference = "Stop"

# resolve paths
$me = $PSScriptRoot

# detect platform + set output path and cmake args
if ($IsWindows) {
    $platform = "win-$Arch"
    $binary = "yoga.dll"
    $cmakeArch = if ($Arch -eq "arm64") { "ARM64" } else { "x64" }
    $extraArgs = @("-A", $cmakeArch)
}
elseif ($IsMacOS) {
    $platform = "osx-$Arch"
    $binary = "libyoga.dylib"
    $cmakeArch = if ($Arch -eq "arm64") { "arm64" } else { "x86_64" }
    $extraArgs = @("-DCMAKE_OSX_ARCHITECTURES=$cmakeArch")
}
elseif ($IsLinux) {
    $platform = "linux-$Arch"
    $binary = "libyoga.so"
    $extraArgs = @()
}
else {
    Write-Error "Unsupported platform"
    exit 1
}

# configure
$buildDir = "$me/build"
cmake -S $me -B $buildDir @extraArgs
if (-not $?) { Write-Error "CMake configure failed"; exit 1 }

# build
cmake --build $buildDir --config $Configuration
if (-not $?) { Write-Error "CMake build failed"; exit 1 }

# deploy
$runtimes = "$me/../src/YG/runtimes/$platform/native/"

New-Item -ItemType Directory -Force -Path $runtimes | Out-Null
$output = Get-ChildItem "$buildDir/out/$binary"
if (-not $output) { Write-Error "Could not find built binary: $binary"; exit 1 }

Copy-Item $output "$runtimes"
