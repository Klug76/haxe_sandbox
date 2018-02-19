//package;

import php.Lib;
import php.TypedArray;
import php.VarNatives;

class Main
{

	static function main()
	{
		var arr = TypedArray.fromMap([ 'a'=>'1', 'b'=>'2', 'c'=>'3' ]);
		//for (&a in arr)
		//{}; // do nothing. maybe?
		//unset($a);
		for (a in arr)
		{};  // do nothing. maybe?
		VarNatives.print_r(arr);
		Lib.println('Hello, Мир!');
	}

}