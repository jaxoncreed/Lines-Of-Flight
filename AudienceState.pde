import processing.video.*;


public class AudienceState extends State {
  SettingState settingState;
  
  // All this is kinda messy
  Capture myMovie;
  ControlP5 cp5;
  PImage baseImg;
  PImage compared;
  int frameNum = 0;
  int areaDimension = 8;
  // Kernel for edge detection
  float[][] kernel = {{ -3, -3, -3}, 
                      { -3,  23, -3}, 
                      { -3, -3, -3}};
  int threshold = 0xDDDDDD;
  
  public int width = 0;
  public int height = 0;
  
  public ArrayList<AudienceMember> audience;
  
  
  AudienceState(SettingState settingState) {
    this.settingState = settingState;
    this.audience = new ArrayList<AudienceMember>();
  }
 
  public void settings() {
    size(1280, 740);
  }
  
  public void setup() {
    baseImg = createImage(vidWidth, vidHeight, RGB);
    baseImg.loadPixels();
    myMovie = new Capture(this, CAMERA_NAME);
    myMovie.start();
    
    /**
     * UI
     */
    /*cp5 = new ControlP5(this);
    cp5.addSlider("thresholdSlide")
     .setRange(0 ,0xFFFFFF)
     .setValue(75)
     .setPosition(0,720)
     .setSize(this.width,20);*/
  }
  
  /*void thresholdSlide(int value) {
    this.threshold = value;
  }*/
    
  void draw() {
    image(myMovie, 0, 0, 640, 360);
    
    if (frameNum % 1 == 0) {
      
      // PRODUCE COMPARISON IMAGE
      myMovie.loadPixels();
      compared = createImage(myMovie.width, myMovie.height, RGB);
      
      int areasWidth = ceil(myMovie.width / areaDimension);
      int areasHeight = ceil(myMovie.height / areaDimension);
      for (int areaY = 0; areaY < areasHeight; areaY++) {
        for (int areaX = 0; areaX < areasWidth; areaX++) {
          int sumR = 0;
          int sumG = 0;
          int sumB = 0;
          int total = 0;
          
          for (int y = areaY * areaDimension; y < (areaY * areaDimension) + areaDimension; y++) {
            for (int x = areaX * areaDimension; x < (areaX * areaDimension) + areaDimension; x++) {
              color currColor = myMovie.pixels[getIndexFromXY(x, y, myMovie.width, myMovie.height)];
              color bkgdColor = baseImg.pixels[getIndexFromXY(x, y, myMovie.width, myMovie.height)];
              
              // Extract the red, green, and blue components of the current pixel’s color
              int currR = (currColor >> 16) & 0xFF;
              int currG = (currColor >> 8) & 0xFF;
              int currB = currColor & 0xFF;
              // Extract the red, green, and blue components of the background pixel’s color
              int bkgdR = (bkgdColor >> 16) & 0xFF;
              int bkgdG = (bkgdColor >> 8) & 0xFF;
              int bkgdB = bkgdColor & 0xFF;
              // Compute the difference of the red, green, and blue values
              int diffR = abs(currR - bkgdR);
              int diffG = abs(currG - bkgdG);
              int diffB = abs(currB - bkgdB);
              
              sumR += diffR;
              sumG += diffG;
              sumB += diffB;
              total++;
            }
          }
          int finalR = sumR / total;
          int finalG = sumG / total;
          int finalB = sumB / total;
          int normalized = (finalR + finalG + finalB) / 3;
          
          for (int y = areaY * areaDimension; y < (areaY * areaDimension) + areaDimension; y++) {
            for (int x = areaX * areaDimension; x < (areaX * areaDimension) + areaDimension; x++) {
              compared.pixels[getIndexFromXY(x, y, myMovie.width, myMovie.height)] = color(normalized, normalized, normalized);
            }
          } 
        }
      }
      // "compared" is an image with lighter pixels being the ones that are different.
      compared.updatePixels();
      
      // APPLY THRESHOLD
      PImage thresholdImg = createImage(compared.width, compared.height, RGB);
      for (int i = 0; i < compared.pixels.length; i++) {
        if (compared.pixels[i] * -1 < threshold) {
          thresholdImg.pixels[i] = 0xFFFFFF;
        } else {
          thresholdImg.pixels[i] = 0x000000;
        }
      }
      thresholdImg.updatePixels();
      
      
      // BLOB DETECTION
      int[][] blobAreas = new int[areasWidth][areasHeight];
      int blobNum = 1;
      noFill();
      audience.clear();
      for (int areaX = 0; areaX < areasWidth; areaX++) {
        for (int areaY = 0; areaY < areasHeight; areaY++) {
          if (blobAreas[areaX][areaY] == 0 && thresholdImg.pixels[getIndexFromXY(areaX * areaDimension, areaY * areaDimension, myMovie.width, myMovie.height)] > 0x00000) {
            int[] squareDimensions = recursiveBlobCheck(areaX, areaY, areaX, areaY, areaX, areaY, blobAreas, blobNum, thresholdImg);
            stroke(255, 255, 255);
            noFill();
            rect(squareDimensions[2] * areaDimension / 2, squareDimensions[3] * areaDimension / 2, ((squareDimensions[2] + squareDimensions[0]) * areaDimension) / 2, ((squareDimensions[3] + squareDimensions[1]) * areaDimension) / 2);
            int averageX = (squareDimensions[1] + squareDimensions[3]) / 2;
            int averageY = (squareDimensions[0] + squareDimensions[2]) / 2;
            fill(255, 255, 255);
            ellipse(averageX * areaDimension - 15, averageY * areaDimension - 15, 30, 30);
            audience.add(new AudienceMember(averageX * areaDimension, averageY * areaDimension));
            blobNum++;
          }
        }
      }
      
      // RUN EDGE DETECTION
      // Create an opaque image of the same size as the original
      PImage edgeImg = createImage(compared.width, compared.height, RGB);
      // Loop through every pixel in the image.
      for (int y = 1; y < compared.height-1; y++) { // Skip top and bottom edges
        for (int x = 1; x < compared.width-1; x++) { // Skip left and right edges
          float sum = 0; // Kernel sum for this pixel
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              // Calculate the adjacent pixel for this kernel point
              int pos = (y + ky)*compared.width + (x + kx);
              // Image is grayscale, red/green/blue are identical
              float val = red(compared.pixels[pos]);
              // Multiply adjacent pixels based on the kernel values
              sum += kernel[ky+1][kx+1] * val;
            }
          }
          // For this pixel in the new image, set the gray value
          // based on the sum from the kernel
          edgeImg.pixels[y*compared.width + x] = color(sum, sum, sum);
        }
      }
      // State that there are changes to edgeImg.pixels[]
      edgeImg.updatePixels();
      
