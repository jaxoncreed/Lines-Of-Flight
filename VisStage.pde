
public abstract class VisStage {
  protected Visualization parent;
  PGraphics audLayer;
  PGraphics danLayer;
  int jumpRange = 30;
  
  public VisStage(Visualization parentApplet) {
    this.parent = parentApplet;
    audLayer = createGraphics(parent.width, parent.height);
    danLayer = createGraphics(parent.width, parent.height);
    danLayer.beginDraw();
    danLayer.background(173, 183, 247, 175); //important!!! covers up weird gray bg color in dancer layer
    danLayer.endDraw();
  }
  
  public abstract void init();
  
  public abstract void display(SettingState settingState, AudienceState audienceState, DancerState dancerState);
  
  void drawAudience(color c, AudienceState audienceState) {
    audLayer.beginDraw();
    audLayer.background(c); //this line is very important!!! it clears away audience residue
    int cR = (c >> 16) & 0xFF;
    int cG = (c >> 8) & 0xFF;
    int cB = c & 0xFF;
    PImage densityImage = new PImage(vidWidth, vidHeight);
    for (int areaX = 0; areaX < audienceState.densityMatrix.length; areaX++) {
      for (int areaY = 0; areaY < audienceState.densityMatrix[0].length; areaY++) {
        float densityPercent = audienceState.densityMatrix[areaX][areaY];
        int adjustedR = round(cR + ((0xFF - cR) * densityPercent));
        int adjustedG = round(cG + ((0xFF - cG) * densityPercent));
        int adjustedB = round(cB + ((0xFF - cB) * densityPercent));
        int areaColor = color(adjustedR, adjustedG, adjustedB);
        for (int y = areaY * audienceState.areaDimension; y < (areaY * audienceState.areaDimension) + audienceState.areaDimension; y++) {
          for (int x = areaX * audienceState.areaDimension; x < (areaX * audienceState.areaDimension) + audienceState.areaDimension; x++) {
            densityImage.pixels[getIndexFromXY(x, y, vidWidth, vidHeight)] = areaColor;
          }
        }
      }
    }
    audLayer.image(densityImage, parent.getScreenAdustedX(0), parent.getScreenAdustedX(0), (parent.getScreenAdustedX(vidWidth) - parent.getScreenAdustedX(0)), (parent.getScreenAdustedY(vidHeight) - parent.getScreenAdustedY(0)));
    for(int n = 0; n < audienceState.audience.size(); n++) {
        AudienceMember a = audienceState.audience.get(n);
        audLayer.noStroke();
        audLayer.fill(7, 11, 76); //fill with full dancer color, not less opaque color
        audLayer.ellipse(a.position.x, a.position.y, 8, 8); //draw audience member in current position
    }
    audLayer.endDraw();
  }
  
  void drawAudience(color c, AudienceState audienceState, Dancer[] dancers) {
    int cR = (c >> 16) & 0xFF;
    int cG = (c >> 8) & 0xFF;
    int cB = c & 0xFF;
    audLayer.beginDraw();
    audLayer.background(c); //this line is very important!!! it clears away audience residue
    for(int n = 0; n < audienceState.audience.size(); n++) {
      AudienceMember a = audienceState.audience.get(n);
      //compare proximity with d1
      float d1_dist_compare = dist(a.position.x, a.position.x, dancers[0].position.x, dancers[0].position.y);
      //println(d1_dist_compare);
      if ( d1_dist_compare <= 10 ) {
        audLayer.noStroke();
        audLayer.fill(dancers[0].c);
        audLayer.ellipse(300, 560, 50, 50);
      //else draw audience normally
      } else {
        audLayer.noStroke();
        audLayer.fill(7, 11, 76); //fill with full dancer color, not less opaque color
        audLayer.ellipse(a.position.x, a.position.y, 8, 8); //draw audience member in current position
      }
    }//end for
    audLayer.endDraw();
  }
  
}