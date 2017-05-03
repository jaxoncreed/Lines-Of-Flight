String CAMERA_NAME = "name=FaceTime HD Camera,size=320x180,fps=30";
int vidWidth = 640; //320
int vidHeight = 426; //180

int m = millis();
 
/**
 * Set Up 
 */
void setup() {
  // Print Possible Cameras
  String[] cameras = Capture.list();
  println("Available cameras:");
  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }
  
  // Initiailization
  SettingState settingState = new SettingState();
  AudienceState audienceState = new AudienceState(settingState);
  DancerState dancerState = new DancerState(settingState);
  Visualization visualization = new Visualization(settingState, audienceState, dancerState);
  
  // Run Windows
  PApplet.runSketch(new String[] {audienceState.getClass().getSimpleName()}, audienceState);
  PApplet.runSketch(new String[] {dancerState.getClass().getSimpleName()}, dancerState);
  PApplet.runSketch(new String[] {visualization.getClass().getSimpleName()}, visualization);
  PApplet.runSketch(new String[] {settingState.getClass().getSimpleName()}, settingState);
}