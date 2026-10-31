package monsterMaths_fla
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol144")]
   public dynamic class score_42 extends MovieClip
   {
      
      public var points:Number;
      
      public var text_txt:TextField;
      
      public var heroName_txt:TextField;
      
      public function score_42()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function addPoints(param1:Number) : void
      {
         points += param1;
         writeScore();
      }
      
      public function writeScore() : void
      {
         text_txt.text = points.toString();
      }
      
      public function init() : void
      {
         trace("scoreInit");
         heroName_txt.text = global.heroName;
         points = 0;
         writeScore();
      }
      
      internal function frame1() : *
      {
      }
   }
}

