package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.text.TextField;
   import flash.utils.Timer;
   import gs.TweenMax;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol13")]
   public dynamic class startGameMSG extends MovieClip
   {
      
      public var music:Sound;
      
      public var tmr:Timer;
      
      public var level_txt:TextField;
      
      public var stage_txt:TextField;
      
      public function startGameMSG()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
         tmr = new Timer(1500,1);
         tmr.addEventListener(TimerEvent.TIMER_COMPLETE,finished);
         tmr.start();
      }
      
      internal function frame1() : *
      {
         music = new titleMusic();
         music.play();
         level_txt.text = String(global.level);
         stage_txt.text = String(global.lStage);
      }
      
      public function finished(param1:Event) : void
      {
         TweenMax.to(music,0.5,{"volume":0});
         dispatchEvent(new Event("finished"));
      }
   }
}

