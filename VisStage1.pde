public class VisStage1 extends VisStage {

  
  public VisStage1(PApplet parentApplet) {
    super(parentApplet);
  }
  
  @Override
  public void init() {
    print ("initing");
    parent.background(173, 183, 247); //lavendar color for phaseI
  }
  
  @Override
  public void display(SettingState settingState, AudienceState audienceState, DancerState dancerState) {
    drawWeb(dancerState.dancers, this.parent);
    // parent.noStroke();
    // parent.fill(255,0,0);
    // parent.ellipse(p.x, p.y, 50, 50);
  }
}

void drawWeb(Dancer[] arg, PApplet canvas) {
  float dx;
  float dy;
  float d;
  for(int i = 0; i < 3; i++) {
    Dancer dancer = arg[i];

    dancer.points[dancer.count][0] = dancer.position.x; //mouseX for mouse control of lines
    dancer.points[dancer.count][1] = dancer.position.y; //mouseY
    
    canvas.strokeWeight(1);
    canvas.stroke(dancer.c);
    canvas.line(dancer.old_position.x, dancer.old_position.y, dancer.position.x, dancer.position.y);

    for(int j = 0; j < dancer.points.length; j++) {
      dx = dancer.points[j][0] - dancer.points[dancer.count][0];
      dy = dancer.points[j][1] - dancer.points[dancer.count][1];
      d = dx * dx + dy * dy;
      
      //d < 2500 and Math.random() > 0.9 are original values
      //bigger number > d makes thicker webs
      //wider threshold (smaller decimal) for random values makes webs more saturated
      if (d < 1500 && Math.random() > 0.75) {
        canvas.line(dancer.points[dancer.count][0], dancer.points[dancer.count][1],
          dancer.points[j][0], dancer.points[j][1]);
      }
    }
    
    dancer.count = (dancer.count + 1) % 50;
    
    if(millis() - m >= 1000) {
      dancer.old_position.x = dancer.position.x;
      dancer.old_position.y = dancer.position.y;
      m = millis();
    }
  }
}