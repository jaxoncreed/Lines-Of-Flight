class AudienceMember {
  public PVector old_position;
  public PVector position;
  public color c;
  
  AudienceMember(float x, float y) {
    this.position.x = x;
    this.position.y = y;
    this.c = color(0, 255, 0);
  }
  
  void move() {
    this.old_position.x = this.position.x;
    this.old_position.y = this.position.y;
    this.position.x = this.position.x + random(-10, 10);
    this.position.y = this.position.y + random(-10, 10);
  }
}