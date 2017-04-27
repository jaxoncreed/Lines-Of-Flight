String CAMERA_NAME = "USB_Camera #2,size=240x135,fps=15";
 
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
  PApplet.runSketch(new String[] {settingState.getClass().getSimpleName()}, settingState);
  
  PApplet.runSketch(new String[] {dancerState.getClass().getSimpleName()}, dancerState);
  PApplet.runSketch(new String[] {visualization.getClass().getSimpleName()}, visualization);
}