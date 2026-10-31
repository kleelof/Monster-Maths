package dragger
{
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gs.*;
   
   public class draggie extends MovieClip
   {
      
      public static const DRAG_COMPLETE:String = "dragComplete";
      
      public static const DRAGGING:String = "dragging";
      
      public static const DRAG_STARTED:String = "dragStarted";
      
      internal var cursorPos:Point;
      
      public var dragFilters:Array;
      
      internal var E:EventDispatcher = new EventDispatcher();
      
      internal var P:MovieClip;
      
      public var draggableX:Boolean;
      
      public var dragging:Boolean = false;
      
      internal var filtersHolder:Array;
      
      internal var grabbed:Boolean;
      
      public var dragArea:Rectangle;
      
      public function draggie(param1:MovieClip, param2:Object)
      {
         super();
         P = param1;
         grabbed = false;
         dragArea = new Rectangle(0,0,0,0);
         if(param2.dragArea)
         {
            dragArea = new Rectangle(param2.dragArea.x,param2.dragArea.y,param2.dragArea.width,param2.dragArea.height);
         }
         dragFilters = null;
         if(param2.dragFilters)
         {
            trace("setDragFilters");
            dragFilters = param2.dragFilters;
         }
         draggable = true;
         if(param2.draggable == false)
         {
            trace("setrDraggable: " + param2.draggable);
            draggable = param2.draggable;
         }
      }
      
      public function set draggable(param1:Boolean) : void
      {
         P.buttonMode = param1;
         draggableX = param1;
         switch(param1)
         {
            case true:
               P.addEventListener(MouseEvent.MOUSE_DOWN,grab);
               break;
            case false:
               trace("draggable: " + param1);
               P.removeEventListener(MouseEvent.MOUSE_DOWN,grab);
         }
      }
      
      internal function mouseMoved(param1:MouseEvent) : void
      {
         filtersHolder = null;
         if(grabbed == true && dragging == false)
         {
            grabbed == false;
            dragging = true;
            dispatchEvent(new Event(DRAG_STARTED));
            if(dragFilters != null)
            {
               filtersHolder = P.filters;
               P.filters = dragFilters;
            }
            P.startDrag(false,dragArea);
            P.addEventListener(MouseEvent.MOUSE_UP,letGo);
            P.parent.addChild(P);
         }
         else if(dragging == true)
         {
            dispatchEvent(new Event(DRAGGING));
         }
      }
      
      internal function grab(param1:MouseEvent) : void
      {
         if(draggable == true)
         {
            trace("grabbed");
            grabbed = true;
            P.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
            P.addEventListener(MouseEvent.MOUSE_UP,letGo);
            P.removeEventListener(MouseEvent.MOUSE_DOWN,grab);
         }
      }
      
      public function letGo(param1:MouseEvent) : void
      {
         trace("letGo");
         dragging = false;
         P.stopDrag();
         dispatchEvent(new Event(DRAG_COMPLETE));
         grabbed = false;
         P.filters = filtersHolder;
         P.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoved);
         P.removeEventListener(MouseEvent.MOUSE_UP,letGo);
         P.parent.removeEventListener(MouseEvent.MOUSE_OUT,letGo);
         P.addEventListener(MouseEvent.MOUSE_DOWN,grab);
      }
      
      public function get draggable() : Boolean
      {
         return draggableX;
      }
   }
}

