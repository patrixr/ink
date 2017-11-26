PImage source;
PImage edges;
PImage canvas;
InkLine[] drops;
int dropCount = 0;
int debugImageSelection = 0;

void setup() {
  size(640, 640);
  source = loadImage("image.jpeg");
  source.resize(640, 0);
  edges = detectEdges(source);
  canvas = createImage(source.width, source.height, RGB);
  setAllPixels(canvas, WHITE);
  drops = new InkLine[640];
}

void draw() {
  if (frameCount % 20 == 0 && dropCount < 80)   {
      int index = int(random(100, 540));
      if (drops[index] == null) {
        drops[index] = new InkLine(edges, canvas, index);
        dropCount++;
      }
  }

  canvas.loadPixels();
  for (int i = 0; i < drops.length; ++i) {
    InkLine drop = drops[i];
    if (drop != null)
      drop.draw();
  }
  canvas.updatePixels();
  
  PImage toDisplay = null;
  switch (debugImageSelection) {
    case 2: // Show source
      toDisplay = source;
      break;
    case 1:
      toDisplay = edges;
      break;
    default:
      toDisplay = canvas;
  }
  image(toDisplay, width/2 - toDisplay.width / 2, height/2 - toDisplay.height / 2);
}

void keyPressed(){
  if(key == 'x'){
    debugImageSelection++;
    if (debugImageSelection > 2)
      debugImageSelection = 0;
  } else   if(key == 'z'){
    debugImageSelection--;
    if (debugImageSelection < 0)
      debugImageSelection = 2;
  }
}