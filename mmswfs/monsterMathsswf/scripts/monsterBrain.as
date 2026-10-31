package
{
   import flash.display.MovieClip;
   
   public class monsterBrain extends MovieClip
   {
      
      public var target:MovieClip;
      
      public var mode:String;
      
      public function monsterBrain()
      {
         super();
         mode = "idle";
      }
   }
}

