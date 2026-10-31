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
   import gs.events.TweenEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol153")]
   public dynamic class messenger_49 extends MovieClip
   {
      
      public var holder_mc:shield;
      
      public var screen_mc:MovieClip;
      
      public var theMessage:MovieClip;
      
      public function messenger_49()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init(param1:MovieClip) : void
      {
         var _loc2_:TweenMax = null;
         trace("messengerInit");
         theMessage = param1;
         screen_mc.alpha = 0;
         screen_mc.visible = true;
         _loc2_ = TweenMax.to(screen_mc,0.5,{"alpha":0.3});
         _loc2_.addEventListener(TweenEvent.COMPLETE,addMSG);
      }
      
      public function removeScreen(param1:Event) : void
      {
         screen_mc.visible = false;
         dispatchEvent(new Event("complete"));
      }
      
      public function addMSG(param1:Event) : void
      {
         var _loc2_:DropShadowFilter = null;
         var _loc3_:* = undefined;
         theMessage.alpha = 0;
         holder_mc.addChild(theMessage);
         _loc2_ = new DropShadowFilter();
         theMessage.filters = new Array(_loc2_);
         _loc3_ = TweenMax.to(theMessage,0.5,{"alpha":1});
         _loc3_.addEventListener(TweenEvent.COMPLETE,initMSG);
      }
      
      public function initMSG(param1:Event) : void
      {
         theMessage.init();
         theMessage.addEventListener("finished",finished);
      }
      
      internal function frame1() : *
      {
      }
      
      public function removeMSG(param1:Event) : void
      {
         var _loc2_:TweenMax = null;
         while(holder_mc.numChildren > 0)
         {
            holder_mc.removeChildAt(0);
         }
         _loc2_ = TweenMax.to(screen_mc,0.5,{"alpha":0});
         _loc2_.addEventListener(TweenEvent.COMPLETE,removeScreen);
      }
      
      public function finished(param1:Event) : void
      {
         var _loc2_:TweenMax = null;
         _loc2_ = TweenMax.to(theMessage,0.5,{"alpha":0});
         _loc2_.addEventListener(TweenEvent.COMPLETE,removeMSG);
      }
   }
}

