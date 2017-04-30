import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;
import controlP5.*;

int count = 0;

public class DancerState extends State {
  SettingState settingState;
  Capture video;
  OpenCV opencv;
  ArrayList<PVector> position = new ArrayList();
  ArrayList<Rectangle> d1_positions = new ArrayList();
  ArrayList<Rectangle> d2_positions = new ArrayList();
  ArrayList<Rectangle> d3_positions = new ArrayList();
  PImage src;
  ArrayList<Contour> d1_contours; // contours for color tracking
  ArrayList<Contour> d2_contours; // contours for color tracking
  ArrayList<Contour> d3_contours; // contours for color tracking
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


  // Main Exportables
  Dancer d1 = new Dancer();
  Dancer d2 = new Dancer();
  Dancer d3 = new Dancer();
  
  public Dancer[] dancers = {d1, d2, d3};
  
  DancerState(SettingState settingState) {
    this.settingState = settingState;
  }
 
  public void settings() {
    size(vidWidth * 2 + vidWidth / 2 + 30, vidHeight * 2 + 50);
  }
  
  public void setup() {
    this.video = new Capture(this, CAMERA_NAME);
    this.video.start();
    // init OpenCV with input resolution
    opencv = new OpenCV(this, vidWidth, vidHeight);
    
    // Set thresholding
    //toggleAdaptiveThreshold(useAdaptiveThreshold);
    
    ////////////////////////
    // for color tracking //
    ////////////////////////
    
    //Array for detection colors
    d1_contours = new ArrayList<Contour>();
    d2_contours = new ArrayList<Contour>();
    d3_contours = new ArrayList<Contour>();
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
          d1_contours = opencv.findContours(true,true);
        }
        
        if (outputs[1] != null) {
          opencv.loadImage(outputs[1]);
          d2_contours = opencv.findContours(true,true);
        }
        
