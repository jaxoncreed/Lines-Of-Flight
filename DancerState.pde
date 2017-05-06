import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import controlP5.*;

int count = 0;

public class DancerState extends State {
  SettingState settingState;
  Capture video;
  //Movie video;
  OpenCV opencv;
  int counter = 0;
  Dancer[] dancers = {
    new Dancer(color(255, 255, 255, 15)),
    new Dancer(color(7, 11, 76, 15)),
    new Dancer(color(148, 18, 96, 15))
  };
  int numberOfDancers = dancers.length;
  //calculates distance between each position update. 
  float d1_dist_jump;
  float d2_dist_jump;
  float d3_dist_jump;
  float[] dist_jump = new float[numberOfDancers];
  ArrayList<ArrayList<Rectangle>> positions = new ArrayList<ArrayList<Rectangle>>();

  PImage src;
  
  ArrayList<Contour> contours = new ArrayList<Contour>();

  int maxColors = 3;
  int[] hues;
  int[] colors;
  int hueRangeWidth = 17;
  PImage[] outputs;
  int colorToChange = -1;
  ControlP5 cp5;
  ///////////////////////////////
  //FOR BETTER IMAGE FILTERING //
  ///////////////////////////////
  float contrast = 10.66;
  int brightness = 0;
  int threshold = 75;
  boolean useAdaptiveThreshold = false; // use adaptive thresholding over basic thresholding to start
  int thresholdBlockSize = 601;
  int thresholdConstant = 9;
  int blobSizeThreshold = 40;
  int blurSize = 4;

  
  DancerState(SettingState settingState) {
    this.settingState = settingState;
  }
 
  public void settings() {
    size(vidWidth * 2 + vidWidth / 2 + 30, vidHeight * 2 + 50);
  }
  
  public void setup() {
    for (int i = 0; i < numberOfDancers; i++) {
      positions.add(new ArrayList<Rectangle>());
    }
    
    this.video = new Capture(this, CAMERA_NAME);
    this.video.start();
    //video = new Movie(this, "/Users/chelsi/Documents/Processing/LinesOfFlight/data/TestFootage.mov");
    //video.loop();
    //video.volume(0);
    // init OpenCV with input resolution
    opencv = new OpenCV(this, vidWidth, vidHeight);
    
    // Set thresholding
    //toggleAdaptiveThreshold(useAdaptiveThreshold);
    
    ////////////////////////
    // for color tracking //
    ////////////////////////
    colors = new int[maxColors];
    hues = new int[maxColors];
    
    outputs = new PImage[maxColors];
    
    /**
     * UI
     */
    cp5 = new ControlP5(this);
    cp5.addSlider("threshold")
     .setRange(0,255)
     .setValue(threshold)
     .setPosition(0,vidHeight * 2)
     .setSize(this.width,20);
  }
  
  void threshold(int value) {
    this.threshold = value;
  }
  
  void keyPressed() {
    //For selction of colors to track
    //uses QWERTY keys
    if (key == '7') {
      colorToChange = 1;  
    } else if (key == '8') {
      colorToChange = 2;
      
    } else if (key == '9') {
      colorToChange = 3;
    }
  }
  
  void keyReleased() {
    colorToChange = -1; 
  }
  
  void mousePressed() {
    if (colorToChange > -1) {
      color c = get(mouseX, mouseY);
      //println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
     
      int hue = int(map(hue(c), 0, 255, 0, 180));
      
      colors[colorToChange-1] = c;
      hues[colorToChange-1] = hue;
      // dancers[colorToChange-1].c = c;
      
      //println("color index " + (colorToChange-1) + ", value: " + hue);
    }
  }
  
