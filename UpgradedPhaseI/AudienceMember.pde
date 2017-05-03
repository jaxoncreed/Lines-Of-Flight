class AudienceMember {
  float x;
  float y;
  float oldx;
  float oldy;
  color c;
  
  AudienceMember(float x, float y) {
    this.x = x;
    this.y = y;
    this.c = color(0, 255, 0);
  }
  
  void move() {
    oldx = x;
    oldy = y;
    x = x + random(-10, 10);
    y = y + random(-10, 10);
  }
  
  void display(color c) { 
    noStroke();
    fill(c); //the color of the background for that phase
    ellipse(this.oldx, this.oldy, 6, 6);
    fill(255);
    ellipse(this.x, this.y, 5, 5);
  }
}