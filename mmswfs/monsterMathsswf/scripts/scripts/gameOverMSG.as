package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol23")]
   public dynamic class gameOverMSG extends MovieClip
   {
      
      public var playAgain_btn:SimpleButton;
      
      public function gameOverMSG()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
      }
      
      internal function frame1() : *
      {
         playAgain_btn.addEventListener(MouseEvent.CLICK,playAgain);
      }
      
      public function playAgain(param1:Event) : void
      {
         dispatchEvent(new Event("finished"));
      }
   }
}

