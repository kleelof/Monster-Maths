package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol19")]
   public dynamic class stageClearMSG extends MovieClip
   {
      
      public var level_txt:TextField;
      
      public var stage_txt:TextField;
      
      public function stageClearMSG()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
         var _loc1_:Timer = null;
         _loc1_ = new Timer(3000,1);
         _loc1_.addEventListener(TimerEvent.TIMER_COMPLETE,exit);
         _loc1_.start();
      }
      
      public function exit(param1:Event) : void
      {
         dispatchEvent(new Event("finished"));
      }
      
      internal function frame1() : *
      {
         level_txt.text = String(global.level);
         stage_txt.text = String(global.lStage);
      }
   }
}

