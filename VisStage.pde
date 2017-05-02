
public abstract class VisStage {
  protected Visualization parent;
  
  public VisStage(Visualization parentApplet) {
    this.parent = parentApplet;
  }
  
  public abstract void init();
  
  public abstract void display(SettingState settingState, AudienceState audienceState, DancerState dancerState);
  
}