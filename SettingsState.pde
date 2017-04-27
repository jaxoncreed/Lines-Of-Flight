
class SettingState extends State {
  public int stage = 0;
  
  SettingState() {
    
  }
  
  void addVariable(String name, Object defaultValue) {
    
  }
  
  Object getVariable(String name) {
    return new Object();
  }
 
  public void settings() {
    size(200, 100);
  }
  
  public void draw() {
    background(255);
    fill(0);
    ellipse(100, 50, 10, 10);
  }
  
  void keyPressed() {
    if (key == '1' || key == '2' || key == '3' || key == '0') {
      this.stage = Integer.parseInt(Character.toString(key));
    }
  }
  
}