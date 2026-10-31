package monsterMaths_fla
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
   import gs.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol107")]
   public dynamic class digitsHolder_24 extends MovieClip
   {
      
      public var inx:Number;
      
      public var hite:Number;
      
      public var t0:digits;
      
      public var t2:digits;
      
      public var t3:digits;
      
      public var t7:digits;
      
      public var t1:digits;
      
      public var t9:digits;
      
      public var t5:digits;
      
      public var t8:digits;
      
      public var t4:digits;
      
      public var value:Number;
      
      public var t6:digits;
      
      public var t20:MovieClip;
      
      public var t22:MovieClip;
      
      public var back:MovieClip;
      
      public function digitsHolder_24()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = NaN;
         var _loc3_:MovieClip = null;
         inx = 0;
         _loc2_ = 0;
         while(_loc2_ <= 9)
         {
            _loc3_ = this["t" + String(_loc2_)];
            _loc3_.addEventListener(MouseEvent.CLICK,sel);
            _loc2_++;
         }
         t20.addEventListener(MouseEvent.CLICK,sel);
         t20.addEventListener(MouseEvent.MOUSE_OVER,respond);
         t20.addEventListener(MouseEvent.MOUSE_OUT,down);
         t22.addEventListener(MouseEvent.CLICK,sel);
         t22.addEventListener(MouseEvent.MOUSE_OVER,respond);
         t22.addEventListener(MouseEvent.MOUSE_OUT,down);
      }
      
      public function out(param1:MouseEvent) : void
      {
         param1.currentTarget.removeEventListener(MouseEvent.MOUSE_OUT,out);
         TweenMax.to(param1.currentTarget,0.5,{
            "scaleX":1,
            "scaleY":1
         });
         param1.currentTarget.addEventListener(MouseEvent.MOUSE_OVER,ovr);
      }
      
      public function sel(param1:MouseEvent) : void
      {
         trace("tick");
         value = Number(param1.currentTarget.name.substr(1));
      }
      
      public function ovr(param1:MouseEvent) : void
      {
         param1.currentTarget.removeEventListener(MouseEvent.MOUSE_OVER,ovr);
         TweenMax.to(param1.currentTarget,0.5,{
            "scaleX":1.5,
            "scaleY":1.5
         });
         param1.currentTarget.addEventListener(MouseEvent.MOUSE_OUT,out);
      }
      
      public function down(param1:Event) : void
      {
         TweenMax.to(param1.currentTarget,0.5,{
            "scaleX":1,
            "scaleY":1
         });
      }
      
      public function respond(param1:MouseEvent) : void
      {
         TweenMax.to(param1.currentTarget,0.5,{
            "scaleX":1.25,
            "scaleY":1.25
         });
      }
      
      internal function frame1() : *
      {
      }
   }
}