        if (outputs[2] != null) {
          opencv.loadImage(outputs[2]);
          d3_contours = opencv.findContours(true,true); 
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
      
      /////////////////////////////////////////////////////////////////////
      // POPULATE DANCER'S POSITIONS AND DETECT AND DISPLAY BOUNDING BOX //
      /////////////////////////////////////////////////////////////////////
  
      /////////////////////////////// DANCER 1 /////////////////////////////////////////
  
      ////this populates for ALL contour bounding boxed
      //for (int i = 0; i < d1_contours.size(); i++) {
      //  Contour contour = d1_contours.get(i);
      //  Rectangle r = contour.getBoundingBox();
      //  d1_positions.add(r);
        
      //  if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      //    continue;
        
      //  //draw rectangles for detected bounding boxes
      //  stroke(255, 255, 255);
      //  fill(255, 255, 255, 150);
      //  strokeWeight(2);
      //  rect(r.x, r.y, r.width, r.height);
      //}
      
      //this populates the BIGGEST contour bounding box
      // <9> Check to make sure we've found any contours
      if (d1_contours.size() > 0) {
        // <9> Get the first contour, which will be the largest one
        Contour biggestContour = d1_contours.get(0);
        // <10> Find the bounding box of the largest contour,
        // and hence our object.
        Rectangle r = biggestContour.getBoundingBox();
        d1_positions.add(r);
        
        // <11> Draw the bounding box of our object
        //stroke(255, 255, 255);
        //fill(255, 255, 255, 150);
        //strokeWeight(2);
        //rect(r.x, r.y, r.width, r.height);
        
        // <12> Draw a dot in the middle of the bounding box, on the object.
        noStroke(); 
        fill(255, 255, 255);
        ellipse(r.x * 2 + r.width/2, r.y * 2 + r.height/2, 30, 30);
      }
    
      for (int i = 0; i < d1_positions.size(); i++) {
        
        //getting the normal position of the bounding box
        //float x = (float) d1_positions.get(i).x;
        //float y = (float) d1_positions.get(i).y;
        
        //UPDATING DANCER'S POSITION BASED ON THE CENTER OF THE BIGGEST BOUNDING BOX
        //getting the center of the bounding box as position
        float x = (float) d1_positions.get(i).x + d1_positions.get(i).width/2;
        float y = (float) d1_positions.get(i).y + d1_positions.get(i).height/2;
        
        //update Dancers position
        d1.updatePosition(new PVector(x, y));
  
      }//end of for loop
      
      /////////////////////////////// END DANCER 1 /////////////////////////////////////////
      
      /////////////////////////////// DANCER 2 /////////////////////////////////////////
      ////this populates for ALL contour bounding boxed
      //for (int i = 0; i < d2_contours.size(); i++) {
      //  Contour contour = d2_contours.get(i);
      //  Rectangle r = contour.getBoundingBox();
      //  d2_positions.add(r);
        
      //  if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      //    continue;
        
      //  //draw rectangles for detected bounding boxes
      //  stroke(255, 255, 255);
      //  fill(255, 255, 255, 150);
      //  strokeWeight(2);
      //  rect(r.x, r.y, r.width, r.height);
      //}
      
      //this populates the BIGGEST contour bounding box
      // <9> Check to make sure we've found any contours
      if (d2_contours.size() > 0) {
        // <9> Get the first contour, which will be the largest one
        Contour biggestContour = d2_contours.get(0);
        // <10> Find the bounding box of the largest contour,
        // and hence our object.
        Rectangle r = biggestContour.getBoundingBox();
        d2_positions.add(r);
        
        // <11> Draw the bounding box of our object
        //stroke(255, 255, 255);
        //fill(255, 255, 255, 150);
        //strokeWeight(2);
        //rect(r.x, r.y, r.width, r.height);
        
        // <12> Draw a dot in the middle of the bounding box, on the object.
        noStroke(); 
        fill(255, 255, 255);
        ellipse(r.x * 2 + r.width/2, r.y * 2 + r.height/2, 30, 30);
      }
      
      for (int i = 0; i < d2_positions.size(); i++) {
    
        //getting the normal position of the bounding box
        //float x = (float) d2_positions.get(i).x;
        //float y = (float) d2_positions.get(i).y;
        
        //UPDATING DANCER'S POSITION BASED ON THE CENTER OF THE BIGGEST BOUNDING BOX
        //getting the center of the bounding box as position
        float x = (float) d2_positions.get(i).x + d2_positions.get(i).width/2;
        float y = (float) d2_positions.get(i).y + d2_positions.get(i).height/2;
        
         
        //update Dancers position
        d2.updatePosition(new PVector(x, y));
  
      }//end of for loop
      
      /////////////////////////////// END DANCER 2 /////////////////////////////////////////
      
      /////////////////////////////// DANCER 3 /////////////////////////////////////////
      ////this populates for ALL contour bounding boxed
      //for (int i = 0; i < d3_contours.size(); i++) {
      //  Contour contour = d3_contours.get(i);
      //  Rectangle r = contour.getBoundingBox();
      //  d3_positions.add(r);
        
      //  if ((r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      //    continue;
        
      //  //draw rectangles for detected bounding boxes
      //  stroke(255, 255, 255);
      //  fill(255, 255, 255, 150);
      //  strokeWeight(2);
      //  rect(r.x, r.y, r.width, r.height);
      //}
      
      //this populates the BIGGEST contour bounding box
      // <9> Check to make sure we've found any contours
      if (d3_contours.size() > 0) {
        // <9> Get the first contour, which will be the largest one
        Contour biggestContour = d3_contours.get(0);
        // <10> Find the bounding box of the largest contour,
        // and hence our object.
        Rectangle r = biggestContour.getBoundingBox();
        d3_positions.add(r);
        
        // <11> Draw the bounding box of our object
        //stroke(255, 255, 255);
        //fill(255, 255, 255, 150);
        //strokeWeight(2);
        //rect(r.x, r.y, r.width, r.height);
        
        // <12> Draw a dot in the middle of the bounding box, on the object.
        if (colorToChange == -1) {
          noStroke(); 
          fill(255, 255, 255);
          ellipse(r.x * 2 + r.width/2, r.y * 2 + r.height/2, 30, 30);
        }
      }
      
      for (int i = 0; i < d3_positions.size(); i++) {
        
        //getting the normal position of the bounding box
        //float x = (float) d3_positions.get(i).x;
        //float y = (float) d3_positions.get(i).y;
        
        //UPDATING DANCER'S POSITION BASED ON THE CENTER OF THE BIGGEST BOUNDING BOX
        //getting the center of the bounding box as position
        float x = (float) d3_positions.get(i).x + d3_positions.get(i).width/2;
        float y = (float) d3_positions.get(i).y + d3_positions.get(i).height/2;
        
        //update Dancers position
        d3.updatePosition(new PVector(x, y));
  
      }//end of for loop
      
      /////////////////////////////// END DANCER 3 /////////////////////////////////////////
      
    }//end of if statement
  

  }//end of draw
  
  public void captureEvent(Capture c) {
    c.read();
  }
  
}