class Dancer {
  float x;
  float y;
  float oldx;
  float oldy;
  color c;
  float[][] points;
  int count;
  int phase;

  Dancer() {
    this(225, 200, color(74, 1, 68, 50));
  }
  
  Dancer(int x, int y, color c) {
    this.x = x;
    this.y = y;
    oldx = x;
    oldy = y;
    this.c = c;
    
    this.phase = 1;
    this.points = new float[50][2];
  }
  
  void move() {
    //oldx = x;
    //oldy = y;
    x = x + random(-10, 10);
    y = y + random(-10, 10);
  }
}