package gs
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.*;
   import gs.events.TweenEvent;
   
   public class TweenMax extends TweenFilterLite implements IEventDispatcher
   {
      
      public static var version:Number = 3;
      
      protected static const _RAD2DEG:Number = 180 / Math.PI;
      
      private static var _overwriteMode:int = OverwriteManager.enabled ? OverwriteManager.mode : OverwriteManager.init();
      
      public static var killTweensOf:Function = TweenLite.killTweensOf;
      
      public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
      
      public static var removeTween:Function = TweenLite.removeTween;
      
      public static var setGlobalTimeScale:Function = TweenFilterLite.setGlobalTimeScale;
      
      protected var _dispatcher:EventDispatcher;
      
      protected var _callbacks:Object;
      
      protected var _pauseTime:int;
      
      public function TweenMax(param1:Object, param2:Number, param3:Object)
      {
         super(param1,param2,param3);
         _pauseTime = -1;
         if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null)
         {
            initDispatcher();
            if(param2 == 0 && this.delay == 0)
            {
               onUpdateDispatcher();
               onCompleteDispatcher();
            }
         }
         if(this.vars.yoyo == true || this.vars.loop == true)
         {
            this.vars.persist = true;
         }
         if(TweenFilterLite.version < 9)
         {
            trace("TweenMax error! Please update your TweenFilterLite class or try deleting your ASO files. TweenMax requires a more recent version. Download updates at http://www.TweenMax.com.");
         }
      }
      
      public static function sequence(param1:Object, param2:Array) : Array
      {
         trace("WARNING: TweenMax.sequence() has been deprecated in favor of the much more powerful and flexible TweenGroup class. See http://blog.greensock.com/tweengroup/ for more details.");
         return [];
      }
      
      public static function bezierProxy(param1:Object) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc9_:uint = 0;
         _loc2_ = Number(param1.target.t);
         _loc3_ = param1.info.props;
         _loc4_ = param1.info.target;
         if(_loc2_ == 1)
         {
            for(_loc6_ in _loc3_)
            {
               _loc5_ = _loc3_[_loc6_].length - 1;
               _loc4_[_loc6_] = _loc3_[_loc6_][_loc5_].e;
            }
         }
         else
         {
            for(_loc6_ in _loc3_)
            {
               _loc9_ = uint(_loc3_[_loc6_].length);
               if(_loc2_ < 0)
               {
                  _loc5_ = 0;
               }
               else if(_loc2_ >= 1)
               {
                  _loc5_ = _loc9_ - 1;
               }
               else
               {
                  _loc5_ = int(_loc9_ * _loc2_);
               }
               _loc8_ = (_loc2_ - _loc5_ * (1 / _loc9_)) * _loc9_;
               _loc7_ = _loc3_[_loc6_][_loc5_];
               _loc4_[_loc6_] = _loc7_.s + _loc8_ * (2 * (1 - _loc8_) * (_loc7_.cp - _loc7_.s) + _loc8_ * (_loc7_.e - _loc7_.s));
            }
         }
      }
      
      public static function hexColorsProxy(param1:Object) : void
      {
         param1.info.target[param1.info.prop] = uint(param1.target.r << 16 | param1.target.g << 8 | param1.target.b);
      }
      
      public static function parseBeziers(param1:Object, param2:Boolean = false) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         _loc7_ = {};
         if(param2)
         {
            for(_loc6_ in param1)
            {
               _loc4_ = param1[_loc6_];
               _loc7_[_loc6_] = _loc5_ = [];
               if(_loc4_.length > 2)
               {
                  _loc5_[_loc5_.length] = {
                     "s":_loc4_[0],
                     "cp":_loc4_[1] - (_loc4_[2] - _loc4_[0]) / 4,
                     "e":_loc4_[1]
                  };
                  _loc3_ = 1;
                  while(_loc3_ < _loc4_.length - 1)
                  {
                     _loc5_[_loc5_.length] = {
                        "s":_loc4_[_loc3_],
                        "cp":_loc4_[_loc3_] + (_loc4_[_loc3_] - _loc5_[_loc3_ - 1].cp),
                        "e":_loc4_[_loc3_ + 1]
                     };
                     _loc3_++;
                  }
               }
               else
               {
                  _loc5_[_loc5_.length] = {
                     "s":_loc4_[0],
                     "cp":(_loc4_[0] + _loc4_[1]) / 2,
                     "e":_loc4_[1]
                  };
               }
            }
         }
         else
         {
            for(_loc6_ in param1)
            {
               _loc4_ = param1[_loc6_];
               _loc7_[_loc6_] = _loc5_ = [];
               if(_loc4_.length > 3)
               {
                  _loc5_[_loc5_.length] = {
                     "s":_loc4_[0],
                     "cp":_loc4_[1],
                     "e":(_loc4_[1] + _loc4_[2]) / 2
                  };
                  _loc3_ = 2;
                  while(_loc3_ < _loc4_.length - 2)
                  {
                     _loc5_.push({
                        "s":_loc5_[_loc3_ - 2].e,
                        "cp":_loc4_[_loc3_],
                        "e":(_loc4_[_loc3_] + _loc4_[_loc3_ + 1]) / 2
                     });
                     _loc3_++;
                  }
                  _loc5_[_loc5_.length] = {
                     "s":_loc5_[_loc5_.length - 1].e,
                     "cp":_loc4_[_loc4_.length - 2],
                     "e":_loc4_[_loc4_.length - 1]
                  };
               }
               else if(_loc4_.length == 3)
               {
                  _loc5_[_loc5_.length] = {
                     "s":_loc4_[0],
                     "cp":_loc4_[1],
                     "e":_loc4_[2]
                  };
               }
               else if(_loc4_.length == 2)
               {
                  _loc5_[_loc5_.length] = {
                     "s":_loc4_[0],
                     "cp":(_loc4_[0] + _loc4_[1]) / 2,
                     "e":_loc4_[1]
                  };
               }
            }
         }
         return _loc7_;
      }
      
      public static function bezierProxy2(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:Number = NaN;
         var _loc10_:uint = 0;
         bezierProxy(param1);
         _loc2_ = {};
         _loc3_ = param1.info.target;
         param1.info.target = _loc2_;
         param1.target.t += 0.01;
         bezierProxy(param1);
         _loc4_ = param1.info.orientToBezier;
         _loc10_ = 0;
         while(_loc10_ < _loc4_.length)
         {
            _loc8_ = _loc4_[_loc10_];
            _loc9_ = Number(Number(_loc8_[3]) || 0);
            _loc6_ = _loc2_[_loc8_[0]] - _loc3_[_loc8_[0]];
            _loc7_ = _loc2_[_loc8_[1]] - _loc3_[_loc8_[1]];
            _loc3_[_loc8_[2]] = Math.atan2(_loc7_,_loc6_) * _RAD2DEG + _loc9_;
            _loc10_++;
         }
         param1.info.target = _loc3_;
         param1.target.t -= 0.01;
      }
      
      public static function pauseAll(param1:Boolean = true, param2:Boolean = false) : void
      {
         changePause(true,param1,param2);
      }
      
      public static function set globalTimeScale(param1:Number) : void
      {
         setGlobalTimeScale(param1);
      }
      
      public static function get globalTimeScale() : Number
      {
         return _globalTimeScale;
      }
      
      public static function getTweensOf(param1:Object) : Array
      {
         var _loc2_:Dictionary = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         _loc2_ = masterList[param1];
         _loc3_ = [];
         if(_loc2_ != null)
         {
            for(_loc4_ in _loc2_)
            {
               if(_loc2_[_loc4_].tweens != undefined)
               {
                  _loc3_[_loc3_.length] = _loc2_[_loc4_];
               }
            }
         }
         return _loc3_;
      }
      
      public static function killAllDelayedCalls(param1:Boolean = false) : void
      {
         killAll(param1,false,true);
      }
      
      public static function multiSequence(param1:Array) : Array
      {
         trace("WARNING: TweenMax.multiSequence() has been deprecated in favor of the much more powerful and flexible TweenGroup class. See http://blog.greensock.com/tweengroup/ for more details.");
         return [];
      }
      
      public static function delayedCall(param1:Number, param2:Function, param3:Array = null, param4:Boolean = false) : TweenMax
      {
         return new TweenMax(param2,0,{
            "delay":param1,
            "onComplete":param2,
            "onCompleteParams":param3,
            "persist":param4,
            "overwrite":0
         });
      }
      
      public static function isTweening(param1:Object) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:* = 0;
         _loc2_ = getTweensOf(param1);
         _loc3_ = int(_loc2_.length - 1);
         while(_loc3_ > -1)
         {
            if(_loc2_[_loc3_].active)
            {
               return true;
            }
            _loc3_--;
         }
         return false;
      }
      
      public static function killAll(param1:Boolean = false, param2:Boolean = true, param3:Boolean = true) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Boolean = false;
         var _loc6_:* = 0;
         _loc4_ = getAllTweens();
         _loc6_ = int(_loc4_.length - 1);
         while(_loc6_ > -1)
         {
            _loc5_ = _loc4_[_loc6_].target == _loc4_[_loc6_].vars.onComplete;
            if(_loc5_ == param3 || _loc5_ != param2)
            {
               if(param1)
               {
                  _loc4_[_loc6_].complete(false);
                  _loc4_[_loc6_].clear();
               }
               else
               {
                  TweenLite.removeTween(_loc4_[_loc6_],true);
               }
            }
            _loc6_--;
         }
      }
      
      public static function changePause(param1:Boolean, param2:Boolean = true, param3:Boolean = false) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Boolean = false;
         var _loc6_:* = 0;
         _loc4_ = getAllTweens();
         _loc6_ = int(_loc4_.length - 1);
         while(_loc6_ > -1)
         {
            _loc5_ = _loc4_[_loc6_].target == _loc4_[_loc6_].vars.onComplete;
            if(_loc4_[_loc6_] is TweenMax && (_loc5_ == param3 || _loc5_ != param2))
            {
               _loc4_[_loc6_].paused = param1;
            }
            _loc6_--;
         }
      }
      
      public static function callbackProxy(param1:Array, param2:Array = null) : void
      {
         var _loc3_:uint = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] != undefined)
            {
               param1[_loc3_].apply(null,param2[_loc3_]);
            }
            _loc3_++;
         }
      }
      
      public static function allFrom(param1:Array, param2:Number, param3:Object) : Array
      {
         param3.runBackwards = true;
         return allTo(param1,param2,param3);
      }
      
      public static function from(param1:Object, param2:Number, param3:Object) : TweenMax
      {
         param3.runBackwards = true;
         return new TweenMax(param1,param2,param3);
      }
      
      public static function killAllTweens(param1:Boolean = false) : void
      {
         killAll(param1,true,false);
      }
      
      public static function getAllTweens() : Array
      {
         var _loc1_:Dictionary = null;
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         _loc1_ = masterList;
         _loc2_ = [];
         for each(_loc3_ in _loc1_)
         {
            for(_loc4_ in _loc3_)
            {
               if(_loc3_[_loc4_] != undefined)
               {
                  _loc2_[_loc2_.length] = _loc3_[_loc4_];
               }
            }
         }
         return _loc2_;
      }
      
      public static function resumeAll(param1:Boolean = true, param2:Boolean = false) : void
      {
         changePause(false,param1,param2);
      }
      
      public static function to(param1:Object, param2:Number, param3:Object) : TweenMax
      {
         return new TweenMax(param1,param2,param3);
      }
      
      public static function allTo(param1:Array, param2:Number, param3:Object) : Array
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Object = null;
         var _loc9_:Array = null;
         var _loc10_:Number = NaN;
         if(param1.length == 0)
         {
            return [];
         }
         _loc9_ = [];
         _loc10_ = Number(Number(param3.delayIncrement) || 0);
         delete param3.delayIncrement;
         if(param3.onCompleteAll == undefined)
         {
            _loc8_ = param3;
         }
         else
         {
            _loc8_ = {};
            for(_loc6_ in param3)
            {
               _loc8_[_loc6_] = param3[_loc6_];
            }
            _loc8_.onCompleteParams = [[param3.onComplete,param3.onCompleteAll],[param3.onCompleteParams,param3.onCompleteAllParams]];
            _loc8_.onComplete = TweenMax.callbackProxy;
            delete param3.onCompleteAll;
         }
         delete param3.onCompleteAllParams;
         if(_loc10_ == 0)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length - 1)
            {
               _loc5_ = {};
               for(_loc6_ in param3)
               {
                  _loc5_[_loc6_] = param3[_loc6_];
               }
               _loc9_[_loc9_.length] = new TweenMax(param1[_loc4_],param2,_loc5_);
               _loc4_++;
            }
         }
         else
         {
            _loc7_ = Number(Number(param3.delay) || 0);
            _loc4_ = 0;
            while(_loc4_ < param1.length - 1)
            {
               _loc5_ = {};
               for(_loc6_ in param3)
               {
                  _loc5_[_loc6_] = param3[_loc6_];
               }
               _loc5_.delay = _loc7_ + _loc4_ * _loc10_;
               _loc9_[_loc9_.length] = new TweenMax(param1[_loc4_],param2,_loc5_);
               _loc4_++;
            }
            _loc8_.delay = _loc7_ + (param1.length - 1) * _loc10_;
         }
         _loc9_[_loc9_.length] = new TweenMax(param1[param1.length - 1],param2,_loc8_);
         if(param3.onCompleteAllListener is Function)
         {
            _loc9_[_loc9_.length - 1].addEventListener(TweenEvent.COMPLETE,param3.onCompleteAllListener);
         }
         return _loc9_;
      }
      
      public function set reversed(param1:Boolean) : void
      {
         if(this.reversed != param1)
         {
            reverse();
         }
      }
      
      protected function onCompleteDispatcher(... rest) : void
      {
         if(_callbacks.onComplete != null)
         {
            _callbacks.onComplete.apply(null,this.vars.onCompleteParams);
         }
         _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
      }
      
      override public function get active() : Boolean
      {
         if(this.forceActive)
         {
            return true;
         }
         if(_pauseTime != -1)
         {
            return false;
         }
         if(currentTime >= this.startTime)
         {
            this.forceActive = true;
            if(!this.initted)
            {
               initTweenVals();
            }
            else if(this.vars.visible != undefined && _isDisplayObject)
            {
               this.target.visible = true;
            }
            if(this.vars.onStart != null)
            {
               this.vars.onStart.apply(null,this.vars.onStartParams);
            }
            if(this.duration == 0.001)
            {
               --this.startTime;
            }
            return true;
         }
         return false;
      }
      
      protected function adjustStartValues() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         var _loc5_:* = 0;
         _loc1_ = this.progress;
         if(_loc1_ != 0)
         {
            _loc2_ = 1 / (1 - this.ease(_loc1_ * this.duration,0,1,this.duration));
            _loc5_ = int(this.tweens.length - 1);
            while(_loc5_ > -1)
            {
               _loc4_ = this.tweens[_loc5_];
               _loc3_ = _loc4_.s + _loc4_.c;
               _loc4_.c = (_loc3_ - _loc4_.o[_loc4_.p]) * _loc2_;
               _loc4_.s = _loc3_ - _loc4_.c;
               _loc5_--;
            }
         }
      }
      
      public function resume() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Boolean = false;
         if(_pauseTime != -1)
         {
            _loc1_ = this.delay * (1000 / _combinedTimeScale);
            _loc2_ = _pauseTime > this.initTime + _loc1_;
            this.initTime += currentTime - _pauseTime;
            this.startTime = this.initTime + _loc1_;
            _pauseTime = -1;
            if(!_loc2_ && currentTime >= this.startTime)
            {
               _loc2_ = this.active;
            }
            else
            {
               this.forceActive = _loc2_;
            }
         }
         enable();
      }
      
      public function get paused() : Boolean
      {
         return _pauseTime != -1;
      }
      
      public function restart(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.initTime = currentTime;
            this.startTime = currentTime + this.delay * (1000 / _combinedTimeScale);
         }
         else
         {
            this.startTime = currentTime;
            this.initTime = currentTime - this.delay * (1000 / _combinedTimeScale);
         }
         if(this.target != this.vars.onComplete)
         {
            render(this.startTime);
         }
         _pauseTime = -1;
         enable();
      }
      
      public function get progress() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         _loc1_ = _pauseTime != -1 ? _pauseTime : currentTime;
         _loc2_ = ((_loc1_ - this.initTime) / 1000 - this.delay / _combinedTimeScale) / this.duration * _combinedTimeScale;
         if(_loc2_ > 1)
         {
            return 1;
         }
         if(_loc2_ < 0)
         {
            return 0;
         }
         return _loc2_;
      }
      
      override public function complete(param1:Boolean = false) : void
      {
         if(this.vars.yoyo == true || this.vars.loop == true)
         {
            if(this.vars.yoyo == true)
            {
               reverse(false);
            }
            this.startTime = currentTime;
            this.initTime = this.startTime - this.delay * (1000 / _combinedTimeScale);
         }
         else if(this.vars.persist == true)
         {
            pause();
         }
         super.complete(param1);
      }
      
      public function invalidate(param1:Boolean = true) : void
      {
         var _loc2_:Number = NaN;
         if(this.initted)
         {
            _loc2_ = this.progress;
            if(!param1 && _loc2_ != 0)
            {
               this.progress = 0;
            }
            this.tweens = [];
            _subTweens = [];
            initTweenVals();
            _combinedTimeScale = (this.vars.timeScale || 1) * _globalTimeScale;
            if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null)
            {
               if(_dispatcher != null)
               {
                  this.vars.onStart = _callbacks.onStart;
                  this.vars.onUpdate = _callbacks.onUpdate;
                  this.vars.onComplete = _callbacks.onComplete;
                  _dispatcher = null;
               }
               initDispatcher();
            }
            if(_loc2_ != 0)
            {
               if(param1)
               {
                  adjustStartValues();
               }
               else
               {
                  this.progress = _loc2_;
               }
            }
         }
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         if(_dispatcher == null)
         {
            return false;
         }
         return _dispatcher.willTrigger(param1);
      }
      
      public function get reversed() : Boolean
      {
         return this.ease == reverseEase;
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         if(_dispatcher == null)
         {
            return false;
         }
         return _dispatcher.dispatchEvent(param1);
      }
      
      protected function onStartDispatcher(... rest) : void
      {
         if(_callbacks.onStart != null)
         {
            _callbacks.onStart.apply(null,this.vars.onStartParams);
         }
         _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
      }
      
      public function setDestination(param1:String, param2:*, param3:Boolean = true) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         var _loc6_:* = 0;
         var _loc7_:Object = null;
         var _loc8_:Array = null;
         var _loc9_:Array = null;
         _loc4_ = this.progress;
         if(this.vars[param1] != undefined && this.initted)
         {
            if(!param3 && _loc4_ != 0)
            {
               _loc6_ = int(this.tweens.length - 1);
               while(_loc6_ > -1)
               {
                  if(this.tweens[_loc6_].name == param1)
                  {
                     this.tweens[_loc6_].o[this.tweens[_loc6_].p] = this.tweens[_loc6_].s;
                  }
                  _loc6_--;
               }
            }
            _loc5_ = {};
            _loc5_[param1] = 1;
            killVars(_loc5_);
         }
         this.vars[param1] = param2;
         if(this.initted)
         {
            _loc7_ = this.vars;
            _loc8_ = this.tweens;
            _loc9_ = _subTweens;
            this.vars = {};
            this.tweens = [];
            _subTweens = [];
            this.vars[param1] = param2;
            initTweenVals();
            if(this.ease != reverseEase && _loc7_.ease is Function)
            {
               this.ease = _loc7_.ease;
            }
            if(param3 && _loc4_ != 0)
            {
               adjustStartValues();
            }
            this.vars = _loc7_;
            this.tweens = _loc8_.concat(this.tweens);
            _subTweens = _loc9_.concat(_subTweens);
         }
      }
      
      override public function initTweenVals(param1:Boolean = false, param2:String = "") : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:Function = null;
         param2 += " hexColors bezier bezierThrough orientToBezier quaternions onCompleteAll onCompleteAllParams yoyo loop onCompleteListener onUpdateListener onStartListener ";
         if(!param1 && this.delay != 0 && Boolean(TweenLite.overwriteManager.enabled))
         {
            TweenLite.overwriteManager.manageOverwrites(this,masterList[this.target]);
         }
         _loc8_ = bezierProxy;
         if(this.vars.orientToBezier == true)
         {
            this.vars.orientToBezier = [["x","y","rotation",0]];
            _loc8_ = bezierProxy2;
         }
         else if(this.vars.orientToBezier is Array)
         {
            _loc8_ = bezierProxy2;
         }
         if(this.vars.bezier != undefined && this.vars.bezier is Array)
         {
            _loc6_ = {};
            _loc7_ = this.vars.bezier;
            _loc4_ = 0;
            while(_loc4_ < _loc7_.length)
            {
               for(_loc3_ in _loc7_[_loc4_])
               {
                  if(_loc6_[_loc3_] == undefined)
                  {
                     _loc6_[_loc3_] = [this.target[_loc3_]];
                  }
                  if(typeof _loc7_[_loc4_][_loc3_] == "number")
                  {
                     _loc6_[_loc3_].push(_loc7_[_loc4_][_loc3_]);
                  }
                  else
                  {
                     _loc6_[_loc3_].push(this.target[_loc3_] + Number(_loc7_[_loc4_][_loc3_]));
                  }
               }
               _loc4_++;
            }
            for(_loc3_ in _loc6_)
            {
               if(typeof this.vars[_loc3_] == "number")
               {
                  _loc6_[_loc3_].push(this.vars[_loc3_]);
               }
               else
               {
                  _loc6_[_loc3_].push(this.target[_loc3_] + Number(this.vars[_loc3_]));
               }
               delete this.vars[_loc3_];
            }
            addSubTween("bezier",_loc8_,{"t":0},{"t":1},{
               "props":parseBeziers(_loc6_,false),
               "target":this.target,
               "orientToBezier":this.vars.orientToBezier
            });
         }
         if(this.vars.bezierThrough != undefined && this.vars.bezierThrough is Array)
         {
            _loc6_ = {};
            _loc7_ = this.vars.bezierThrough;
            _loc4_ = 0;
            while(_loc4_ < _loc7_.length)
            {
               for(_loc3_ in _loc7_[_loc4_])
               {
                  if(_loc6_[_loc3_] == undefined)
                  {
                     _loc6_[_loc3_] = [this.target[_loc3_]];
                  }
                  if(typeof _loc7_[_loc4_][_loc3_] == "number")
                  {
                     _loc6_[_loc3_].push(_loc7_[_loc4_][_loc3_]);
                  }
                  else
                  {
                     _loc6_[_loc3_].push(this.target[_loc3_] + Number(_loc7_[_loc4_][_loc3_]));
                  }
               }
               _loc4_++;
            }
            for(_loc3_ in _loc6_)
            {
               if(typeof this.vars[_loc3_] == "number")
               {
                  _loc6_[_loc3_].push(this.vars[_loc3_]);
               }
               else
               {
                  _loc6_[_loc3_].push(this.target[_loc3_] + Number(this.vars[_loc3_]));
               }
               delete this.vars[_loc3_];
            }
            addSubTween("bezierThrough",_loc8_,{"t":0},{"t":1},{
               "props":parseBeziers(_loc6_,true),
               "target":this.target,
               "orientToBezier":this.vars.orientToBezier
            });
         }
         if(this.vars.hexColors != undefined && typeof this.vars.hexColors == "object")
         {
            for(_loc3_ in this.vars.hexColors)
            {
               addSubTween("hexColors",hexColorsProxy,{
                  "r":this.target[_loc3_] >> 16,
                  "g":this.target[_loc3_] >> 8 & 0xFF,
                  "b":this.target[_loc3_] & 0xFF
               },{
                  "r":this.vars.hexColors[_loc3_] >> 16,
                  "g":this.vars.hexColors[_loc3_] >> 8 & 0xFF,
                  "b":this.vars.hexColors[_loc3_] & 0xFF
               },{
                  "prop":_loc3_,
                  "target":this.target
               });
            }
         }
         super.initTweenVals(true,param2);
      }
      
      protected function enable() : void
      {
         if(masterList[this.target] == undefined)
         {
            masterList[this.target] = new Dictionary(true);
         }
         if(masterList[this.target][this] != this)
         {
            _combinedTimeScale = _timeScale * _globalTimeScale;
            masterList[this.target][this] = this;
         }
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         if(_dispatcher != null)
         {
            _dispatcher.removeEventListener(param1,param2,param3);
         }
      }
      
      public function killProperties(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = 0;
         _loc2_ = {};
         _loc3_ = int(param1.length - 1);
         while(_loc3_ > -1)
         {
            if(this.vars[param1[_loc3_]] != null)
            {
               _loc2_[param1[_loc3_]] = 1;
            }
            _loc3_--;
         }
         killVars(_loc2_);
      }
      
      public function set progress(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:* = undefined;
         this.startTime = currentTime - this.duration * param1 * 1000;
         this.initTime = this.startTime - this.delay * (1000 / _combinedTimeScale);
         _loc2_ = this.active;
         render(currentTime);
         if(_pauseTime != -1)
         {
            _pauseTime = currentTime;
            this.startTime = 99999999999;
         }
         _loc3_ = this.vars.visible;
         if(this.vars.isTV == true)
         {
            _loc3_ = this.vars.exposedProps.visible;
         }
         if(_loc3_ != null && _isDisplayObject && param1 < 1)
         {
            this.target.visible = Boolean(_loc3_);
         }
      }
      
      public function reverse(param1:Boolean = true) : void
      {
         var _loc2_:Number = NaN;
         this.ease = this.vars.ease == this.ease ? reverseEase : this.vars.ease;
         _loc2_ = this.progress;
         if(_loc2_ < 1)
         {
            resume();
         }
         else if(this.vars.persist != true)
         {
            TweenLite.removeTween(this,false);
         }
         else
         {
            pause();
         }
         if(param1 && _loc2_ > 0)
         {
            this.startTime = currentTime - (1 - _loc2_) * this.duration * 1000 / _combinedTimeScale;
            this.initTime = this.startTime - this.delay * (1000 / _combinedTimeScale);
         }
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(param1)
         {
            pause();
         }
         else
         {
            resume();
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(_dispatcher == null)
         {
            initDispatcher();
         }
         if(param1 == TweenEvent.UPDATE && this.vars.onUpdate != onUpdateDispatcher)
         {
            this.vars.onUpdate = onUpdateDispatcher;
            _hasUpdate = true;
         }
         _dispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      protected function initDispatcher() : void
      {
         var _loc1_:Object = null;
         var _loc2_:String = null;
         if(_dispatcher == null)
         {
            _dispatcher = new EventDispatcher(this);
            _callbacks = {
               "onStart":this.vars.onStart,
               "onUpdate":this.vars.onUpdate,
               "onComplete":this.vars.onComplete
            };
            _loc1_ = {};
            for(_loc2_ in this.vars)
            {
               _loc1_[_loc2_] = this.vars[_loc2_];
            }
            this.vars = _loc1_;
            this.vars.onStart = onStartDispatcher;
            this.vars.onComplete = onCompleteDispatcher;
            if(this.vars.onStartListener is Function)
            {
               _dispatcher.addEventListener(TweenEvent.START,this.vars.onStartListener,false,0,true);
            }
            if(this.vars.onUpdateListener is Function)
            {
               _dispatcher.addEventListener(TweenEvent.UPDATE,this.vars.onUpdateListener,false,0,true);
               this.vars.onUpdate = onUpdateDispatcher;
               _hasUpdate = true;
            }
            if(this.vars.onCompleteListener is Function)
            {
               _dispatcher.addEventListener(TweenEvent.COMPLETE,this.vars.onCompleteListener,false,0,true);
            }
         }
      }
      
      protected function onUpdateDispatcher(... rest) : void
      {
         if(_callbacks.onUpdate != null)
         {
            _callbacks.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         if(_dispatcher == null)
         {
            return false;
         }
         return _dispatcher.hasEventListener(param1);
      }
      
      public function pause() : void
      {
         if(_pauseTime == -1)
         {
            _pauseTime = currentTime;
            this.startTime = 99999999999;
            this.forceActive = false;
         }
      }
      
      public function reverseEase(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return this.vars.ease(param4 - param1,param2,param3,param4);
      }
   }
}

