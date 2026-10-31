package monsterMaths_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol83")]
   public dynamic class mon3walk_8 extends MovieClip
   {
      
      public var boom_mc:MovieClip;
      
      public function mon3walk_8()
      {
         super();
         addFrameScript(20,frame21,21,frame22);
      }
      
      internal function frame22() : *
      {
         boom_mc.gotoAndPlay("start");
         stop();
      }
      
      internal function frame21() : *
      {
         gotoAndPlay(1);
      }
   }
}

