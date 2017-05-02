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
      drawFannedLines(dancer, dancerState.dancers);
    }
  }
  
  void drawFannedLines(Dancer dancer, Dancer[] dancers) {
    danLayer.beginDraw();
    danLayer.stroke(dancer.c);
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
}