      image(compared, 640, 0, 640, 360);
      image(edgeImg, 0, 360, 640, 360);
      image(thresholdImg, 640, 360, 640, 360);
    }
  }
  
  public void captureEvent(Capture c) {
    c.read();
  }
  
  
  
  int getIndexFromXY(int x, int y, int width, int height) {
    return (y * width) + x;
  }
  int[] getXYFromIndex(int index, int width, int height) {
    int result[] = new int[2];
    result[1] = floor(index / width);
    result[0] = index - result[1];
    return result;
  }
  
  int[] recursiveBlobCheck(int maxX, int maxY, int minX, int minY, int curX, int curY, int[][] blobs, int blobNum, PImage thresholdImg) {
    if (curX > blobs.length - 1 ||
        curX < 0 ||
        curY > blobs[curX].length - 1 ||
        curY < 0 ||
        blobs[curX][curY] != 0 ||
        thresholdImg.pixels[getIndexFromXY(curX * areaDimension, curY * areaDimension, myMovie.width, myMovie.height)] <= 0x00000) {
        int[] baseReturn = {maxX, maxY, minX, minY};
      return baseReturn;
    }
    
    blobs[curX][curY] = blobNum;
    
    int[] returnedT = recursiveBlobCheck(maxX, maxY, minX, minY, curX - 1, curY, blobs, blobNum, thresholdImg);
    int[] returnedR = recursiveBlobCheck(maxX, maxY, minX, minY, curX, curY + 1, blobs, blobNum, thresholdImg);
    int[] returnedB = recursiveBlobCheck(maxX, maxY, minX, minY, curX + 1, curY, blobs, blobNum, thresholdImg);
    int[] returnedL = recursiveBlobCheck(maxX, maxY, minX, minY, curX, curY - 1, blobs, blobNum, thresholdImg);
    
    int[] answer = {
      max(new int[]{maxX, curX, returnedT[0], returnedR[0], returnedL[0], returnedB[0]}), // top
      max(new int[]{maxY, curY, returnedT[1], returnedR[1], returnedL[1], returnedB[1]}), // right
      min(new int[]{minX, curX, returnedT[2], returnedR[2], returnedL[2], returnedB[2]}), // bottom
      min(new int[]{minY, curY, returnedT[3], returnedR[3], returnedL[3], returnedB[3]}) // left
    };
    return answer;
  }
  
  void keyPressed() {
    //For selction of colors to track
    //uses QWERTY keys
    myMovie.loadPixels();
    baseImg.loadPixels();
    if (key == '1') {
      for (int x = 0; x < baseImg.width; x++) {
        for (int y = 0; y < baseImg.height; y++) {
          baseImg.set(x, y, myMovie.get(x, y));
        }
      } 
    }
    baseImg.updatePixels();
  }
}