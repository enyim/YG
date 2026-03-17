#Requires -Version 7.5
# also requires VS command prompt

$ROOT = "$(Resolve-Path "../thirdparty/yoga/")".TrimEnd("\")
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

ClangSharpPInvokeGenerator $gen

New-Item -Type Directory $DST -ErrorAction SilentlyContinue
$YG_CS = "$DST\YG.cs"
(Get-Content -Raw $YG_CS).Replace("public const float YGUndefined = NaN;","public const float YGUndefined = float.NaN;") | Out-File $YG_CS -NoNewline
