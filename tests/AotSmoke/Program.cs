using Yoga;

unsafe
{
	var root = YG.NodeNew();
	YG.NodeStyleSetFlexDirection(root, YGFlexDirection.YGFlexDirectionRow);
	YG.NodeStyleSetWidth(root, 300);

	var a = YG.NodeNew();
	YG.NodeStyleSetFlexGrow(a, 1);
	var b = YG.NodeNew();
	YG.NodeStyleSetFlexGrow(b, 2);

	YG.NodeInsertChild(root, a, 0);
	YG.NodeInsertChild(root, b, 1);
	YG.NodeCalculateLayout(root, float.NaN, float.NaN, YGDirection.YGDirectionLTR);

	var wa = YG.NodeLayoutGetWidth(a);
	var wb = YG.NodeLayoutGetWidth(b);
	YG.NodeFreeRecursive(root);

	System.Console.WriteLine($"a={wa} b={wb}");

	return wa == 100 && wb == 200 ? 0 : 1;
}
