namespace Yoga;

public enum YGErrata
{
    YGErrataNone = 0,
    YGErrataStretchFlexBasis = 1,
    YGErrataAbsolutePositionWithoutInsetsExcludesPadding = 2,
    YGErrataAbsolutePercentAgainstInnerSize = 4,
    YGErrataMinSizeUndefinedInsteadOfAuto = 8,
    YGErrataAll = 2147483647,
    YGErrataClassic = 2147483646,
}
