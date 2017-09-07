package bcbg {
  import flash.display.*;
  import flash.geom.*;
  import flash.filters.*;
  import flash.events.*;
  
  public class floating_object_bitmap extends Sprite{
    
    public var floatingObjectImage:Bitmap;
    private var floatingObjectBitmapData:BitmapData;
    public var depth:Number;
    
    private var messenger:EventDispatcher;
    
    public function floating_object_bitmap() {
      this.messenger = bcbg_messages.getInstance();
      
      this.depth = 0;
      //this.floatingObjectImage = new Bitmap(null, PixelSnapping.ALWAYS, false);
      //this.floatingObjectBitmapData = null;
      this.floatingObjectImage = new Bitmap(null, PixelSnapping.AUTO, false);
      this.addChild(this.floatingObjectImage);
    }
    
    public function draw_object_image(object_sprite:Sprite, new_depth:Number):void {
      if((object_sprite.width !=0)&&((object_sprite.width !=0))){
        this.depth = new_depth;

        var boundsRect:Rectangle = object_sprite.getBounds(object_sprite);
        var draw_matrix:Matrix = new Matrix(1, 0, 0, 1, -boundsRect.left + this.depth, -boundsRect.top + this.depth);
        var draw_colorTransform_bleach:Number = (64 - this.depth) / 64;
        var draw_colorTransform:ColorTransform = new ColorTransform(draw_colorTransform_bleach, draw_colorTransform_bleach, draw_colorTransform_bleach, 1, 0, 0, 0, 0);
        //var draw_colorTransform:ColorTransform = new ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0);
        var focusFilter:BlurFilter = new BlurFilter(this.depth, this.depth, BitmapFilterQuality.MEDIUM);
        
        this.floatingObjectImage.visible = false;
        if (this.floatingObjectBitmapData) {
          this.floatingObjectBitmapData.dispose();
        }
        this.floatingObjectBitmapData = new BitmapData(object_sprite.width + 2 * this.depth, object_sprite.height + 2 * this.depth, true, 0);
        this.floatingObjectImage.bitmapData = this.floatingObjectBitmapData;
        this.floatingObjectImage.x = boundsRect.left - this.depth;
        this.floatingObjectImage.y = boundsRect.top - this.depth;
        this.floatingObjectBitmapData.draw(object_sprite, draw_matrix, draw_colorTransform);
        this.floatingObjectBitmapData.applyFilter(this.floatingObjectBitmapData, this.floatingObjectBitmapData.rect, new Point(0, 0), focusFilter);
        this.floatingObjectImage.visible = true;
        
        this.messenger.dispatchEvent(new bcbg_event(bcbg_event.CHANGE_DEPTH, { target:this } ));
      }
    } 
  }
}