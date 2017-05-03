public class VisStage1 extends VisStage {

  public VisStage1(Visualization parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    parent.background(173, 183, 247); //lavendar color for phaseI
    danLayer.beginDraw();
    danLayer.background(173, 183, 247, 150); //clears what was on dancer layer before
    danLayer.endDraw();
    parent.image(audLayer, 0, 0); //draw audience layer behind
    parent.image(danLayer, 0, 0); //draw dancer layer in front
  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    for (Dancer dancer : dancerState.dancers) {
      //drawFannedLines(dancer, dancerState.dancers);
      drawCurves(dancer);
    }
  }
  
  void drawFannedLines(Dancer dancer, Dancer[] dancers) {
    danLayer.beginDraw();
    danLayer.stroke(dancer.c); //This isn't registering also, only draws black lines
    danLayer.strokeWeight(2);
    parent.line(parent.getScreenAdustedX(dancer.old_position.x),
        parent.getScreenAdustedY(dancer.old_position.y),
        parent.getScreenAdustedX(dancer.position.x),
        parent.getScreenAdustedY(dancer.position.y));
    danLayer.endDraw();
    
    if(millis() - m >= 1000) { //updates dancer's position every 1 second (1000 ms)
      for(Dancer d : dancers) {
        d.old_position.set(d.position.x, d.position.y);
        m = millis();
      }
    }
  }
  
  void drawCurves(Dancer d) {
    d.PX = parent.getScreenAdustedX(d.position.x);
    d.PY = parent.getScreenAdustedY(d.position.y);
    dragSegment(0, d.PX, d.PY, d);
    for(int i = 0; i < d.points.length - 2; i++) {
      dragSegment(i + 1, parent.getScreenAdustedX(d.points[i][0]),
        parent.getScreenAdustedY(d.points[i][1]), d);
    }
  }
  
  void dragSegment(int i, float xidx, float yidx, Dancer d) {
    float dx = xidx - d.points[i][0];
    float dy = yidx - d.points[i][1];
    float angle = atan2(dy, dx);  
    d.points[i][0] = xidx - cos(angle) * d.segLength;
    d.points[i][1] = yidx - sin(angle) * d.segLength;
    segment(d.points[i][0], d.points[i][1], angle, d, i);
  }
  
  void segment(float x, float y, float a, Dancer d, int i) {
    danLayer.beginDraw();
    danLayer.strokeWeight(1);
    danLayer.stroke(d.c);
    danLayer.pushMatrix();
    danLayer.translate(x, y); //I don't think the line is translating
    danLayer.rotate(a); //or rotating properly
    parent.line(parent.getScreenAdustedX(d.position.x), parent.getScreenAdustedY(d.position.y),
      parent.getScreenAdustedX(d.segLength), 0); 
    danLayer.popMatrix();
    danLayer.endDraw();
  }
  
}