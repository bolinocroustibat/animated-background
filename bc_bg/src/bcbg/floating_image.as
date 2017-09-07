package bcbg {
  import flash.display.*
  import flash.events.Event;
  import flash.net.URLRequest;
  public class floating_image extends floating_object{
    private var image_loader:Loader;
    
    public function floating_image(max_speed:Number, speed_depth:Number, max_speed_rot:Number, acceleration:Number, min_depth:Number, min_depth_probability:Number, depth_step:Number, max_depth:Number, min_duration:Number, max_duration:Number, image_url:String) {
      super(max_speed, speed_depth, max_speed_rot, acceleration, min_depth, min_depth_probability, depth_step, max_depth, min_duration, max_duration);
      
      this.image_loader = new Loader();
      this.image_loader.load(new URLRequest(image_url));
      this.image_loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
      this.endConstruction();
    }
    
    private function initHandler(event:Event):void {
      this.image_loader.content.x = -this.image_loader.content.width / 2;
      this.image_loader.content.y = -this.image_loader.content.height / 2;
      this.object_sprite.addChild(this.image_loader.content);
      if(active_object_bitmap == 0){
        this.object_bitmap0.draw_object_image(this.object_sprite, this.depth);
      } else {
        this.object_bitmap1.draw_object_image(this.object_sprite, this.depth);
      }
      //this.endConstruction();
    }
    
  }
  
}