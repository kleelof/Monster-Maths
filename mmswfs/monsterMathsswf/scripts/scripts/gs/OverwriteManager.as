package gs
{
   import flash.errors.*;
   import flash.utils.*;
   
   public class OverwriteManager
   {
      
      public static var mode:int;
      
      public static var enabled:Boolean;
      
      public static const version:Number = 0.96;
      
      public static const NONE:int = 0;
      
      public static const ALL:int = 1;
      
      public static const AUTO:int = 2;
      
      public static const CONCURRENT:int = 3;
      
      public function OverwriteManager()
      {
         super();
      }
      
      public static function killVars(param1:Object, param2:Object, param3:Array, param4:Array, param5:Array) : void
      {
         var _loc6_:* = 0;
         var _loc7_:String = null;
         _loc6_ = int(param4.length - 1);
         while(_loc6_ > -1)
         {
            if(param1[param4[_loc6_].name] != undefined)
            {
               param4.splice(_loc6_,1);
            }
            _loc6_--;
         }
         _loc6_ = int(param3.length - 1);
         while(_loc6_ > -1)
         {
            if(param1[param3[_loc6_].name] != undefined)
            {
               param3.splice(_loc6_,1);
            }
            _loc6_--;
         }
         _loc6_ = int(param5.length - 1);
         while(_loc6_ > -1)
         {
            if(param1[param5[_loc6_].name] != undefined)
            {
               param5.splice(_loc6_,1);
            }
            _loc6_--;
         }
         for(_loc7_ in param1)
         {
            delete param2[_loc7_];
         }
      }
      
      public static function manageOverwrites(param1:TweenLite, param2:Dictionary) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:* = 0;
         var _loc9_:Object = null;
         var _loc10_:String = null;
         _loc3_ = param1.vars;
         _loc4_ = _loc3_.overwrite == undefined ? mode : int(_loc3_.overwrite);
         if(_loc4_ < 2)
         {
            return;
         }
         _loc6_ = param1.startTime;
         _loc7_ = [];
         for each(_loc5_ in param2)
         {
            if(_loc5_ != param1 && _loc5_.startTime <= _loc6_)
            {
               _loc7_[_loc7_.length] = _loc5_;
            }
         }
         if(_loc7_.length == 0)
         {
            return;
         }
         if(_loc4_ == AUTO)
         {
            if(_loc3_.isTV == true)
            {
               _loc3_ = _loc3_.exposedProps;
            }
            _loc9_ = {};
            for(_loc10_ in _loc3_)
            {
               if(!(_loc10_ == "ease" || _loc10_ == "delay" || _loc10_ == "overwrite" || _loc10_ == "onComplete" || _loc10_ == "onCompleteParams" || _loc10_ == "runBackwards" || _loc10_ == "persist" || _loc10_ == "onUpdate" || _loc10_ == "onUpdateParams" || _loc10_ == "timeScale" || _loc10_ == "onStart" || _loc10_ == "onStartParams" || _loc10_ == "renderOnStart" || _loc10_ == "proxiedEase" || _loc10_ == "easeParams" || _loc10_ == "onCompleteAll" || _loc10_ == "onCompleteAllParams" || _loc10_ == "yoyo" || _loc10_ == "loop"))
               {
                  _loc9_[_loc10_] = 1;
               }
            }
            _loc8_ = int(_loc7_.length - 1);
            while(_loc8_ > -1)
            {
               _loc7_[_loc8_].killVars(_loc9_);
               _loc8_--;
            }
         }
         else
         {
            _loc8_ = int(_loc7_.length - 1);
            while(_loc8_ > -1)
            {
               param2[_loc7_[_loc8_]] = null;
               delete param2[_loc7_[_loc8_]];
               _loc8_--;
            }
         }
      }
      
      public static function init(param1:int = 2) : int
      {
         if(TweenLite.version < 8.14)
         {
            trace("TweenLite warning: Your TweenLite class needs to be updated to work with OverwriteManager (or you may need to clear your ASO files). Please download and install the latest version from http://www.tweenlite.com.");
         }
         TweenLite.overwriteManager = OverwriteManager;
         mode = param1;
         enabled = true;
         return mode;
      }
   }
}

