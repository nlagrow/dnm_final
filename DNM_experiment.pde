import SimpleOpenNI.*;

// Stand about 5 feet away
// position sensor about 2.5 ft high

SimpleOpenNI context;

PImage img;
PImage mask;
PImage bg;
PImage trans;

PImage frame_1;
PImage frame_2;
PImage frame_3;
PImage frame_4;
PImage frame_5;
PImage frame_6;
PImage frame_7;


int w_screen = 1440;  // dimensions of the actual image
int h_screen = 900;

int SIZE_W_KINECT = 640;      // width of the kinect capture screen
int SIZE_H_KINECT = 480;      // height of the kinect capture screen

int w_s = 140;       // width of mini version - keep to w_k x h_k proportions?
int h_s = 400;

// 140 x 350

int SIZE_WIDTH_1 = 140;
int SIZE_HEIGHT_1 = 400;
int PLACEMENT_X_1 = 30;
int PLACEMENT_Y_1 = 150;

color COLOR_FILL = color(255);
color COLOR_OUTLINE = color(0);

void setup() {
  size(w_screen, h_screen);                                    // 640 x 480 are kinect dimensions
  context = new SimpleOpenNI(this);

  if (!context.isInit()) {
    println("Cannot initialize OpenNI, make sure the camera is connected.");
    exit();
    return;
  }

  context.enableDepth();
  context.enableUser();

  img = new PImage(w_s, h_s);
  mask = new PImage(w_s, h_s);
  bg = loadImage("DNM_back.png");
  trans = loadImage("DNM_trans.png");

  img.loadPixels();
  mask.loadPixels();
}

void draw() {

  // update the camera
  context.update();

  // restore kinect capture dimensions
  img.resize(SIZE_W_KINECT, SIZE_H_KINECT);

  // save the camera image as a black and white map
  int[] user_pixels = context.userMap();
  convert_to_black_white(user_pixels, img);
  img.updatePixels();
  
  frame_1 = img.get();
  frame_1.loadPixels();
  
  frame_1.resize(w_s, h_s);
  mask.resize(w_s, h_s);
  for (int i = 0; i < w_s * h_s; i++) {
    if (frame_1.pixels[i] == color(0)) {   // invisible
      mask.pixels[i] = color(0);
    } 
    else {
      mask.pixels[i] = color(255);     // visible
    }
  }
  
  //create_masked_user_image(frame_1, mask, SIZE_WIDTH_1, SIZE_HEIGHT_1);
  

  // Construct the full image
  // Bacgkround must be the same size as image
  background(bg);
  
  // draw the first frame
  frame_1.mask(mask);
  image(frame_1, PLACEMENT_X_1, PLACEMENT_Y_1);
  
  image(trans,0,0);
}

void convert_to_black_white(int[] source, PImage image) {
  for (int i = 0; i < source.length; i++) {
    if (source[i]==0) {
      // 'background' and outline color
      image.pixels[i] = COLOR_OUTLINE;
    } 
    else {
      // This is the 'fill' color
      image.pixels[i] = COLOR_FILL;
    }
  }
}

void create_masked_user_image(PImage user, PImage user_mask, int w, int h) {
  user.resize(w, h);
  mask.resize(w, h);
  
  for (int i = 0; i < w*h; i++) {
    if (user.pixels[i] == color(0)) {   // invisible
      mask.pixels[i] = color(0);
    } 
    else {
      mask.pixels[i] = color(255);     // visible
    }
  }
  
  user.updatePixels();
  user_mask.updatePixels();
}
