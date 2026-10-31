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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol145")]
   public dynamic class heroHeads_46 extends MovieClip
   {
      
      public var girl_mc:MovieClip;
      
      public var boy_mc:MovieClip;
      
      public function heroHeads_46()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      internal function frame1() : *
      {
         boy_mc.visible = false;
         girl_mc.visible = false;
         addEventListener(Event.ENTER_FRAME,entFrame);
      }
      
      public function entFrame(param1:Event) : void
      {
         if(global.heroType)
         {
            this[global.heroType + "_mc"].visible = true;
            removeEventListener(Event.ENTER_FRAME,entFrame);
         }
      }
   }
}