  public void draw() {  
    
    //this if is necessary when using live video. It gives pixels time to load so you don't get an error saying that
    //width and height of video are below 0. Can be left here when using test video as well. 
    if(this.video.width > 0 && this.video.height > 0) {
    
      //Load the new frame of our movie in to OpenCV
      if (this.video.available()) {
        this.video.read();
      }
    
      // <2> Load the new frame of our movie in to OpenCV
      opencv.loadImage(this.video);
      
      // Tell OpenCV to use color information
      opencv.useColor();
      src = opencv.getSnapshot();
  
      // <3> Tell OpenCV to work in HSV color space.
      opencv.useColor(HSB);
      
      ////////////////////
      // Detect Colors ///
      ////////////////////
      
        for (int i=0; i<hues.length; i++) {
          if (hues[i] <= 0) continue;
          opencv.loadImage(src);
          opencv.useColor(HSB);
          
          // <4> Copy the Hue channel of our image into 
          //     the gray channel, which we process.
          opencv.setGray(opencv.getH().clone());
          
          int hueToDetect = hues[i];
          //println("index " + i + " - hue to detect: " + hueToDetect);
          
          //<5> Filter the image based on the range of 
          //hue values that match the object we want to track.
          opencv.inRange(hueToDetect-hueRangeWidth/2, hueToDetect+hueRangeWidth/2);
          
          // <5.5>
          // image filtering to detect blobs better
          
           //Adaptive threshold - Good when non-uniform illumination
          if (useAdaptiveThreshold) {
            
            // Block size must be odd and greater than 3
            if (thresholdBlockSize%2 == 0) thresholdBlockSize++;
            if (thresholdBlockSize < 3) thresholdBlockSize = 3;
            
            opencv.adaptiveThreshold(thresholdBlockSize, thresholdConstant);
            
          // Basic threshold - range [0, 255]
          } else {
            opencv.threshold(threshold);
          }
        
          //Invert (black bg, white blobs)
          // opencv.invert();
          
          // Reduce noise - Dilate and erode to close holes
          opencv.dilate();
          opencv.erode();
          
          // Blur
          opencv.blur(blurSize);
          
          //// Save snapshot for display
          //PImage processedImage = opencv.getSnapshot();
          
          // <6> Save the processed image for reference.
          outputs[i] = opencv.getSnapshot();
        }
        
        //ITS ONLY FINDING THE CONTOURS OF THE FIRST ONE! ITS USINF THE SEPERATE OUTPUTS TO FIND CONTOURS 
        // <7> Find contours in our range image.
        //     Passing 'true' sorts them by descending area.
        if (outputs[0] != null) {
          opencv.loadImage(outputs[0]);
          contours = opencv.findContours(true,true);
        }
      
      // Show images
      if (colorToChange == -1) {
        image(src, 0, 0, src.width * 2, src.height * 2);
      }
      for (int i = 0; i<outputs.length; i++) {
        if (outputs[i] != null) {
          image(outputs[i], src.width * 2 +30, i*src.height / 2, src.width / 2, src.height / 2);
              
          noStroke();
          fill(colors[i]);
          rect(src.width * 2, i*src.height/2, 30, src.height/2);
        }
      }
          
      // Print text if new color expected
      textSize(20);
      stroke(255);
      fill(255);
          
      if (colorToChange > -1) {
        text("click to change color " + colorToChange, 10, 25);
      } else {
         text("press key [7,8, or 9] to select color", 10, 25);
      }
      
      //this populates the BIGGEST contour bounding box
      // <9> Check to make sure we've found any contours
      if (contours.size() > 0) {
        for (int i = 0; i < contours.size() && i < positions.size(); i++) {
          Rectangle r = contours.get(i).getBoundingBox();
          positions.get(i).add(r);
          noStroke(); 
          fill(255, 255, 255);
          ellipse(r.x * 2 + r.width/2, r.y * 2 + r.height/2, 30, 30);
          float x = r.x + r.width/2;
          float y = r.y + r.height/2;
          dancers[i].updatePosition(new PVector(x, y));
        }        
      }
    
    
      // TODO: add this back in to improve accuracy
      /*for (int i = 0; i < d1_positions.size(); i++) {
        float x = (float) d1_positions.get(i).x + d1_positions.get(i).width/2;
        float y = (float) d1_positions.get(i).y + d1_positions.get(i).height/2;
        
        d1_dist_jump = dist(d1.position.x, d1.position.y, x, y);
        println(d1_dist_jump);
        d1.updatePosition(new PVector(x, y));
        
      }//end of for loop*/

      
    }//end of if statement
  
    counter++;
   
  }//end of draw
  
  public void captureEvent(Capture c) {
    c.read();
  }
  
  void movieEvent(Movie m) {
    m.read();
  }
  
}