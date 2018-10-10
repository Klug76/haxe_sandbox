package gs.femto_ui.kha;
import gs.femto_ui.Visel;

class BubbleChain
{
	public var chain_: Array<Visel> = [];
	public var count_: Int = 0;//:avoid chain_::realloc

	private static var pool_: Array<BubbleChain> = [];

	private function new()
	{}

//.............................................................................
	public static function alloc(): BubbleChain
	{
        if (pool_.length > 0)
			return pool_.pop();
		return new BubbleChain();
	}
//.............................................................................
	public static function dispose(bc: BubbleChain): Void
	{
		pool_.push(bc);
	}
//.............................................................................
	public function build(t: Visel) : Void
	{
		count_ = 0;
		while (t != null)
		{
			chain_[count_++] = t;
			t = t.parent;
		}
	}

}