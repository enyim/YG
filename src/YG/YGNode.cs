namespace Yoga;

public readonly struct YGNodeRef : IDisposable
{
	private readonly nint ptr;

	internal YGNodeRef(nint ptr) => this.ptr = ptr;
	internal unsafe YGNodeRef(YGNode* ptr) => this.ptr = (nint)ptr;

	public bool IsNull => ptr == 0;

	public unsafe void Dispose() => YG.NodeFree(this);

	public static implicit operator nint(YGNodeRef n) => n.ptr;
	public static implicit operator YGNodeRef(nint p) => new(p);

	public static unsafe implicit operator YGNode*(YGNodeRef n) => (YGNode*)n.ptr;
	public static unsafe implicit operator YGNodeRef(YGNode* p) => new(p);
}
