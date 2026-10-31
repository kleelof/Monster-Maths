package monsterMaths_fla
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.Sound;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol66")]
   public dynamic class boom_9 extends MovieClip
   {
      
      public var snd:Sound;
      
      public function boom_9()
      {
         super();
         addFrameScript(0,frame1,14,frame15);
      }
      
      internal function frame1() : *
      {
         snd = new boomSND();
         snd.play();
      }
      
      internal function frame15() : *
      {
         dispatchEvent(new Event("complete"));
         stop();
      }
   }
}

