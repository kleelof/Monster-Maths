package
{
   import adobe.utils.*;
   import dragger.draggie;
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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol128")]
   public dynamic class Hero extends MovieClip
   {
      
      public var hero:MovieClip;
      
      public var stageSize:Point;
      
      public var girl_mc:MovieClip;
      
      public var DRG:draggie;
      
      public var isTeleporting:Boolean;
      
      public var mode:String;
      
      public var teleTimer:Timer;
      
      public var boy_mc:MovieClip;
      
      public function Hero()
      {
         super();
         addFrameScript(0,frame1);
      }
      
      public function init(param1:Point) : *
      {
         var _loc2_:DropShadowFilter = null;
         var _loc3_:GlowFilter = null;
         isTeleporting = false;
         boy_mc.visible = false;
         girl_mc.visible = false;
         hero = this[global.heroType + "_mc"];
         hero.visible = true;
         stageSize = param1;
         _loc2_ = new DropShadowFilter();
         _loc2_.distance = 10;
         _loc3_ = new GlowFilter();
         _loc3_.color = 65280;
         DRG = new draggie(this,{
            "dragFilters":new Array(_loc2_,_loc3_),
            "draggable":false,
            "dragArea":{
               "x":this.width / 2,
               "y":this.height / 2,
               "width":stageSize.x - this.width,
               "height":stageSize.y - this.height
            }
         });
      }
      
      public function teleComplete(param1:Event) : void
      {
         trace("TeleComplete");
         trace("testFiip: " + this.x + ":" + stageSize.x / 2);
         if(this.x < stageSize.x / 2 - 20)
         {
            trace("rigth: " + hero.scaleX);
            hero.right();
         }
         else if(this.x > stageSize.x / 2 + 20)
         {
            trace("left");
            hero.left();
         }
         killTele();
      }
      
      public function timerTix(param1:Event) : void
      {
         global.teleTime -= 100;
         if(global.teleTime < 1)
         {
            global.teleTime = 0;
            teleComplete(null);
         }
      }
      
      public function handFrame(param1:Event) : void
      {
         switch(mode)
         {
            case "play":
               DRG.draggable = true;
               DRG.addEventListener("dragStarted",dragStarted);
         }
         if(global.teleTime == 0)
         {
            DRG.draggable = false;
         }
         if(global.givingQuestion == true)
         {
            DRG.draggable = false;
         }
      }
      
      internal function frame1() : *
      {
         addEventListener(Event.ENTER_FRAME,handFrame);
      }
      
      public function killTele() : void
      {
         teleTimer.stop();
         isTeleporting = false;
         this.alpha = 1;
         stage.removeEventListener(Event.MOUSE_LEAVE,teleComplete);
         stage.removeEventListener(MouseEvent.MOUSE_UP,teleComplete);
         DRG.removeEventListener("dragComplete",teleComplete);
         DRG.letGo(null);
         this.alpha = 1;
         dispatchEvent(new Event("heroMoved"));
      }
      
      public function dragStarted(param1:Event) : void
      {
         trace("heroTele");
         if(global.teleTime > 0)
         {
            isTeleporting = true;
            this.alpha = 0.4;
            stage.addEventListener(Event.MOUSE_LEAVE,teleComplete);
            stage.addEventListener(MouseEvent.MOUSE_UP,teleComplete);
            DRG.addEventListener("dragComplete",teleComplete);
            teleTimer = new Timer(100);
            teleTimer.addEventListener(TimerEvent.TIMER,timerTix);
            teleTimer.start();
         }
      }
   }
}

