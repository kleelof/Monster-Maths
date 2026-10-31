package
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   import gs.*;
   import gs.events.TweenEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol108")]
   public dynamic class questionPanel extends MovieClip
   {
      
      public var answer_txt:TextField;
      
      public var question_txt:TextField;
      
      public var theAnswer:Number;
      
      public var digitsHolder_mc:MovieClip;
      
      public function questionPanel()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:String = null;
         question_txt.text = "";
         for(_loc2_ in param1.question)
         {
            question_txt.appendText(param1.question[_loc2_]);
         }
         answer_txt.text = "";
         theAnswer = param1.result;
         digitsHolder_mc.init();
         digitsHolder_mc.addEventListener(MouseEvent.CLICK,sel);
         global.givingQuestion = true;
      }
      
      public function sel(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = Number(param1.currentTarget.value);
         trace("cmd: " + _loc2_);
         if(_loc2_ <= 9)
         {
            answer_txt.appendText(String(param1.currentTarget.value));
            if(Number(answer_txt.text) == theAnswer)
            {
               dispatchEvent(new Event("accept"));
            }
         }
         else if(_loc2_ == 20)
         {
            trace("back");
            if(answer_txt.text.length > 0)
            {
               answer_txt.text = answer_txt.text.substr(0,answer_txt.text.length - 1);
            }
         }
         else if(_loc2_ == 22)
         {
            trace("canceling");
            dispatchEvent(new Event("cancel"));
         }
         else if(_loc2_ == 21)
         {
            dispatchEvent(new Event("accept"));
         }
      }
      
      internal function frame1() : *
      {
      }
      
      public function kill() : void
      {
         var _loc1_:TweenMax = null;
         global.givingQuestion = false;
         _loc1_ = TweenMax.to(this,0.25,{"alpha":0});
         _loc1_.addEventListener(TweenEvent.COMPLETE,finish);
      }
      
      public function finish(param1:TweenEvent) : void
      {
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
      }
   }
}

