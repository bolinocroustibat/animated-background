package bcbg {
  public class floating_square extends floating_object {
    private var color:uint;
    private var size:uint;
    
    public function floating_square(max_speed:Number, speed_depth:Number, max_speed_rot:Number, acceleration:Number, min_depth:Number, min_depth_probability:Number, depth_step:Number, max_depth:Number, min_duration:Number, max_duration:Number, color:uint, size:uint) {
      super(max_speed, speed_depth, max_speed_rot, acceleration, min_depth, min_depth_probability, depth_step, max_depth, min_duration, max_duration);
      this.color = color;
      this.size = size;
      
      this.draw_square();
      this.endConstruction();
    }
    
    private function draw_square():void {
      this.object_sprite.graphics.clear();
      this.object_sprite.graphics.lineStyle();
      this.object_sprite.graphics.beginFill(this.color,1)
      this.object_sprite.graphics.drawRect( - this.size /2, - this.size /2, this.size, this.size);
      this.object_sprite.graphics.endFill();
    }
  }
}