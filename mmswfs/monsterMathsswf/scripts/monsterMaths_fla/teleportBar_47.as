package monsterMaths_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol150")]
   public dynamic class teleportBar_47 extends MovieClip
   {
      
      public var theBar_mc:MovieClip;
      
      public var text_txt:TextField;
      
      public function teleportBar_47()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      internal function frame1() : *
      {
         addEventListener(Event.ENTER_FRAME,entFrame);
      }
      
      public function entFrame(param1:Event) : void
      {
         theBar_mc.scaleX = global.teleTime / global.teleStartTime;
         text_txt.text = String(int(global.teleTime / global.teleStartTime * 100)) + "%";
         text_txt.x = theBar_mc.x + theBar_mc.width - text_txt.width;
         text_txt.visible = true;
      }
   }
}

