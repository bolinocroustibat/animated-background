package {
	import flash.events.*;
	import flash.display.*;
  import flash.net.*;
  
  import bcbg.*;
  
	public class Main extends Sprite {
    private const max_speed:Number = 0.9;
    private const max_depth_speed:Number = 0.06;
    private const max_rot_speed:Number = 0.9;
    private const acceleration:Number = 0.03;
    
    private var params_file_loader:URLLoader;
    
    private var min_pixels_per_object:uint;
    private var initial_pixels_per_object:uint;
    private var target_framerate:Number;
    private var min_framerate:Number;

    private var floating_objects_array:Array;
    private var floating_sprites_array:Array;
    private var number_of_objects:uint;
    private var target_number_of_objects:uint;
    private var max_number_of_objects:uint;
    private var floater_params_array:Array;
    private var floater_probability_sum:Number;
    
    private var fpsCounter:FrameRateCounter;
    private var messenger:EventDispatcher;
    
	public function Main():void {
      this.messenger = bcbg_messages.getInstance();
      
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
      
      stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
      stage.showDefaultContextMenu = false;
			stage.addEventListener(Event.RESIZE, onResizeHandler);
      
      //get parameters file
      
      var params_file:String;
      if ((LoaderInfo(this.root.loaderInfo).parameters['config_file']) && (LoaderInfo(this.root.loaderInfo).parameters['config_file'] != "")) {
        params_file = LoaderInfo(this.root.loaderInfo).parameters['config_file'];
      } else {
        params_file = "config_bg.xml";
      }
      
      var params_file_urlrequest:URLRequest = new URLRequest(encodeURI(params_file));
      this.params_file_loader = new URLLoader();
      this.params_file_loader.addEventListener(Event.COMPLETE, on_params_loaded);
      this.params_file_loader.load(params_file_urlrequest);
		}
		
    private function on_params_loaded(event:Event):void {
      //default config values
      this.target_framerate = 20;
      this.min_framerate = this.target_framerate -1;
      this.initial_pixels_per_object = 100000;
      this.min_pixels_per_object = 60000;

      
      //get and parse parameters file
      this.floater_params_array = new Array();
      this.floater_probability_sum = 0;
      
      var config_xml:XMLList = new XMLList(this.params_file_loader.data);
      var xml_number_param:Number;
      var xml_int_param:int;
      
      for each(var xml_elt:XML in config_xml) {
        switch(xml_elt.name().localName.toLowerCase()) {
          default:
          break;
          
          case "config":
            if (xml_elt.attribute("framerate")) {
              xml_number_param = Number(xml_elt.attribute("framerate"));
              if (!isNaN(xml_number_param)) {
                if (xml_number_param < 1) {
                  xml_number_param = 1;
                } else if (xml_number_param > 60) {
                  xml_number_param = 60;
                }
                this.target_framerate = xml_number_param;
              }
            }
            
            if (xml_elt.attribute("min_pixels_per_object")) {
              xml_int_param = uint(xml_elt.attribute("min_pixels_per_object"));
              if(xml_int_param != 0){
                if (xml_int_param < 3000) {
                  xml_int_param = 3000;
                }
                this.min_pixels_per_object = xml_int_param;
              }
            }
            
            if (xml_elt.attribute("initial_pixels_per_object")) {
              xml_int_param = uint(xml_elt.attribute("initial_pixels_per_object"));
              if(xml_int_param != 0){
                if (xml_int_param < 3000) {
                  xml_int_param = 3000;
                }
                this.initial_pixels_per_object = xml_int_param;
              }
            }
            
          break;
          
          case "floater":
            if (xml_elt.attribute("type")) {
              var valid_entry:Boolean = true;
              var floater_quantity:Number = 0;
              var floater_params_object:Object = new Object();
              
              if (xml_elt.attribute("quantity")) {
                xml_number_param = Number(xml_elt.attribute("quantity"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  floater_quantity = xml_number_param;
                }
              }
              
              if (floater_quantity == 0) {
                valid_entry = false; 
              }
                  
              floater_params_object.type = String(xml_elt.attribute("type"));
              floater_params_object.quantity = floater_quantity;
              this.floater_probability_sum += floater_quantity;
              floater_params_object.quantity_sum = this.floater_probability_sum;
              
              floater_params_object.maximum_speed = 18;
              if (xml_elt.attribute("maximum_speed")) {
                xml_number_param = Number(xml_elt.attribute("maximum_speed"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  floater_params_object.maximum_speed = xml_number_param;
                }
              }
              
              floater_params_object.maximum_depth_speed = 1.2;
              if (xml_elt.attribute("maximum_depth_speed")) {
                xml_number_param = Number(xml_elt.attribute("maximum_depth_speed"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  floater_params_object.maximum_depth_speed = xml_number_param;
                }
              }
              
              floater_params_object.maximum_rotation_speed = 0;
              if (xml_elt.attribute("maximum_rotation_speed")) {
                xml_number_param = Number(xml_elt.attribute("maximum_rotation_speed"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  floater_params_object.maximum_rotation_speed = xml_number_param;
                }
              }
              
              floater_params_object.acceleration = 0.6;
              if (xml_elt.attribute("acceleration")) {
                xml_number_param = Number(xml_elt.attribute("acceleration"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  floater_params_object.acceleration = xml_number_param;
                }
              }
              
              floater_params_object.min_depth = 0;
              if (xml_elt.attribute("min_depth")) {
                xml_number_param = Number(xml_elt.attribute("min_depth"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  if (xml_number_param > 64) {
                    xml_number_param = 64;
                  }
                  floater_params_object.min_depth = xml_number_param;
                }
              }
              
              floater_params_object.min_depth_probability = 0.01;
              if (xml_elt.attribute("min_depth_probability")) {
                xml_number_param = Number(xml_elt.attribute("min_depth_probability"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0) {
                    xml_number_param = 0;
                  }
                  if (xml_number_param > 1) {
                    xml_number_param = 1;
                  }
                  floater_params_object.min_depth_probability = xml_number_param;
                }
              }
              
              floater_params_object.depth_step = 8;
              if (xml_elt.attribute("depth_step")) {
                xml_number_param = Number(xml_elt.attribute("depth_step"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < floater_params_object.min_depth) {
                    xml_number_param = floater_params_object.min_depth;
                  }
                  if (xml_number_param > 64) {
                    xml_number_param = 64;
                  }
                  floater_params_object.depth_step = xml_number_param;
                }
              }
              
              floater_params_object.max_depth = 20;
              if (xml_elt.attribute("max_depth")) {
                xml_number_param = Number(xml_elt.attribute("max_depth"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < floater_params_object.depth_step) {
                    xml_number_param = floater_params_object.depth_step;
                  }
                  if (xml_number_param > 64) {
                    xml_number_param = 64;
                  }
                  floater_params_object.max_depth = xml_number_param;
                }
              }
              
              floater_params_object.min_duration = 2;
              if (xml_elt.attribute("min_duration")) {
                xml_number_param = Number(xml_elt.attribute("min_duration"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < 0.1) {
                    xml_number_param = 0.1;
                  }
                  floater_params_object.min_duration = xml_number_param;
                }
              }
              
              floater_params_object.max_duration = 6;
              if (xml_elt.attribute("max_duration")) {
                xml_number_param = Number(xml_elt.attribute("max_duration"));
                if (!isNaN(xml_number_param)) {
                  if (xml_number_param < floater_params_object.min_duration) {
                    xml_number_param = floater_params_object.min_duration;
                  }
                  floater_params_object.max_duration = xml_number_param;
                }
              }
              
              switch(String(xml_elt.attribute("type"))) {
                default:
                break;
                
                case "grey_circle":
                case "grey_square":
                  floater_params_object.min_size = 80;
                  if (xml_elt.attribute("min_size")) {
                    xml_number_param = Number(xml_elt.attribute("min_size"));
                    if (!isNaN(xml_number_param)) {
                      if (xml_number_param < 1) {
                        xml_number_param = 1;
                      }
                      if (xml_number_param > 250) {
                        xml_number_param = 250;
                      }
                      floater_params_object.min_size = xml_number_param;
                    }
                  }
                  
                  floater_params_object.max_size = 180;
                  if (xml_elt.attribute("max_size")) {
                    xml_number_param = Number(xml_elt.attribute("max_size"));
                    if (!isNaN(xml_number_param)) {
                      if (xml_number_param < floater_params_object.min_size) {
                        xml_number_param = floater_params_object.min_size;
                      }
                      if (xml_number_param > 250) {
                        xml_number_param = 250;
                      }
                      floater_params_object.max_size = xml_number_param;
                    }
                  }
                  
                  floater_params_object.min_luminosity = 90;
                  if (xml_elt.attribute("min_luminosity")) {
                    xml_number_param = Number(xml_elt.attribute("min_luminosity"));
                    if (!isNaN(xml_number_param)) {
                      if (xml_number_param < 0) {
                        xml_number_param = 0;
                      }
                      if (xml_number_param > 255) {
                        xml_number_param = 255;
                      }
                      floater_params_object.min_luminosity = xml_number_param;
                    }
                  }
                  
                  floater_params_object.max_luminosity = 120;
                  if (xml_elt.attribute("max_luminosity")) {
                    xml_number_param = Number(xml_elt.attribute("max_luminosity"));
                    if (!isNaN(xml_number_param)) {
                      if (xml_number_param < floater_params_object.min_luminosity) {
                        xml_number_param = floater_params_object.min_luminosity;
                      }
                      if (xml_number_param > 255) {
                        xml_number_param = 255;
                      }
                      floater_params_object.max_luminosity = xml_number_param;
                    }
                  }
                  
                break;
                
                case "image":
                  if (xml_elt.attribute("image_url")) {
                    floater_params_object.image_url = encodeURI(String(xml_elt.attribute("image_url")));
                  } else {
                    valid_entry = false;
                  }
                break;
                
                case "imageset":
                  if (xml_elt.children().length() > 0) {
                    floater_params_object.min_occurences = 0;
                    floater_params_object.images = new Array();
                    for each(var xml_image:XML in xml_elt.children()) {
                      if(xml_image.name().localName.toLowerCase() == "image"){
                        if (xml_image.attribute("image_url")) {
                          var image_object:Object = new Object();
                          image_object.image_url = encodeURI(String(xml_image.attribute("image_url")));
                          image_object.occurences = 0;
                          floater_params_object.images.push(image_object);
                        }
                      }
                    }
                    if (floater_params_object.images.length == 0) {
                      valid_entry = false;
                    }
                  } else {
                    valid_entry = false;
                  }
                break;
              }
            }
            
            if (valid_entry) {
              this.floater_params_array.push(floater_params_object);
            }
          break;
        }        
      }
      
      
      
      this.floating_objects_array = new Array();
      this.floating_sprites_array = new Array();
            
      stage.frameRate = this.target_framerate;
      
      this.target_number_of_objects = Math.floor(stage.stageWidth * stage.stageHeight / this.initial_pixels_per_object);
      this.max_number_of_objects = Math.floor(stage.stageWidth * stage.stageHeight / this.min_pixels_per_object);
      
      if (this.target_number_of_objects > this.max_number_of_objects) {
        this.target_number_of_objects = this.max_number_of_objects;
      }
      
      this.number_of_objects = 0;
      
      this.fpsCounter = new FrameRateCounter();
      this.fpsCounter.setAverage(10*stage.frameRate);
      
      var i:int;
      var floater:floating_object;
        
      for (i = 0; i < this.target_number_of_objects; i++) {  
        floater = createNewFloatingObject();
        floater.pos_x = Math.random() * stage.stageWidth;
        floater.pos_y = Math.random() * stage.stageHeight;
        //floater.pos_x = 150 + (i%6) * 150;
        //floater.pos_y = 150 + 150 * Math.floor(i / 6);
        this.floating_objects_array.push(floater);
        this.floating_sprites_array.push(floater.object_bitmap0);
        floater.object_bitmap0.x = floater.pos_x;
        floater.object_bitmap0.y = floater.pos_y;
        this.floating_sprites_array.push(floater.object_bitmap1);
        floater.object_bitmap1.x = floater.pos_x;
        floater.object_bitmap1.y = floater.pos_y;
        this.number_of_objects++;
      }
      this.floating_sprites_array.sortOn("depth", Array.NUMERIC | Array.DESCENDING);
      
      for (i = 0; i < this.floating_sprites_array.length; i++) {
        this.addChild(this.floating_sprites_array[i]);
      }
      
      this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
      this.onResize();
      this.messenger.addEventListener(bcbg_event.CHANGE_DEPTH, this.onChangeDepthHandler);
    }
    
    private function onResizeHandler(event:Event):void {
      this.onResize();
    }
    
    private function onResize():void {
      this.max_number_of_objects = Math.floor(stage.stageWidth * stage.stageHeight / this.min_pixels_per_object);
      if (this.target_number_of_objects > this.max_number_of_objects) {
        this.target_number_of_objects = this.max_number_of_objects;
      }
    }
    
    private function createNewFloatingObject():floating_object {
      var floater:floating_object;
      var random_number:Number;
      var chosen_object_index:uint = 0;

      random_number = Math.random() * this.floater_probability_sum;
      while ((chosen_object_index < this.floater_params_array.length - 1) && (this.floater_params_array[chosen_object_index].quantity_sum < random_number)) {
        chosen_object_index++;
      }
      
      switch(this.floater_params_array[chosen_object_index].type) {
        default:
        case "grey_circle":
          floater = new floating_circle(
            this.floater_params_array[chosen_object_index].maximum_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_depth_speed / stage.frameRate,
            0, 
            this.floater_params_array[chosen_object_index].acceleration / stage.frameRate,
            this.floater_params_array[chosen_object_index].min_depth,
            this.floater_params_array[chosen_object_index].min_depth_probability,
            this.floater_params_array[chosen_object_index].depth_step,
            this.floater_params_array[chosen_object_index].max_depth,
            this.floater_params_array[chosen_object_index].min_duration,
            this.floater_params_array[chosen_object_index].max_duration,
            (65536 + 256 + 1) * Math.floor(this.floater_params_array[chosen_object_index].min_luminosity + Math.random() * (this.floater_params_array[chosen_object_index].max_luminosity - this.floater_params_array[chosen_object_index].min_luminosity)),
            this.floater_params_array[chosen_object_index].min_size + Math.random() * (this.floater_params_array[chosen_object_index].max_size - this.floater_params_array[chosen_object_index].min_size)
          )
        break;
        
        case "grey_square":
          floater = new floating_square(
            this.floater_params_array[chosen_object_index].maximum_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_depth_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_rotation_speed / stage.frameRate, 
            this.floater_params_array[chosen_object_index].acceleration / stage.frameRate,
            this.floater_params_array[chosen_object_index].min_depth,
            this.floater_params_array[chosen_object_index].min_depth_probability,
            this.floater_params_array[chosen_object_index].depth_step,
            this.floater_params_array[chosen_object_index].max_depth,
            this.floater_params_array[chosen_object_index].min_duration,
            this.floater_params_array[chosen_object_index].max_duration,
            (65536 + 256 + 1) * Math.floor(this.floater_params_array[chosen_object_index].min_luminosity + Math.random() * (this.floater_params_array[chosen_object_index].max_luminosity - this.floater_params_array[chosen_object_index].min_luminosity)),
            this.floater_params_array[chosen_object_index].min_size + Math.random() * (this.floater_params_array[chosen_object_index].max_size - this.floater_params_array[chosen_object_index].min_size)
            
           )
        break;
        
        case "image":
          floater = new floating_image(
            this.floater_params_array[chosen_object_index].maximum_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_depth_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_rotation_speed / stage.frameRate, 
            this.floater_params_array[chosen_object_index].acceleration / stage.frameRate,
            this.floater_params_array[chosen_object_index].min_depth,
            this.floater_params_array[chosen_object_index].min_depth_probability,
            this.floater_params_array[chosen_object_index].depth_step,
            this.floater_params_array[chosen_object_index].max_depth,
            this.floater_params_array[chosen_object_index].min_duration,
            this.floater_params_array[chosen_object_index].max_duration,
            this.floater_params_array[chosen_object_index].image_url
          )
        break;
        
        case "imageset":
          var random_image_number:uint = Math.floor(Math.random() * this.floater_params_array[chosen_object_index].images.length);
          
          while (this.floater_params_array[chosen_object_index].min_occurences < this.floater_params_array[chosen_object_index].images[random_image_number].occurences) {
            random_image_number = (random_image_number + 1) % this.floater_params_array[chosen_object_index].images.length;
          }
          this.floater_params_array[chosen_object_index].images[random_image_number].occurences++;
          
          this.floater_params_array[chosen_object_index].min_occurences = this.floater_params_array[chosen_object_index].images[random_image_number].occurences;
          for (var i:uint = 0; i < this.floater_params_array[chosen_object_index].images.length; i++) {
            if (this.floater_params_array[chosen_object_index].min_occurences > this.floater_params_array[chosen_object_index].images[i].occurences) {
              this.floater_params_array[chosen_object_index].min_occurences = this.floater_params_array[chosen_object_index].images[i].occurences;
            }
          }
          
          floater = new floating_image(
            this.floater_params_array[chosen_object_index].maximum_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_depth_speed / stage.frameRate,
            this.floater_params_array[chosen_object_index].maximum_rotation_speed / stage.frameRate, 
            this.floater_params_array[chosen_object_index].acceleration / stage.frameRate,
            this.floater_params_array[chosen_object_index].min_depth,
            this.floater_params_array[chosen_object_index].min_depth_probability,
            this.floater_params_array[chosen_object_index].depth_step,
            this.floater_params_array[chosen_object_index].max_depth,
            this.floater_params_array[chosen_object_index].min_duration,
            this.floater_params_array[chosen_object_index].max_duration,
            this.floater_params_array[chosen_object_index].images[random_image_number].image_url
          )
          
        break;
      }
      return floater;
    }
    
    private function onChangeDepthHandler(event:bcbg_event):void {
      reorderFloatingSprite(event.params.target);
    }
    
    private function reorderFloatingSprite(floating_sprite:floating_object_bitmap):void {
      var i:int = 0;
      var new_index:int = -1;
      var old_index:int = -1;
      
      while(i < this.floating_sprites_array.length) {
        if (this.floating_sprites_array[i] == floating_sprite) {
          old_index = i;
        }
        if(new_index == -1){
          if (this.floating_sprites_array[i].depth < floating_sprite.depth) {
            new_index = i;
          }
        }
        i++;
      }
      if(old_index != -1){
        if (new_index == -1) {
          new_index = this.floating_sprites_array.length - 1;
        }
        if(new_index != old_index){
          this.setChildIndex(floating_sprite, this.getChildIndex(this.floating_sprites_array[new_index]));
          if (old_index < new_index) {
            this.floating_sprites_array.splice(new_index, 0, floating_sprite);
            this.floating_sprites_array.splice(old_index, 1);
          } else {
            this.floating_sprites_array.splice(old_index, 1);
            this.floating_sprites_array.splice(new_index, 0, floating_sprite);
          }
        }
      }
    }
    
    private function onEnterFrameHandler(event:Event):void {
      onEnterFrame();
    }
    
    private function onEnterFrame():void {
      var i:int;
      var j:int;
      var floater:floating_object;
      var delete_floater:Boolean = false;
      
      if (this.fpsCounter.framesFromStart % 10*stage.frameRate == 0){
        if (this.fpsCounter.getAverage(10*stage.frameRate) > this.min_framerate + 1.15) {
          if(this.target_number_of_objects < this.max_number_of_objects){
            this.target_number_of_objects++;
          }
        }
      }
      
      if (this.fpsCounter.framesFromStart % 10*stage.frameRate == 0){
        if (this.fpsCounter.getAverage(10*stage.frameRate) < this.min_framerate) {
          if(this.target_number_of_objects > 0){
            this.target_number_of_objects--;
          }
        }
      }
      
      if (this.number_of_objects < this.target_number_of_objects) {
        floater = createNewFloatingObject();
        switch(Math.floor(Math.random() * 4)) {
          case 0:
            floater.pos_x = - (floater.object_sprite.width + floater.object_sprite.height) / 2;
            floater.pos_y = Math.floor(Math.random() * stage.stageHeight);
          break;
          
          case 1:
            floater.pos_x = stage.stageWidth + (floater.object_sprite.width + floater.object_sprite.height) / 2;
            floater.pos_y = Math.floor(Math.random() * stage.stageHeight);
          break;
          
          case 2:
            floater.pos_x = Math.floor(Math.random() * stage.stageWidth);
            floater.pos_y = - (floater.object_sprite.width + floater.object_sprite.height) / 2;
          break;
          
          case 3:
          default:
            floater.pos_x = Math.floor(Math.random() * stage.stageWidth);
            floater.pos_y = stage.stageHeight + (floater.object_sprite.width + floater.object_sprite.height) / 2;
          break;
          
        }
        this.addChild(floater.object_bitmap0);
        this.addChild(floater.object_bitmap1);
        this.floating_objects_array.push(floater);
        this.floating_sprites_array.push(floater.object_bitmap0);
        this.floating_sprites_array.push(floater.object_bitmap1);
        floater.object_bitmap0.x = floater.pos_x;
        floater.object_bitmap0.y = floater.pos_y;
        floater.object_bitmap1.x = floater.pos_x;
        floater.object_bitmap1.y = floater.pos_y;
        this.number_of_objects++;
        reorderFloatingSprite(floater.object_bitmap0);
        reorderFloatingSprite(floater.object_bitmap1);
        
      }
      
      for (i = 0; i < this.floating_objects_array.length; i++) {
        if (this.number_of_objects > this.target_number_of_objects + 8) {
          delete_floater = true;
        }
        
        if (this.floating_objects_array[i].pos_x < - (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height) / 2) {
          if (this.number_of_objects > this.target_number_of_objects) {
            delete_floater = true;
          }
          this.floating_objects_array[i].pos_x = stage.stageWidth + (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height)/2;
        }
        if (this.floating_objects_array[i].pos_x > stage.stageWidth + (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height) / 2) {
          if (this.number_of_objects > this.target_number_of_objects) {
            delete_floater = true;
          }
          this.floating_objects_array[i].pos_x = - (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height)/2;
        }
        if (this.floating_objects_array[i].pos_y < - (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height) / 2) {
          if (this.number_of_objects > this.target_number_of_objects) {
            delete_floater = true;
          }
          this.floating_objects_array[i].pos_y = stage.stageHeight + (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height)/2;
        }
        if (this.floating_objects_array[i].pos_y > stage.stageHeight + (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height) / 2) {
          if (this.number_of_objects > this.target_number_of_objects) {
            delete_floater = true;
          }
          this.floating_objects_array[i].pos_y = - (this.floating_objects_array[i].object_sprite.width + this.floating_objects_array[i].object_sprite.height)/2;
        }
        
        if (delete_floater) {
          for (j = 0; j < this.floating_sprites_array.length; j++) {
            if( (this.floating_sprites_array[j] == this.floating_objects_array[i].object_bitmap0) ||  (this.floating_sprites_array[j] == this.floating_objects_array[i].object_bitmap1)){
              this.removeChild(this.floating_sprites_array[j]);
              this.floating_sprites_array.splice(j, 1);
              j--;
            }
          }
          this.floating_objects_array.splice(i, 1);
          
          this.number_of_objects--;
          delete_floater = false;
        }
      }
    } 
	}
}