public class VisStage3 extends VisStage {
  
  public VisStage3(PApplet parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    parent.background(84, 172, 174);
  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    //parent.noStroke();
    //parent.fill(0,0,255);
    //parent.ellipse(p.x, p.y, 50, 50);
  }
}