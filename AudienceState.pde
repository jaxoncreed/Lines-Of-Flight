class AudienceState extends State {
  SettingState settingState;
  
  // All this is kinda messy
  Movie myMovie;
  PImage baseImg;
  PImage compared;
  int frameNum = 0;
  int areaDimension = 16;
  // Kernel for edge detection
  float[][] kernel = {{ -3, -3, -3}, 
                      { -3,  23, -3}, 
                      { -3, -3, -3}};
  int THRESHOLD = 0xDDDDDD;
  
  public int width = 0;
  public int height = 0;
  
  AudienceState(SettingState settingState) {
    this.settingState = settingState;
  }
 
  public void settings() {
    size(200, 100);
  }
  
  public void draw() {
    background(255);
    fill(0);
    ellipse(100, 50, 10, 10);
  }
  
}