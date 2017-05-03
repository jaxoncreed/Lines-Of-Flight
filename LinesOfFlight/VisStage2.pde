public class VisStage2 extends VisStage {
  
  public VisStage2(Visualization parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    parent.background(250, 43, 47); //blood orange color for phase II
    danLayer.beginDraw();
    danLayer.background(250, 43, 47, 150);
    danLayer.endDraw();
  }
  

  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    for (Dancer dancer : dancerState.dancers) {
      drawFur(dancer);
    }
    this.drawAudience(color(250, 43, 47), audienceState.audience);
    parent.image(audLayer, 0, 0); //draw audience layer behind
    parent.image(danLayer, 0, 0); //draw dancer layer in front
  }
  
  void drawFur(Dancer dancer) {
    danLayer.beginDraw();
    danLayer.stroke(dancer.c);
    danLayer.strokeWeight(1);
    dancer.points[dancer.count][0] = dancer.position.x;
    dancer.points[dancer.count][1] = dancer.position.y;
    danLayer.line(parent.getScreenAdustedX(dancer.old_position.x),
        parent.getScreenAdustedY(dancer.old_position.y),
        parent.getScreenAdustedX(dancer.position.x),
        parent.getScreenAdustedY(dancer.position.y));
  
    for (int i = 0; i < dancer.points.length; i++) {
        float dx = dancer.points[i][0] - dancer.points[dancer.count][0];
        float dy = dancer.points[i][1] - dancer.points[dancer.count][1];
        float d = dx * dx + dy * dy;
  
        if (d < 1000 && Math.random() > d / 1000) { //larger numbers make thicker fur
            danLayer.line(parent.getScreenAdustedX(dancer.old_position.x + (dx * 0.5)),
                parent.getScreenAdustedY(dancer.old_position.y + (dy * 0.5)),
                parent.getScreenAdustedX(dancer.position.x - (dx * 0.5)),
                parent.getScreenAdustedY(dancer.position.y - (dy * 0.5)));
        }
    }
    danLayer.endDraw();
  
    //wrap inputs around in the array to not get null pointer exceptions
    dancer.count = (dancer.count + 1) % dancer.points.length;
    
    dancer.old_position.x = dancer.position.x; //update dancer's old x and y values constantly
    dancer.old_position.y = dancer.position.y;
  }
}