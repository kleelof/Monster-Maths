package
{
   import flash.geom.Point;
   
   public class global
   {
      
      public static var mode:String;
      
      public static var level:Number;
      
      public static var heroName:String;
      
      public static var lStage:Number;
      
      public static var heroType:String;
      
      public static var teleTime:Number;
      
      public static var givingQuestion:Boolean;
      
      public static var valid:Boolean;
      
      public static var stageSize:Point;
      
      public static var teleStartTime:Number = 4000;
      
      public function global()
      {
         super();
         givingQuestion = false;
         teleTime = 0;
         valid = false;
      }
      
      public static function addTeleTime(param1:Number) : void
      {
         if(teleTime + param1 > teleStartTime)
         {
            teleTime = teleStartTime;
         }
         else
         {
            teleTime += param1;
         }
      }
   }
}

