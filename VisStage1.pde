public class VisStage1 extends VisStage {

  
  public VisStage1(Visualization parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    print ("initing");
    parent.background(173, 183, 247); //lavendar color for phaseI
  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    for (Dancer dancer : dancerState.dancers) {
      drawFannedLines(dancer, dancerState.dancers);
    }
  }
  
  void drawFannedLines(Dancer dancer, Dancer[] dancers) {
    parent.stroke(dancer.c);
    parent.line(parent.getScreenAdustedX(dancer.old_position.x),
        parent.getScreenAdustedY(dancer.old_position.y),
        parent.getScreenAdustedX(dancer.position.x),
        parent.getScreenAdustedY(dancer.position.y));
    
    if(millis() - m >= 1000) { //updates dancer's position every 1 second (1000 ms)
      for(Dancer d : dancers) {
        d.old_position.set(d.position.x, d.position.y);
        m = millis();
      }
    }
  }
}