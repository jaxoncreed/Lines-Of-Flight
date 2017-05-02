
class Visualization extends PApplet {
  private ArrayList<VisStage> stages;
  private SettingState settingState;
  private AudienceState audienceState;
  private DancerState dancerState;
  private int currentStage = -1;
  
  Visualization(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    this.settingState = settingState;
    this.audienceState = audienceState;
    this.dancerState = dancerState;
    
    this.stages = new ArrayList<VisStage>();
    stages.add(new VisStage0(this));
    stages.add(new VisStage1(this));
    stages.add(new VisStage2(this));
    stages.add(new VisStage3(this));
  }
  
  public void settings() {
    fullScreen(1);
  }
  
  public void setup() {
    frameRate(40);
  }
  
  public void draw() {
    if (this.settingState.stage != this.currentStage) {
      this.stages.get(this.settingState.stage).init();
      this.currentStage = this.settingState.stage;
    }
    this.stages.get(this.settingState.stage).display(this.settingState, this.audienceState, this.dancerState);
  }
  
  public int getScreenAdustedX(int x) {
    if (this.width / this.height > vidWidth / vidHeight) {
      // constrained by height
      return (this.height / vidHeight) * x + (this.width - ((this.height / vidHeight) * x)) / 2;
    } else {
      // constrained by width
      return (this.width / vidWidth) * x;
    }
  }
  public int getScreenAdustedX(float x) {
    return this.getScreenAdustedX((int) x);
  }
  public int getScreenAdustedY(int y) {
    if (this.width / this.height > vidWidth / vidHeight) {
      // constrained by height
      return (this.height / vidHeight) * y;
    } else {
      // constrained by width
      return (this.width / vidWidth) * y + (this.width - ((this.width / vidWidth) * y)) / 2;
    }
  }
  public int getScreenAdustedY(float x) {
    return this.getScreenAdustedY((int) x);
  }
}