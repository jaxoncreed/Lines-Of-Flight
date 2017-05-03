/*
All three stages of the dance visualization with audience added
Dancers and audience members are drawn on different layers, or PGraphics

The audience layer is drawn on the bottom and the dancer layer is drawn on top
The audience layer has an opaque bg color, dancer layer has a translucent bg color
This is necessary to capture the full color of the dancer's lines bc they are not opaque
*/

ArrayList<Dancer> dancers = new ArrayList();
ArrayList<AudienceMember> audience = new ArrayList();

float dx;
float dy;
float d;

int m = millis();
PGraphics bgLayer;
PGraphics audLayer;
PGraphics danLayer;

int r1;
int rd;

void setup() {
  size(1000, 500);
  r1 = 173;
  rd = 1;

  audLayer = createGraphics(1000, 500);
  danLayer = createGraphics(1000, 500);
  bgLayer = createGraphics(1000, 500);
  danLayer.beginDraw();
  danLayer.background(173, 183, 247, 175); //important!!! covers up weird gray bg color in dancer layer
  danLayer.endDraw();
  
  for(int i = 0; i < 3; i++) {
    dancers.add(0, new Dancer(255, 200, color(255, 255, 255, 15))); //white
    dancers.add(1, new Dancer(255 + 300, 200, color(7, 11, 76, 15))); //dark purple
    dancers.add(2, new Dancer(255 + (300 * i), 200, color(148, 18, 96, 15))); //pink
  }
  
  for(int k = 0; k < 20; k++) {
    audience.add(new AudienceMember(random(100, 900), random(100, 400)));
  }
  
}

void draw() {
  for(int i = 0; i < 3; i++) {
    Dancer dancer = dancers.get(i);
    dancer.move();
    
    if(dancer.phase == 1) {
      r1 = r1 + rd; //make the background color change gradually back and forth
      if(r1 > 240 || r1 < 140) {
        rd = -rd;
      }
      
      //drawBgEffects();
      drawAudience(color(r1, 183, 247));
      //drawFannedLines(dancer);
      drawCurves(dancer);
      image(bgLayer, 0, 0);
      image(audLayer, 0, 0); //draw audience layer behind
      image(danLayer, 0, 0); //draw dancer layer in front
      
    } if(dancer.phase == 2) {      
      drawAudience(color(250, 43, 47));
      drawFur(dancer);
      image(audLayer, 0, 0);
      image(danLayer, 0, 0);
      
    } if(dancer.phase == 3) {
      drawAudience(color(84, 172, 174));
      drawWeb(dancer);
      image(audLayer, 0, 0);
      image(danLayer, 0, 0);
    }
  }
  
}

void keyPressed() {
  for(int i = 0; i < dancers.size(); i++) {
    Dancer d = dancers.get(i);
    
    //pressing these keys will also clear the visualization in that phase
    if(key == '1') { //PHASE I
      d.phase = 1;

      danLayer.beginDraw();
      danLayer.background(173, 183, 247, 150); //clears what was on dancer layer before
      danLayer.endDraw();
      
    } else if(key == '2') { //PHASE II
      d.phase = 2;
      
      d.count = 0;
      danLayer.beginDraw();
      danLayer.background(250, 43, 47, 150);
      danLayer.endDraw();
      
    } else if(key == '3') { //PHASE III
      d.phase = 3;
      
      danLayer.beginDraw();
      danLayer.background(84, 172, 174, 175);
      danLayer.endDraw();
    }
  }
}

void drawAudience(color c) {
    audLayer.beginDraw();
    audLayer.background(c, 100); //this line is very important!!! it clears away audience residue
    for(int n = 0; n < audience.size(); n++) {
        AudienceMember a = audience.get(n);
        audLayer.noStroke();
        audLayer.fill(7, 11, 76); //fill with full dancer color, not less opaque color
        audLayer.ellipse(a.x, a.y, 8, 8); //draw audience member in current position
        a.move();
    }
    audLayer.endDraw();
}

/*
draws lines from the dancer's old x and y positions, which update every second,
creating movement in fanned lines.
line technique for PHASE I
*/
void drawFannedLines(Dancer dancer) {
  danLayer.beginDraw();
  danLayer.stroke(dancer.c);
  danLayer.strokeWeight(2);
  danLayer.line(dancer.oldx, dancer.oldy, dancer.x, dancer.y);
  danLayer.endDraw();
  
  if(millis() - m >= 1000) { //updates dancer's position every 1 second (1000 ms)
    for(int i = 0; i < dancers.size(); i++) {
      Dancer d = dancers.get(i);
      d.oldx = d.x;
      d.oldy = d.y;
      m = millis();
    }
  }
}

