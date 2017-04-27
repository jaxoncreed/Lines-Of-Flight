/*import processing.video.*;
Movie myMovie;
PImage baseImg;
PImage compared;
int frameNum = 0;

void setup() {
  size(640, 720);
  baseImg = loadImage("videoBase.png");
  baseImg.loadPixels();
  myMovie = new Movie(this, "video.m4v");
  myMovie.loop();
}

void draw() {
  if (frameNum % 2 == 0) {
    myMovie.loadPixels();
    //if (compared == null) {
    //  compared = createImage(myMovie.width, myMovie.height, RGB);
    //}
    compared = createImage(myMovie.width, myMovie.height, RGB);
    for (int i = 0; i < myMovie.width * myMovie.height; i++) {
      color currColor = myMovie.pixels[i];
      color bkgdColor = baseImg.pixels[i];
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
      // Add these differences to the running tally
      // presenceSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      //pixels[i] = color(diffR, diffG, diffB);
      // The following line does the same thing much faster, but is more technical
      int normalized = (diffR + diffG + diffB) / 3;
      compared.pixels[i] = color(normalized, normalized, normalized);
    }
    compared.updatePixels();
    image(compared, 0, 360, 640, 360);
  }
  image(myMovie, 0, 0, 640, 360);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  frameNum++;
}*/


// THIS ONE GROUPS BY AREA WITH AND ADJUSTABLE PIXEL SIZE

import processing.video.*;


Movie myMovie;
PImage baseImg;
PImage compared;
int frameNum = 0;
int areaDimension = 16;
// Kernel for edge detection
float[][] kernel = {{ -3, -3, -3},
                    { -3,  23, -3},
                    { -3, -3, -3}};
int THRESHOLD = 0xDDDDDD;


void setup() {
  size(1280, 720);
  baseImg = loadImage("videoBase.png");
  baseImg.loadPixels();
  myMovie = new Movie(this, "video.m4v");
  myMovie.loop();
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
    max(new int[]{maxX, curX, returnedT[0], returnedR[0], returnedL[0], returnedB[0]}),
    max(new int[]{maxY, curY, returnedT[1], returnedR[1], returnedL[1], returnedB[1]}),
    min(new int[]{minX, curX, returnedT[2], returnedR[2], returnedL[2], returnedB[2]}),
    min(new int[]{minY, curY, returnedT[3], returnedR[3], returnedL[3], returnedB[3]})
  };
  return answer;
}

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
      if (compared.pixels[i] * -1 < THRESHOLD) {
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

    for (int areaX = 0; areaX < areasWidth; areaX++) {
      for (int areaY = 0; areaY < areasHeight; areaY++) {
        if (blobAreas[areaX][areaY] == 0 && thresholdImg.pixels[getIndexFromXY(areaX * areaDimension, areaY * areaDimension, myMovie.width, myMovie.height)] > 0x00000) {
          int[] squareDimensions = recursiveBlobCheck(areaX, areaY, areaX, areaY, areaX, areaY, blobAreas, blobNum, thresholdImg);
          rect(squareDimensions[2] * areaDimension / 2, squareDimensions[3] * areaDimension / 2, ((squareDimensions[2] + squareDimensions[0]) * areaDimension) / 2, ((squareDimensions[3] + squareDimensions[1]) * areaDimension) / 2);
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

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  frameNum++;
}