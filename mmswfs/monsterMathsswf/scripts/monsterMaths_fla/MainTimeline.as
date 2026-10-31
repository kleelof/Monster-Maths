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
   import gs.*;
   
   [SWF(width="800", height="500", backgroundColor="#f3de47", frameRate="32")]
   public dynamic class MainTimeline extends MovieClip
   {
      
      public var hero:MovieClip;
      
      public var startMusic:Sound;
      
      public var tMusic:*;
      
      public var stageSize:Point;
      
      public var percent:Number;
      
      public var QP:MovieClip;
      
      public var mHanger_mc:MovieClip;
      
      public var T:TweenMax;
      
      public var ground_mc:MovieClip;
      
      public var score_mc:MovieClip;
      
      public var validator:URLLoader;
      
      public var splash_mc:MovieClip;
      
      public var messenger_mc:MovieClip;
      
      public var gamePlayMusic:Sound;
      
      public var mBrain:monsterBrain;
      
      public var qHolder_mc:shield;
      
      public var gamePlayPlyr:SoundChannel;
      
      public var teleportBar_mc:MovieClip;
      
      public var bar_mc:MovieClip;
      
      public var lives_mc:MovieClip;
      
      public var selectedMonster:MovieClip;
      
      public var names_mc:MovieClip;
      
      public var acceptTmr:Timer;
      
      public var numberOfMonsters:Number;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,frame1,2,frame3,3,frame4);
      }
      
      public function finished2(param1:Event) : void
      {
         gotoAndPlay("playGame");
      }
      
      public function acceptQuestion(param1:Event) : void
      {
         if(param1.currentTarget.answer_txt.text == selectedMonster.question.result)
         {
            param1.currentTarget.kill();
            score_mc.addPoints(selectedMonster.points);
            selectedMonster.kill();
            --numberOfMonsters;
            global.addTeleTime(200);
            if(numberOfMonsters == 0)
            {
               if(global.valid == true)
               {
                  messenger_mc.init(new stageClearMSG());
               }
               else
               {
                  messenger_mc.init(new invalidFile());
               }
               messenger_mc.addEventListener("complete",nextStage);
            }
            else
            {
               mBrain.mode = "attack";
            }
         }
         else
         {
            cancelQuestion(null);
         }
      }
      
      public function setUpGame(param1:Event) : void
      {
         tMusic.stop();
         messenger_mc.removeEventListener("complete",setUpGame);
         trace("setUpGame!!!");
         global.level = 1;
         global.lStage = 1;
         hero = new Hero();
         hero.init(stageSize);
         gamePlayMusic = new gamePlayMSC();
         score_mc.init();
         lives_mc.init();
         startGame();
      }
      
      public function fadeMe(param1:Event) : void
      {
         var _loc2_:TweenMax = null;
         _loc2_ = TweenMax.to(names_mc,0.75,{"alpha":0});
         _loc2_.addEventListener(Event.COMPLETE,finished);
      }
      
      internal function frame3() : *
      {
         stop();
         names_mc.alpha = 0;
         T = TweenMax.to(names_mc,0.75,{"alpha":1});
         T.addEventListener(Event.COMPLETE,holdNames);
         startMusic = new gamePlayMSC();
         tMusic = startMusic.play(0,999);
      }
      
      internal function frame4() : *
      {
         stop();
         stageSize = new Point(800,500);
         global.stageSize = stageSize;
         validator = new URLLoader();
         validator.addEventListener(Event.COMPLETE,validateFile);
         validator.load(new URLRequest("valid.dat"));
         messenger_mc.addEventListener("complete",setUpGame);
         messenger_mc.init(new selectHeroMSG());
      }
      
      internal function frame1() : *
      {
         loaderInfo.addEventListener(ProgressEvent.PROGRESS,update);
         percent = Math.floor(this.loaderInfo.bytesLoaded * 100 / this.loaderInfo.bytesTotal);
      }
      
      public function startGame() : void
      {
         while(mHanger_mc.numChildren > 0)
         {
            mHanger_mc.removeChildAt(0);
         }
         while(qHolder_mc.numChildren > 0)
         {
            qHolder_mc.removeChildAt(0);
         }
         mBrain = new monsterBrain();
         global.teleTime = global.teleStartTime;
         global.givingQuestion = false;
         addHero();
         if(gamePlayPlyr)
         {
            trace("fadeOut");
            TweenMax.to(gamePlayPlyr,1,{"volume":0});
         }
         messenger_mc.init(new startGameMSG());
         messenger_mc.addEventListener("complete",startPlay);
      }
      
      public function cancelQuestion(param1:Event) : void
      {
         selectedMonster.filters = new Array();
         QP.kill();
         mBrain.mode = "attack";
      }
      
      public function monsterSelected(param1:MouseEvent) : void
      {
         var _loc2_:GlowFilter = null;
         if(selectedMonster != null)
         {
            selectedMonster.filters = new Array();
            QP.kill();
         }
         selectedMonster = MovieClip(param1.currentTarget);
         _loc2_ = new GlowFilter();
         _loc2_.color = 255;
         _loc2_.quality = 1;
         selectedMonster.filters = new Array(_loc2_);
         QP = new questionPanel();
         QP.init(selectedMonster.question);
         qHolder_mc.addChild(QP);
         TweenMax.from(QP,0.25,{"alpha":0});
         QP.y = selectedMonster.y - (QP.height + 10);
         if(QP.y < 0)
         {
            QP.y = 5;
         }
         QP.x = selectedMonster.x - (QP.width + 10);
         if(QP.x < 0)
         {
            QP.x = 5;
         }
         QP.addEventListener("cancel",cancelQuestion);
         QP.addEventListener("accept",acceptQuestion);
      }
      
      public function finished(param1:Event) : void
      {
         var _loc2_:TweenMax = null;
         _loc2_ = TweenMax.to(splash_mc,0.75,{"alpha":0});
         _loc2_.addEventListener(Event.COMPLETE,finished2);
      }
      
      public function addMonsters(param1:Number, param2:Number, param3:Number) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:* = undefined;
         var _loc9_:* = undefined;
         var _loc10_:* = undefined;
         numberOfMonsters = 0;
         _loc4_ = new questionMaker();
         mBrain.mode = "idle";
         _loc5_ = global.level;
         while(_loc5_ > 10)
         {
            _loc5_ -= 9;
         }
         _loc7_ = 1;
         while(_loc7_ <= param1)
         {
            _loc8_ = new troll();
            _loc8_.points = 10;
            _loc6_ = _loc5_ - 1;
            if(_loc6_ < 1)
            {
               _loc6_ = 1;
            }
            _loc8_.question = _loc4_.getQuestion(_loc6_);
            placeMonster(_loc8_);
            _loc7_++;
         }
         _loc7_ = 1;
         while(_loc7_ <= param2)
         {
            _loc9_ = new hopper();
            _loc9_.points = 15;
            _loc9_.question = _loc4_.getQuestion(_loc5_);
            placeMonster(_loc9_);
            _loc7_++;
         }
         _loc7_ = 1;
         while(_loc7_ <= param3)
         {
            _loc10_ = new crab();
            _loc10_.points = 25;
            _loc6_ = _loc5_ + 1;
            if(_loc6_ > 10)
            {
               _loc6_ = 10;
            }
            _loc10_.question = _loc4_.getQuestion(_loc6_);
            placeMonster(_loc10_);
            _loc7_++;
         }
      }
      
      public function validateFile(param1:Event) : void
      {
         global.valid = true;
      }
      
      public function startPlay(param1:Event) : void
      {
         messenger_mc.removeEventListener("complete",startPlay);
         trace("startPlay");
         selectedMonster = null;
         switch(global.lStage)
         {
            case 1:
               addMonsters(7,3,1);
               break;
            case 2:
               addMonsters(5,5,1);
               break;
            case 3:
               addMonsters(3,7,2);
         }
         if(gamePlayPlyr)
         {
            gamePlayPlyr.stop();
         }
         gamePlayPlyr = gamePlayMusic.play(0,int.MAX_VALUE);
         hero.mode = "play";
         mBrain.mode = "attack";
         global.mode = "play";
      }
      
      public function playAgain(param1:Event) : void
      {
         messenger_mc.removeEventListener("complete",playAgain);
         setUpGame(null);
      }
      
      public function update(param1:ProgressEvent) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = Math.floor(param1.bytesLoaded * 100 / param1.bytesTotal);
         trace("pre: " + _loc2_);
         bar_mc.scaleX = _loc2_ / 100;
         if(_loc2_ == 100)
         {
            trace("gotoLogo");
            gotoAndPlay(2);
         }
      }
      
      public function addHero() : void
      {
         trace("addHero");
         mBrain.target = hero;
         hero.x = stageSize.x / 2 - hero.width / 2;
         hero.y = stageSize.y / 2 - hero.height / 2;
         mHanger_mc.addChild(hero);
      }
      
      public function nextStage(param1:Event) : void
      {
         messenger_mc.removeEventListener("complete",nextStage);
         ++global.lStage;
         if(global.lStage == 4)
         {
            ++global.level;
            global.lStage = 1;
            startGame();
         }
         else
         {
            startGame();
         }
      }
      
      public function placeMonster(param1:MovieClip) : void
      {
         var _loc2_:Number = NaN;
         ++numberOfMonsters;
         param1.init();
         param1.myBrain = mBrain;
         _loc2_ = 50;
         param1.x = -_loc2_;
         if(Math.floor(Math.random() * 2) == 1)
         {
            param1.x = stageSize.x;
         }
         param1.x += Math.floor(Math.random() + _loc2_);
         param1.y = Math.floor(Math.random() * (stageSize.y - param1.height));
         mHanger_mc.addChild(param1);
         param1.addEventListener(MouseEvent.CLICK,monsterSelected);
         param1.addEventListener("heroCaptured",heroCaptured);
      }
      
      public function holdNames(param1:Event) : void
      {
         var _loc2_:Timer = null;
         _loc2_ = new Timer(2000,1);
         _loc2_.addEventListener(TimerEvent.TIMER_COMPLETE,fadeMe);
         _loc2_.start();
      }
      
      public function heroCaptured(param1:Event) : void
      {
         if(lives_mc.removeLife() == false)
         {
            mBrain.mode = "idle";
            messenger_mc.init(new gameOverMSG());
            messenger_mc.addEventListener("complete",playAgain);
         }
         else
         {
            startGame();
         }
      }
   }
}

