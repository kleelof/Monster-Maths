package
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol78")]
   public dynamic class hopper extends MovieClip
   {
      
      public var points:Number;
      
      public var speed:Number;
      
      public var boom_mc:MovieClip;
      
      public var myBrain:MovieClip;
      
      public var mon2_mc:MovieClip;
      
      public var question:Object;
      
      public function hopper()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
         speed = 2 + int(global.level / 9);
         this.addEventListener(Event.ENTER_FRAME,handFrame);
      }
      
      public function removeMe(param1:Event) : void
      {
         trace("removeMe");
         this.parent.removeChild(this);
      }
      
      public function handFrame(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         _loc2_ = 0;
         switch(myBrain.mode)
         {
            case "question":
               _loc2_ = speed / 2;
               break;
            case "attack":
               _loc2_ = speed;
         }
         if(_loc2_ > 0)
         {
            _loc3_ = _loc2_ / 2;
            _loc4_ = _loc2_;
            if(Math.abs(x - myBrain.target.x) > Math.abs(y - myBrain.target.y))
            {
               _loc3_ = _loc2_;
               _loc4_ = _loc2_ / 2;
            }
            if(Math.floor(Math.random() * 2) == 1)
            {
               if(x < myBrain.target.x)
               {
                  x += _loc3_;
               }
               if(x > myBrain.target.x)
               {
                  x -= _loc3_;
               }
            }
            else
            {
               if(y < myBrain.target.y)
               {
                  y += _loc4_;
               }
               if(y > myBrain.target.y)
               {
                  y -= _loc4_;
               }
            }
            if(Math.abs(this.x - myBrain.target.x) < 10 && Math.abs(this.y - myBrain.target.y) < 10 && myBrain.target.isTeleporting == false)
            {
               trace("!!:Captured");
               dispatchEvent(new Event("heroCaptured"));
               myBrain.mode = "idle";
            }
            if(myBrain.target.x > this.x)
            {
               if(this.scaleX > 0)
               {
                  this.scaleX = -this.scaleX;
               }
            }
            else
            {
               this.scaleX = Math.abs(this.scaleX);
            }
         }
      }
      
      internal function frame1() : *
      {
      }
      
      public function kill() : void
      {
         this.removeEventListener(Event.ENTER_FRAME,handFrame);
         this.filters = new Array();
         mon2_mc.addEventListener("complete",removeMe);
         mon2_mc.gotoAndPlay("explode");
      }
   }
}

