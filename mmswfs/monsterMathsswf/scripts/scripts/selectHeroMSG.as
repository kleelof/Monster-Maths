package
{
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol112")]
   public dynamic class selectHeroMSG extends MovieClip
   {
      
      public var hero:MovieClip;
      
      public var howTo_btn:SimpleButton;
      
      public var girl_mc:MovieClip;
      
      public var ok_btn:SimpleButton;
      
      public var name_txt:TextField;
      
      public var boy_mc:MovieClip;
      
      public function selectHeroMSG()
      {
         super();
         addFrameScript(0,frame1,1,frame2,2,frame3,3,frame4,4,frame5);
      }
      
      public function howTo(param1:Event) : void
      {
         gotoAndPlay("instructions");
      }
      
      public function init() : void
      {
      }
      
      public function exit(param1:MouseEvent) : void
      {
         if(hero != null && name_txt.text != "")
         {
            global.heroType = hero.name.substr(0,hero.name.indexOf("_"));
            global.heroName = name_txt.text;
            dispatchEvent(new Event("finished"));
         }
      }
      
      public function exiter3(param1:Event) : void
      {
         gotoAndPlay("instr4");
      }
      
      public function exiter4(param1:Event) : void
      {
         gotoAndPlay("home");
      }
      
      public function exiter2(param1:Event) : void
      {
         gotoAndPlay("instr3");
      }
      
      public function exiter(param1:Event) : void
      {
         gotoAndPlay("instr2");
      }
      
      internal function frame3() : *
      {
         stop();
         ok_btn.addEventListener(MouseEvent.CLICK,exiter2);
      }
      
      internal function frame1() : *
      {
         stop();
         hero = null;
         girl_mc.addEventListener(MouseEvent.CLICK,selHero);
         boy_mc.addEventListener(MouseEvent.CLICK,selHero);
         ok_btn.addEventListener(MouseEvent.CLICK,exit);
         howTo_btn.addEventListener(MouseEvent.CLICK,howTo);
      }
      
      internal function frame4() : *
      {
         stop();
         ok_btn.addEventListener(MouseEvent.CLICK,exiter3);
      }
      
      internal function frame5() : *
      {
         stop();
         ok_btn.addEventListener(MouseEvent.CLICK,exiter4);
      }
      
      public function selHero(param1:MouseEvent) : void
      {
         var _loc2_:GlowFilter = null;
         if(hero != null)
         {
            hero.filters = new Array();
         }
         hero = MovieClip(param1.currentTarget);
         _loc2_ = new GlowFilter();
         _loc2_.color = 16777215;
         _loc2_.blurX = 20;
         _loc2_.blurY = _loc2_.blurX;
         hero.filters = new Array(_loc2_);
      }
      
      internal function frame2() : *
      {
         stop();
         ok_btn.addEventListener(MouseEvent.CLICK,exiter);
      }
   }
}

