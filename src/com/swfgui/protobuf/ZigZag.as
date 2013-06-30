﻿package com.swfgui.protobuf
{

    final public class ZigZag extends Object
    {

        public function ZigZag()
        {
            return;
        }// end function

        public static function encode64low(low:uint, high:int) : uint
        {
            return low << 1 ^ high >> 31;
        }// end function

        public static function encode32(n:int) : int
        {
            return n << 1 ^ n >> 31;
        }// end function

        public static function encode64high(low:uint, high:int) : int
        {
            return low >>> 31 ^ high << 1 ^ high >> 31;
        }// end function

        public static function decode64low(low:uint, high:int) : uint
        {
            return high << 31 ^ low >>> 1 ^ -(low & 1);
        }// end function

        public static function decode32(n:int) : int
        {
            return n >>> 1 ^ -(n & 1);
        }// end function

        public static function decode64high(low:uint, high:int) : int
        {
            return high >>> 1 ^ -(low & 1);
        }// end function

    }
}
