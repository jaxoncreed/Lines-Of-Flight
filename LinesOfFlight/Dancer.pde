import gab.opencv.OpenCV;

class Dancer {
  
  public PVector position; //original position (x,y,z)
  public PVector old_position; //old position of dancer
  
  public color c;
  
  //currently not in use
  float speed;
  float velocity;
  float acceleration;
  //or coudld be PVectors???
  PVector spe;
  PVector vel;
  PVector acc;
  
  //
  float[][] points;
  int count;
  
  //variables for the wispy curves in phase I
  float PY;
  float PX;
  int segLength;
  
  Dancer(color col) {
    //current starting Position is 0,0 CHANGE THIS TO BE REAL DANCERS STARTING POSITION
    this.position = new PVector(255 + 300, 200, 0);
    this.old_position = position;
    this.speed = 0.0; 
    this.points = new float[25][2];
    this.c = col;
    this.segLength = 5;
  } 
  
  Dancer (PVector pos) {
    this.position = pos;
    this.old_position = position;
  }
  
  void updatePosition(PVector new_pos) {
    old_position = position; //update old pos to be previous position
    position = new_pos; //change position to new position
  }
}