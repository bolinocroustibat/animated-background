package bcbg {
  import flash.display.*;
  import flash.utils.getTimer;
  import flash.events.Event;
  
  public class FrameRateCounter extends Sprite {
    public var framesPerSecond:Number;
    public var averages:Object;
    public var framesFromStart:uint;
    
    private var lastTimer:int;
    private var currentTimer:int;
    private var samplesArray:Array;
    private var samplesArrayIndex:uint;
    
    public function FrameRateCounter() {
      this.framesPerSecond = 0;
      this.lastTimer = 0;
      this.framesFromStart = 0;
      
      this.averages = new Object();
      this.samplesArray = new Array(0);
      this.samplesArrayIndex = 0;
      this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
    }
    
    private function onEnterFrameHandler(event:Event):void {
      this.framesFromStart++;
      this.currentTimer = getTimer();
      this.framesPerSecond = 1000 / (this.currentTimer - this.lastTimer);
      this.samplesArray[this.samplesArrayIndex] = this.framesPerSecond;
      
      for each(var averageObject:Object in averages) {
        averageObject.accumulator += this.samplesArray[this.samplesArrayIndex];
        if (averageObject.start != 0) {
          averageObject.start--;
        } else {
          averageObject.accumulator -= this.samplesArray[(this.samplesArrayIndex + this.samplesArray.length - averageObject.samples) % this.samplesArray.length];
        }
      }
      
      this.lastTimer = this.currentTimer;
      this.samplesArrayIndex++;
      this.samplesArrayIndex %= this.samplesArray.length;
    }
    
    public function setAverage(numberOfSamples:uint):void {
      if (!this.averages["average_" + numberOfSamples]) {
        this.averages["average_" + numberOfSamples] = new Object();
        this.averages["average_" + numberOfSamples].samples = numberOfSamples;
        this.averages["average_" + numberOfSamples].accumulator = new Number(0);
        this.averages["average_" + numberOfSamples].start = numberOfSamples;
        
        if (this.samplesArray.length < numberOfSamples + 1) {
          this.samplesArray.length = numberOfSamples + 1;
          
        }
      }
    }
    
    public function getAverage(numberOfSamples:uint):Number {
      var return_value:Number;
      if (this.averages["average_" + numberOfSamples]) {
        return_value = this.averages["average_" + numberOfSamples].accumulator / (this.averages["average_" + numberOfSamples].samples - this.averages["average_" + numberOfSamples].start);
      } else {
        return_value = 0;
      }
      return return_value;
      
    }
  }
}