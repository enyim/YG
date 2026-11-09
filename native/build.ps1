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
    $staticLib = "yoga_static.lib"
    $cmakeArch = if ($Arch -eq "arm64") { "ARM64" } else { "x64" }
    $extraArgs = @("-G", "Visual Studio 18 2026", "-A", $cmakeArch)
}
elseif ($IsMacOS) {
    $platform = "osx-$Arch"
    $binary = "libyoga.dylib"
    $staticLib = "libyoga_static.a"
    $cmakeArch = if ($Arch -eq "arm64") { "arm64" } else { "x86_64" }
    $extraArgs = @("-DCMAKE_OSX_ARCHITECTURES=$cmakeArch", "-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0")
}
elseif ($IsLinux) {
    $platform = "linux-$Arch"
    $binary = "libyoga.so"
    $staticLib = "libyoga_static.a"
    $extraArgs = @()
}
else {
    Write-Error "Unsupported platform"
    exit 1
}

# configure
$buildDir = "$me/build/$platform"
cmake -S $me -B $buildDir -DCMAKE_BUILD_TYPE=$Configuration @extraArgs
if (-not $?) { Write-Error "CMake configure failed"; exit 1 }

# build
cmake --build $buildDir --config $Configuration
if (-not $?) { Write-Error "CMake build failed"; exit 1 }

# deploy
function Deploy([string]$file, [string]$dest) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    $output = Get-ChildItem "$buildDir/out/$file" -ErrorAction SilentlyContinue
    if (-not $output) { Write-Error "Could not find built binary: $file"; exit 1 }
    Copy-Item $output $dest
}

# dynamic library -> runtimes/ (JIT)
Deploy $binary "$me/../src/YG/runtimes/$platform/native/"
# static library -> staticlibs/ (Native AOT)
Deploy $staticLib "$me/../src/YG/staticlibs/$platform/"
