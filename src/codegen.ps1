#Requires -Version 7.5
# Windows: run from a VS command prompt; macOS: needs Xcode (or the command line tools)

$ROOT = "$(Resolve-Path "../thirdparty/yoga/")".TrimEnd("\", "/")
$DST = "./YG/bindings"

$gen = @(
  "-I", $ROOT
  "--file"
  "$ROOT/yoga/YGConfig.h"
  "$ROOT/yoga/YGEnums.h"
  "$ROOT/yoga/YGMacros.h"
  "$ROOT/yoga/YGNode.h"
  "$ROOT/yoga/YGNodeLayout.h"
  "$ROOT/yoga/YGNodeStyle.h"
  "$ROOT/yoga/YGPixelGrid.h"
  "$ROOT/yoga/YGValue.h"

  "--config"
  "latest-codegen"
  "multi-file"
  "exclude-enum-operators"
  "exclude-using-statics-for-enums"
  "generate-file-scoped-namespaces"
  "generate-helper-types"
  # this is not working correctly
  # "strip-enum-member-type-name"

  "--libraryPath", "yoga"
  "--namespace", "Yoga"
  "--methodClassName", "YG"
  "--prefixStrip", "YG"

  "--output", "$DST"
  # "--with-access-specifier", "*=Internal"
)

if ($IsMacOS) {
  # libclang bundled with ClangSharp has no system headers; borrow Xcode's
  $sdk = xcrun --show-sdk-path
  $resourceDir = clang -print-resource-dir
  $gen += @(
    "--additional"
    "-isysroot", $sdk
    "-isystem", "$sdk/usr/include/c++/v1"
    "-isystem", "$resourceDir/include"
  )
}

ClangSharpPInvokeGenerator $gen

New-Item -Type Directory $DST -ErrorAction SilentlyContinue
$YG_CS = Join-Path $DST "YG.cs"
(Get-Content -Raw $YG_CS).Replace("public const float YGUndefined = NaN;","public const float YGUndefined = float.NaN;") | Out-File $YG_CS -NoNewline

# newer ClangSharp marks the whole assembly as generated code (incl. the handwritten wrappers)
Remove-Item (Join-Path $DST "GeneratedCode.cs") -ErrorAction SilentlyContinue

# the underlying type of plain C enums is compiler-defined: MSVC uses int, clang on macOS/Linux
# uses unsigned int when there are no negative values; keep the public API stable as int
foreach ($file in Get-ChildItem $DST -Filter "*.cs") {
  $text = Get-Content -Raw $file
  $fixed = $text -replace '\[NativeTypeName\("unsigned int"\)\]\r?\n(public enum \w+) : uint', '$1'
  if ($fixed -ne $text) { $fixed | Out-File $file -NoNewline }
}
