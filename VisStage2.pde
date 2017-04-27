public class VisStage2 extends VisStage {
  
  public VisStage2(PApplet parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    parent.background(250, 43, 47); //blood orange color for phase II
  }
  

  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    Dancer d1 = dancerState.dancers[0];
    Dancer d2 = dancerState.dancers[1];
    Dancer d3 = dancerState.dancers[2];
    
    parent.smooth();
    
    drawFur(dancerState.dancers);
    parent.stroke(d1.c);
    parent.strokeWeight(2);
    parent.line(d1.old_position.x, d1.old_position.y, d1.position.x, d1.position.y);
      
    parent.stroke(d2.c);
    parent.strokeWeight(2);
    parent.line(d2.old_position.x, d2.old_position.y, d2.position.x, d2.position.y);
      
    parent.stroke(d3.c);
    parent.strokeWeight(2);
    parent.line(d3.old_position.x, d3.old_position.y, d3.position.x, d3.position.y);
  }
}

void drawFur(Dancer[] arg) {
  float dx;
  float dy;
  float d;
  
  for(int j = 0; j < 3; j++) {
    Dancer dancer = arg[j];
    
    dancer.points[dancer.count][0] = dancer.position.x;
    dancer.points[dancer.count][1] = dancer.position.y;
  
    strokeWeight(1);
    stroke(dancer.c);

    line(dancer.old_position.x, dancer.old_position.y, dancer.position.x, dancer.position.y);
  
    for (int i = 0; i < dancer.points.length; i++) {
        dx = dancer.points[i][0] - dancer.points[dancer.count][0];
        dy = dancer.points[i][1] - dancer.points[dancer.count][1];
        d = dx * dx + dy * dy;
  
        if (d < 2000 && Math.random() > d / 2000) { //larger numbers make thicker fur
            line(dancer.old_position.x + (dx * 0.5), dancer.old_position.y + (dy * 0.5),
              dancer.position.x - (dx * 0.5), dancer.position.y - (dy * 0.5));
        }
    }
  
    //wrap inputs around in the array to not get null pointer exceptions
    dancer.count = (dancer.count + 1) % 50;
  }
}