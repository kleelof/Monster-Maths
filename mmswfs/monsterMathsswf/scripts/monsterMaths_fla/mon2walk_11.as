package monsterMaths_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol77")]
   public dynamic class mon2walk_11 extends MovieClip
   {
      
      public var boom_mc:MovieClip;
      
      public function mon2walk_11()
      {
         super();
         addFrameScript(24,frame25,25,frame26);
      }
      
      internal function frame25() : *
      {
         gotoAndPlay(1);
      }
      
      internal function frame26() : *
      {
         boom_mc.gotoAndPlay("start");
         stop();
      }
   }
}

