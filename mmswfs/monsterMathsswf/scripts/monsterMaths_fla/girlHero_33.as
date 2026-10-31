package monsterMaths_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol127")]
   public dynamic class girlHero_33 extends MovieClip
   {
      
      public var defScale:Number;
      
      public var body_mc:MovieClip;
      
      public function girlHero_33()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function left() : void
      {
         body_mc.scaleX = defScale;
      }
      
      public function right() : void
      {
         body_mc.scaleX = -defScale;
      }
      
      internal function frame1() : *
      {
         defScale = body_mc.scaleX;
      }
   }
}

