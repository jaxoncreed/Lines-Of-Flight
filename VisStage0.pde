public class VisStage0 extends VisStage {
  
  public VisStage0(PApplet parentApplet) {
    super(parentApplet); 
  }
  
  @Override
  public void init() {
    parent.background(0);
  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    parent.textSize(32);
    parent.fill(255, 255, 255);
    String message = "Lines of Flight";
    parent.text(message, (parent.width / 2) - (textWidth(message) / 2), (parent.height / 2) - 16); 
  }
}