void drawCurves(Dancer d) {
  danLayer.beginDraw();
  danLayer.stroke(d.c);
  danLayer.endDraw();
  d.PX = d.x;
  d.PY = d.y;
  dragSegment(0, d.PX, d.PY, d);
  
  for(int i = 0; i < d.points.length - 1; i++) {
      dragSegment(i+1, d.points[i][0], d.points[i][1], d);
  }
}
  
void dragSegment(int i, float xidx, float yidx, Dancer d) {
  float dx = xidx - d.points[i][0];
  float dy = yidx - d.points[i][1];
  float angle = atan2(dy, dx);
  d.points[i][0] = xidx - cos(angle) * d.segLength;
  d.points[i][1] = yidx - sin(angle) * d.segLength;
  segment(d.points[i][0], d.points[i][1], angle, d);
}

void segment(float x, float y, float a, Dancer d) {
  danLayer.beginDraw();
  danLayer.strokeWeight(1);
  danLayer.stroke(d.c);
  danLayer.pushMatrix();
  danLayer.translate(x, y);
  danLayer.rotate(a);
  danLayer.line(0, 0, d.segLength, 0); //put in d.x and d.y instead of 0 for tons of cool lines
  danLayer.popMatrix();
  danLayer.endDraw();
}

//draws background effects on the bottom-most layer of the vis
void drawBgEffects() { 
  bgLayer.beginDraw();
  bgLayer.fill(148, 18, 96, 100);
  bgLayer.noStroke();
  bgLayer.ellipse(random(0, 1000), random(0, 500), 50, 50);
  bgLayer.endDraw();
}

/*
draws lines with furry texture from the dancer's old x and y positions,
which are updated constantly, not every second like in phase I
line technique for PHASE II
*/
void drawFur(Dancer dancer) {  
    dancer.points[dancer.count][0] = dancer.x;
    dancer.points[dancer.count][1] = dancer.y;
    
    danLayer.beginDraw();
    danLayer.strokeWeight(1);
    danLayer.stroke(dancer.c);
    danLayer.line(dancer.oldx, dancer.oldy, dancer.x, dancer.y);
  
    for (int i = 0; i < dancer.points.length; i++) {
        dx = dancer.points[i][0] - dancer.points[dancer.count][0];
        dy = dancer.points[i][1] - dancer.points[dancer.count][1];
        d = dx * dx + dy * dy;
  
        if (d < 1000 && Math.random() > d / 1000) { //larger numbers make thicker fur
            danLayer.line(dancer.oldx + (dx * 0.5), dancer.oldy + (dy * 0.5),
              dancer.x - (dx * 0.5), dancer.y - (dy * 0.5));
        }
    }
    danLayer.endDraw();
  
    //wrap inputs around in the array to not get null pointer exceptions
    dancer.count = (dancer.count + 1) % dancer.points.length;
    
    dancer.oldx = dancer.x; //update dancer's old x and y values constantly
    dancer.oldy = dancer.y;
}

/*
draws webbed lines between overlapping lines created by the dancer's movement
line technique for PHASE III
*/
void drawWeb(Dancer dancer) {
  dancer.points[dancer.count][0] = dancer.x;
  dancer.points[dancer.count][1] = dancer.y;
  
  danLayer.beginDraw();
  danLayer.stroke(dancer.c);
  danLayer.strokeWeight(2);
  danLayer.line(dancer.oldx, dancer.oldy, dancer.x, dancer.y);
  
  for(int j = 0; j < dancer.points.length; j++) {
    dx = dancer.points[j][0] - dancer.points[dancer.count][0];
    dy = dancer.points[j][1] - dancer.points[dancer.count][1];
    d = dx * dx + dy * dy;
    
    //d < 2500 and Math.random() > 0.9 are original values
    //bigger number > d makes thicker webs
    //wider threshold (smaller decimal) for random values makes webs more saturated
    if (d < 1500 && Math.random() > 0.75) {
      danLayer.line(dancer.points[dancer.count][0], dancer.points[dancer.count][1],
        dancer.points[j][0], dancer.points[j][1]);
    }
  }
  danLayer.endDraw();
  
  dancer.count = (dancer.count + 1) % dancer.points.length;
  dancer.oldx = dancer.x;
  dancer.oldy = dancer.y;
}