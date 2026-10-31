package
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gs.TweenMax;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol100")]
   public dynamic class digits extends MovieClip
   {
      
      public var shield_mc:shield;
      
      public var text_txt:TextField;
      
      public function digits()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
      }
      
      internal function frame1() : *
      {
         shield_mc.width = width;
         shield_mc.height = height;
         shield_mc.buttonMode = true;
         addEventListener(MouseEvent.MOUSE_OVER,respond);
         addEventListener(MouseEvent.MOUSE_OUT,down);
         text_txt.text = name.substr(1);
      }
      
      public function respond(param1:MouseEvent) : void
      {
         TweenMax.to(this,0.5,{
            "scaleX":1.25,
            "scaleY":1.25
         });
      }
      
      public function down(param1:Event) : void
      {
         TweenMax.to(this,0.5,{
            "scaleX":1,
            "scaleY":1
         });
      }
   }
}

