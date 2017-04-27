
public abstract class VisStage {
  protected PApplet parent;
  
  public VisStage(PApplet parentApplet) {
    this.parent = parentApplet;
  }
  
  public abstract void init();
  
  public abstract void display(SettingState settingState, AudienceState audienceState, DancerState dancerState);
  
  
}