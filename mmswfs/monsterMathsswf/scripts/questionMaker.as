package
{
   public class questionMaker
   {
      
      public function questionMaker()
      {
         super();
      }
      
      public function getQuestion(param1:Number) : Object
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         switch(param1)
         {
            case 1:
               _loc2_ = Math.floor(Math.random() * 9);
               _loc3_ = Math.floor(Math.random() * 9);
               _loc4_ = _loc2_ + _loc3_;
               _loc5_ = "+";
               break;
            case 2:
               _loc2_ = Math.floor(Math.random() * 89) + 10;
               _loc3_ = Math.floor(Math.random() * 9);
               _loc4_ = _loc2_ + _loc3_;
               _loc5_ = "+";
               break;
            case 3:
               _loc2_ = Math.floor(Math.random() * 9);
               _loc3_ = Math.floor(Math.random() * _loc2_);
               _loc4_ = _loc2_ - _loc3_;
               _loc5_ = "-";
               break;
            case 4:
               _loc2_ = Math.floor(Math.random() * 89) + 10;
               _loc3_ = Math.floor(Math.random() * 9);
               _loc4_ = _loc2_ - _loc3_;
               _loc5_ = "-";
               break;
            case 5:
               _loc2_ = Math.floor(Math.random() * 99);
               _loc3_ = Math.floor(Math.random() * 99);
               _loc4_ = _loc2_ + _loc3_;
               _loc5_ = "+";
               break;
            case 6:
               _loc2_ = Math.floor(Math.random() * 89) + 11;
               _loc3_ = Math.floor(Math.random() * _loc2_ - 10) + 10;
               _loc4_ = _loc2_ - _loc3_;
               _loc5_ = "-";
               break;
            case 7:
               _loc2_ = Math.floor(Math.random() * 9);
               _loc3_ = Math.floor(Math.random() * 9);
               _loc4_ = _loc2_ * _loc3_;
               _loc5_ = "x";
               trace(_loc2_ + ":" + _loc3_ + ":" + _loc4_);
               break;
            case 8:
               _loc2_ = Math.floor(Math.random() * 8) + 1;
               _loc3_ = Math.floor(Math.random() * 8) + 1;
               _loc4_ = _loc2_;
               _loc2_ *= _loc3_;
               _loc5_ = "/";
               break;
            case 9:
               _loc2_ = Math.floor(Math.random() * 9);
               _loc3_ = Math.floor(Math.random() * 5) + 10;
               _loc4_ = _loc2_ * _loc3_;
               _loc5_ = "x";
               break;
            case 10:
               _loc2_ = Math.floor(Math.random() * 5) + 10;
               _loc3_ = Math.floor(Math.random() * 5) + 10;
               _loc4_ = _loc2_ * _loc3_;
               _loc5_ = "x";
         }
         _loc6_ = new Object();
         _loc6_.question = new Array();
         _loc6_.result = _loc4_;
         _loc6_.question.push(_loc2_);
         _loc6_.question.push(_loc5_);
         _loc6_.question.push(_loc3_);
         return _loc6_;
      }
   }
}

