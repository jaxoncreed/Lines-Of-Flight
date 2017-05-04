public class VisStage3 extends VisStage {
  
  public VisStage3(Visualization parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    parent.background(84, 172, 174);
    danLayer.beginDraw();
    danLayer.background(84, 172, 174, 175);
    danLayer.endDraw();

  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    if (dancerState.d1_dist_jump < jumpRange && dancerState.d2_dist_jump < jumpRange && dancerState.d3_dist_jump < jumpRange) {
      for (Dancer dancer : dancerState.dancers) {
        drawWeb(dancer);
      }
      this.drawAudience(color(84, 172, 174), audienceState.audience);
      parent.image(audLayer, 0, 0); //draw audience layer behind
      parent.image(danLayer, 0, 0); //draw dancer layer in front
    }
  }
  
  void drawWeb(Dancer dancer) {
    danLayer.beginDraw();
    danLayer.stroke(dancer.c);
    danLayer.strokeWeight(2);
    dancer.points[dancer.count][0] = dancer.position.x;
    dancer.points[dancer.count][1] = dancer.position.y;
    danLayer.line(parent.getScreenAdustedX(dancer.old_position.x),
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
        danLayer.line(parent.getScreenAdustedX(dancer.points[dancer.count][0]),
            parent.getScreenAdustedY(dancer.points[dancer.count][1]),
            parent.getScreenAdustedX(dancer.points[j][0]),
            parent.getScreenAdustedY(dancer.points[j][1]));
      }
    }
    danLayer.endDraw();
    
    dancer.count = (dancer.count + 1) % 50;
    dancer.old_position.x = dancer.position.x;
    dancer.old_position.y = dancer.position.y;
  }
}