package com.swfgui.managers.errorcode
{
	

	/**
	 *
	 * @author llj
	 *
	 */
	public class ErrorCodeManager
	{
		private static var errorTable:Array;

		public function ErrorCodeManager()
		{
		}

		/**
		 * 如果errorCode不为0就弹出错误提示
		 * @param errorCode
		 * @return 发生错误true 没有错误false
		 */
		public static function ThrowError(errorCode:int):Boolean
		{
			if (errorCode != 0)
			{
//				var err:ErrorCode = GlobalFactory.instance.getErrorCodeById(errorCode);
//				if(err)
//				Alert.instance.show(err.content);
//				else
//					Alert.instance.show("发生错误");
//		
			}

			return errorCode != 0;
		}
	}
}