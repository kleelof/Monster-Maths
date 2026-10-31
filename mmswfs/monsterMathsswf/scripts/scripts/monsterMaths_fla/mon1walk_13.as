package monsterMaths_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol67")]
   public dynamic class mon1walk_13 extends MovieClip
   {
      
      public var boom_mc:MovieClip;
      
      public function mon1walk_13()
      {
         super();
         addFrameScript(36,frame37,37,frame38);
      }
      
      internal function frame37() : *
      {
         gotoAndPlay(1);
      }
      
      internal function frame38() : *
      {
         boom_mc.gotoAndPlay("start");
         stop();
      }
   }
}

