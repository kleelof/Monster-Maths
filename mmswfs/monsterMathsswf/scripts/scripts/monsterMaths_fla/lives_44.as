package monsterMaths_fla
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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol147")]
   public dynamic class lives_44 extends MovieClip
   {
      
      public var hero:MovieClip;
      
      public var lives:Number;
      
      public var t2:MovieClip;
      
      public var t3:MovieClip;
      
      public var t1:MovieClip;
      
      public function lives_44()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init() : void
      {
         var _loc1_:Number = NaN;
         trace("livesInit");
         lives = 3;
         _loc1_ = 1;
         while(_loc1_ <= lives)
         {
            this["t" + String(_loc1_)].visible = true;
            _loc1_++;
         }
      }
      
      internal function frame1() : *
      {
      }
      
      public function removeLife() : Boolean
      {
         this["t" + String(lives)].visible = false;
         lives = lives - 1;
         if(lives > 0)
         {
            return true;
         }
         return false;
      }
   }
}

