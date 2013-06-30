package com.swfgui.utils
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ClassUtil
	{
		public static function clone( value:* ):*
		{
			var s : String = getQualifiedClassName( value ).replace("::",".");
			registerClassAlias( s , Class( getDefinitionByName( s ) ) );
			var ba : ByteArray = new ByteArray();
			ba.writeObject( value );
			ba.position = 0;
			var r : * = ba.readObject();
			return r;
		}
	}
}