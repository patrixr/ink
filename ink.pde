int MAX_RESISTANCE = 10;

class InkLine {

  PImage edges;
  PImage canvas;
  boolean ended;
  int x, y;
  int thickness;
  boolean atEdge;
  color outputColor;
  int resistance;
  int lastFrame;
  int framesSinceLastEdge;
  boolean spreading;
  ArrayList<PVector> spreadPoints;
  PVector[] spreadPattern = {
    new PVector(-1,-1), new PVector(0, -1), new PVector(1, -1),
    new PVector(-1, 0), new PVector(1, 0),
    new PVector(-1, 1), new PVector(0, 1), new PVector(1, 1)
  };

  InkLine(PImage edges, PImage canvas, int x) {
    this.x = x;
    this.y = 0;
    this.edges = edges;
    this.canvas = canvas;
    this.ended = false;
    this.thickness = int(random(1,4));
    this.atEdge = false;
    this.outputColor = BLACK;
    this.resistance = int(random(1, 3)); // up to 10
    this.lastFrame = frameCount;
    this.spreading = false;
    this.spreadPoints = new ArrayList<PVector>();
    this.framesSinceLastEdge = 0;
  }

  
  private void setPixel(int px, int py, color c) {
    canvas.pixels[py * canvas.width + px] = c;
  }
  
  private color getPixel(PImage img, int px, int py) {
    return img.pixels[py * img.width + px];
  }

  private color getPixel(PImage img, PVector pt) {
    return img.pixels[int(pt.y) * img.width + int(pt.x)];
  }

  private boolean pixelIsEmpty(PImage img, PVector pt) {
    return getPixel(img, pt) == WHITE;
  }
  
  private boolean pixelIsFilled(PImage img, PVector pt) {
    return getPixel(img, pt) != WHITE;
  }

  private boolean hasEnded() {
    return 
      ended 
      || red(outputColor) >= 250
      || resistance == MAX_RESISTANCE
      || y == canvas.height - 1 
      || thickness == 0;
  }

  private void end() {
    ended = true;
  }
  
  private boolean isOutOfBounds(PVector pt) {
    return (pt.x < 0 || pt.y < 0 || pt.x >= canvas.width || pt.y >= canvas.height); 
  }
  
  private void dimColor() {
    float r = red(outputColor);
    float g = green(outputColor);
    float b = blue(outputColor);
    
    r+= 5;
    g+= 5;
    b+= 5;
    
    outputColor = color(r,g,b);
  }
  
  void startSpread() {
    spreading = true;
    spreadPoints.clear();
    spreadPoints.add(new PVector(this.x, this.y));
  }
  
  void stopSpread() {
    println("stop spreading");
    spreading = false; 
    //dimColor();
  }
  
  void drawSpread() {
    ArrayList<PVector> nextPoints = new ArrayList<PVector>();
    PVector lastSpreadPoint = null;
    
    // Add ink
    for (int i = 0; i < spreadPoints.size(); ++i) {
      PVector point = spreadPoints.get(i);
      lastSpreadPoint = point;
      setPixel(int(point.x), int(point.y), BLACK);
    }
    
    // check for following points to ink
    for (int i = 0; i < spreadPoints.size(); ++i) {
      PVector point = spreadPoints.get(i);
      for (int j = 0; j < spreadPattern.length; ++j) {
        PVector move = spreadPattern[j];
        PVector nextPoint = new PVector(point.x + move.x, point.y + move.y); 
        if (!isOutOfBounds(nextPoint) && pixelIsFilled(edges, nextPoint) && pixelIsEmpty(canvas, nextPoint)) {
          // Scheduled to be filled next frame  
          nextPoints.add(nextPoint);
        } 
      }
      if (nextPoints.size() > thickness * 3)
        break;
    }
    
    if (nextPoints.size() == 0) {
      stopSpread(); 
      if (lastSpreadPoint != null) {
        this.x = int(lastSpreadPoint.x);
        this.y = int(lastSpreadPoint.y);
      }
    } else {
      spreadPoints = nextPoints;
    }
  }
  
  void drawLine() {
    PVector pt = new PVector(x,y);
    if (pixelIsFilled(edges, pt) && pixelIsEmpty(canvas, pt)) {
      atEdge = true;
      startSpread();
      framesSinceLastEdge = 0;
      return;
    } else {
      atEdge = false;
      if ((framesSinceLastEdge > 120 && thickness >= 4) || (framesSinceLastEdge > 240 && thickness > 1)) {
        framesSinceLastEdge = 0;
        thickness--;
      }
    }

    int tx = floor(x - thickness/2);
    for (int i = 0; i < thickness; ++i) {
       setPixel(tx + i, y, outputColor);
    }
    
    y++;
  }
  
  void draw() {
    if (hasEnded())
      return;
    
    // apply resistance
    int framesElapsed = frameCount - lastFrame;
    if (!spreading && framesElapsed < resistance) {
      return;
    }
    
    framesSinceLastEdge += framesElapsed;
    lastFrame = frameCount;
    
    // occasionally slow down
    if (!spreading && frameCount % 100 == 0)
      resistance++;
  
    if (spreading)
      drawSpread();
    else
      drawLine();
  }

}