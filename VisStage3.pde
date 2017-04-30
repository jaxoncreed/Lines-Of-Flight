public class VisStage3 extends VisStage {
  
  public VisStage3(Visualization parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    parent.background(84, 172, 174);
  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    for (Dancer dancer : dancerState.dancers) {
      drawWeb(dancer);
    }
  }
  
  void drawWeb(Dancer dancer) {
    parent.stroke(dancer.c);
    dancer.points[dancer.count][0] = dancer.position.x;
    dancer.points[dancer.count][1] = dancer.position.y;
    parent.line(parent.getScreenAdustedX(dancer.old_position.x),
        parent.getScreenAdustedY(dancer.old_position.y),
        parent.getScreenAdustedX(dancer.position.x),
        parent.getScreenAdustedY(dancer.position.y));
    
    for(int j = 0; j < dancer.points.length; j++) {
      float dx = dancer.points[j][0] - dancer.points[dancer.count][0];
      float dy = dancer.points[j][1] - dancer.points[dancer.count][1];
      float d = dx * dx + dy * dy;
      
      //d < 2500 and Math.random() > 0.9 are original values
      //bigger number > d makes thicker webs
      //wider threshold (smaller decimal) for random values makes webs more saturated
      if (d < 1500 && Math.random() > 0.75) {
        parent.line(parent.getScreenAdustedX(dancer.points[dancer.count][0]),
            parent.getScreenAdustedY(dancer.points[dancer.count][1]),
            parent.getScreenAdustedX(dancer.points[j][0]),
            parent.getScreenAdustedY(dancer.points[j][1]));
      }
    }
    
    dancer.count = (dancer.count + 1) % 50;
    dancer.old_position.x = dancer.position.x;
    dancer.old_position.y = dancer.position.y;
  }
}