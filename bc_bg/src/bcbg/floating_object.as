package bcbg {
  import flash.display.*;
  import flash.events.*;
  import flash.geom.*;
  import flash.utils.Timer;
  import flash.filters.*;
  
  public class floating_object extends Sprite{ //this is a virtual class
    public var depth:Number; //current screen depth, needs to be public for parent sprite z-index processing
    public var pos_x:Number; //x position
    public var pos_y:Number; //y position
    public var pos_rot:Number; //rotation
    
    public var object_bitmap0:floating_object_bitmap;
    public var object_bitmap1:floating_object_bitmap;
    public var object_sprite:Sprite;
    protected var active_object_bitmap:uint;
    
    private var speed_x:Number; //current relative horizontal speed
    private var target_speed_x:Number; //target speed_x for the current time slot
    private var speed_y:Number; //current relative vertical speed
    private var target_speed_y:Number;
    private var target_depth:Number; //depth goes toward target_depth during depth variation
    private var initial_depth:Number; //depth comes from initial_depth during depth variation
    private var speed_rot:Number; //current rotation speed
    private var target_speed_rot:Number;
    private var focusFilter:BlurFilter;
    private var initial_focusFilter:BlurFilter;
    private var filtersArray:Array;
    
    private var changeMovementTimer:Timer;
    
    private var max_speed:Number; //absolute maximum horizontal and vertical speed
    private var speed_depth:Number; //absolute depth change speed
    private var max_speed_rot:Number; //absolute maximum rotation speed
    private var acceleration:Number; //absolute maximum acceleration
    private var min_depth:Number; //minimum depth, should be set to 0 for sprites to be unblurred, and must be less than or equal to depth step.
    private var min_depth_probability:Number; //probality for the sprite to come to min depth for a given time slot
    private var depth_step:Number; //first depth for the non min_depth domain, must be more or equal to min depth, and less or equal to max depth
    private var max_depth:Number; //maximum depth for the non min_depth domain, must be more than min depth, depth step, and less than 255
    private var min_duration:Number; //minimum duration of the time slots, in seconds
    private var max_duration:Number; //maximum duration of the time slots, in seconds
  
    private var messenger:EventDispatcher;
    
    public function floating_object(max_speed:Number, speed_depth:Number, max_speed_rot:Number, acceleration:Number, min_depth:Number, min_depth_probability:Number, depth_step:Number, max_depth:Number, min_duration:Number, max_duration:Number) {      
      this.messenger = bcbg_messages.getInstance();
      
      this.pos_x = 0;
      this.pos_y = 0;
      this.pos_rot = 0;
      
      this.max_speed = max_speed;
      this.speed_depth = speed_depth;
      this.max_speed_rot = max_speed_rot;
      this.acceleration = acceleration;
      this.min_depth = min_depth;
      this.min_depth_probability = min_depth_probability;
      this.depth_step = depth_step;
      this.max_depth = max_depth;
      this.min_duration = min_duration;
      this.max_duration = max_duration;
      this.depth = this.generateNewDepth();
      this.target_depth = this.depth;
      this.initial_depth = this.depth;
     
      this.active_object_bitmap = 0;
      
      this.object_sprite = new Sprite();
      this.object_bitmap0 = new floating_object_bitmap();
      this.object_bitmap1 = new floating_object_bitmap();
      this.object_bitmap1.alpha = 0;
      
      this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
     
    }
    
    protected function endConstruction():void {
      
      this.object_bitmap0.draw_object_image(this.object_sprite, this.depth);
      
      this.changeMovementTimer = new Timer(1, 0);
      this.changeMovementTimer.addEventListener(TimerEvent.TIMER, changeMovementTimerHandler); 
      this.changeMovement();
    }
    
    private function onEnterFrameHandler(event:Event):void {
      //acceleration to speed processing
      if (Math.abs(this.speed_x - this.target_speed_x) > this.acceleration) {
        this.speed_x += this.acceleration * (this.target_speed_x - this.speed_x);
      } else {
        this.speed_x = this.target_speed_x; 
      }
      
      if (Math.abs(this.speed_y - this.target_speed_y) > this.acceleration) {
        this.speed_y += this.acceleration * (this.target_speed_y - this.speed_y);
      } else {
        this.speed_y = this.target_speed_y; 
      }
      
      if (Math.abs(this.speed_rot - this.target_speed_rot) > this.acceleration) {
        this.speed_rot += this.acceleration * (this.target_speed_rot - this.speed_rot);
      } else {
        this.speed_rot = this.target_speed_rot; 
      }
      
      //speed to position processing
      this.pos_x += this.speed_x;
      this.pos_y += this.speed_y;
      this.pos_rot += this.speed_rot;
      
      if (this.target_depth != this.depth) {
        if (Math.abs(this.depth - this.target_depth) > this.speed_depth) {
          if(this.target_depth > this.depth){
            this.depth += this.speed_depth;
          } else {
            this.depth -= this.speed_depth;
          }
        } else {
          this.depth = this.target_depth;
        }
        var transitionCursor:Number = (this.depth - this.initial_depth) / (this.target_depth - this.initial_depth);
        if (transitionCursor < 0.5) {
          if (this.active_object_bitmap == 0) {
            this.object_bitmap0.alpha = 2 * transitionCursor; 
            this.object_bitmap1.alpha = 1;
          } else {
            this.object_bitmap1.alpha = 2 * transitionCursor; 
            this.object_bitmap0.alpha = 1;
          }
        } else {
          if (this.active_object_bitmap == 0) {
            this.object_bitmap0.alpha = 1; 
            this.object_bitmap1.alpha = 1 - 2 * (transitionCursor - 0.5);
          } else {
            this.object_bitmap1.alpha = 1; 
            this.object_bitmap0.alpha = 1 - 2 * (transitionCursor - 0.5);
          }
        }
      }
      
      this.object_bitmap0.x = this.pos_x;
      this.object_bitmap0.y = this.pos_y;
      this.object_bitmap0.rotation = this.pos_rot;
      this.object_bitmap1.x = this.pos_x;
      this.object_bitmap1.y = this.pos_y;
      this.object_bitmap1.rotation = this.pos_rot; 
    }
    
    private function changeMovementTimerHandler(event:TimerEvent):void {
      this.changeMovement();
    }
    
    private function changeMovement():void {
      this.changeMovementTimer.reset();
      
      this.target_speed_x = 2 * (Math.random() - 0.5 ) * this.max_speed;
      this.target_speed_y = 2 * (Math.random() - 0.5 ) * this.max_speed;
      this.target_speed_rot = 2 * (Math.random() - 0.5 ) * this.max_speed_rot;
      if ((Math.random() < 0.2)&&(this.target_depth == this.depth)) {
        this.initial_depth = this.depth;
        this.target_depth = generateNewDepth();
                
        if (this.depth != this.target_depth) {
          if (this.active_object_bitmap == 0) {
            this.active_object_bitmap = 1;
            this.object_bitmap1.draw_object_image(this.object_sprite, this.target_depth);
            this.messenger.dispatchEvent(new bcbg_event(bcbg_event.CHANGE_DEPTH, {target:this.object_bitmap1}));
          } else {
            this.active_object_bitmap = 0;
            this.object_bitmap0.draw_object_image(this.object_sprite, this.target_depth);
            this.messenger.dispatchEvent(new bcbg_event(bcbg_event.CHANGE_DEPTH, {target:this.object_bitmap0}));
          }
        }
      }
        
      this.changeMovementTimer.delay = 1000 * (this.min_duration + Math.random() * (this.max_duration - this.min_duration));
      this.changeMovementTimer.start();
    }
    
    private function generateNewDepth():Number {
      var random_depth_linear:Number = Math.random();
      if (random_depth_linear < this.min_depth_probability) {
        return this.min_depth;
      } else {
        return this.depth_step + ((this.max_depth - this.depth_step)*(random_depth_linear - this.min_depth_probability) / (1 - this.min_depth_probability));
      }
    }
  }
}