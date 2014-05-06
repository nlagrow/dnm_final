import SimpleOpenNI.*;

// Stand about 5 feet away
// position sensor about 2.5 ft high

SimpleOpenNI context;

Animation animation1;
Animation animation2;
Animation animation3;
Animation animation4;
Animation animation5;
Animation animation6;
Animation animation7;

PImage img, bg, trans;
PImage frame_1;
PImage mask_1;

int w_screen = 1440;  // dimensions of the actual image
int h_screen = 900;
int SIZE_W_KINECT = 640;      // width of the kinect capture screen
int SIZE_H_KINECT = 480;      // height of the kinect capture screen

color COLOR_FILL = color(255);
color COLOR_OUTLINE = color(0);

// Animation Settings
int FRAME_RATE = 10;
int NUM_FRAMES = 39;

int SIZE_W_1 = 140;
int SIZE_H_1 = 400;
int PLACEMENT_X_1 = 20;
int PLACEMENT_Y_1 = 250;

int SIZE_W_2 = 140;
int SIZE_H_2 = 400;
int PLACEMENT_X_2 = 220;
int PLACEMENT_Y_2 = 300;

int SIZE_W_3 = 250;
int SIZE_H_3 = 350;
int PLACEMENT_X_3 = 350;
int PLACEMENT_Y_3 = 250;

int SIZE_W_4 = 250;
int SIZE_H_4 = 350;
int PLACEMENT_X_4 = 600;
int PLACEMENT_Y_4 = 320;

int SIZE_W_5 = 250;
int SIZE_H_5 = 188;
int PLACEMENT_X_5 = 790;
int PLACEMENT_Y_5 = 420;

int SIZE_W_6 = 100;
int SIZE_H_6 = 250;
int PLACEMENT_X_6 = 1120;
int PLACEMENT_Y_6 = 440;

int SIZE_W_7 = 200;
int SIZE_H_7 = 400;
int PLACEMENT_X_7 = 1230;
int PLACEMENT_Y_7 = 380;

void setup() {
  size(w_screen, h_screen);                                    // 640 x 480 are kinect dimensions
  context = new SimpleOpenNI(this);

  if (!context.isInit()) {
    println("Cannot initialize OpenNI, make sure the camera is connected.");
    exit();
    return;
  }
  
  context.setMirror(true);
  context.enableDepth();
  context.enableUser();

  img = new PImage(SIZE_W_KINECT, SIZE_H_KINECT);
  
  // Create placeholder masks
  mask_1 = new PImage(SIZE_W_1, SIZE_H_1);

  // Fixed images
  bg = loadImage("DNM_back.png");
  trans = loadImage("DNM_trans.png");
  
  frameRate(FRAME_RATE);
  
  animation1 = new Animation("pose_1/", NUM_FRAMES, SIZE_W_1, SIZE_H_1);
  animation2 = new Animation("pose_2/", NUM_FRAMES, SIZE_W_2, SIZE_H_2);
  //animation3 = new Animation("pose_3/", NUM_FRAMES, SIZE_W_3, SIZE_H_3);
  animation4 = new Animation("pose_4/", NUM_FRAMES, SIZE_W_4, SIZE_H_4);
  animation5 = new Animation("pose_5/", NUM_FRAMES, SIZE_W_5, SIZE_H_5);
  animation6 = new Animation("pose_6/", NUM_FRAMES, SIZE_W_6, SIZE_H_6);
  animation7 = new Animation("pose_7/", NUM_FRAMES, SIZE_W_7, SIZE_H_7);
  
  img.loadPixels();
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

  // build the mirrored frame
  frame_1 = img.get();
  frame_1 = create_masked_user_image(frame_1, SIZE_W_3, SIZE_H_3); 

  // Construct the full image
  // Background must be the same size as im age
  background(bg);

  // draw each individual frame
  image(frame_1, PLACEMENT_X_3, PLACEMENT_Y_3);

  // draw animations
  animation1.display(PLACEMENT_X_1, PLACEMENT_Y_1);
  animation2.display(PLACEMENT_X_2, PLACEMENT_Y_2);
  //animation3.display(PLACEMENT_X_3, PLACEMENT_Y_3);
  animation4.display(PLACEMENT_X_4, PLACEMENT_Y_4);
  animation5.display(PLACEMENT_X_5, PLACEMENT_Y_5);
  animation6.display(PLACEMENT_X_6, PLACEMENT_Y_6);
  animation7.display(PLACEMENT_X_7, PLACEMENT_Y_7);
  
  image(trans, 0, 0);
}



// Helper functions

void convert_to_black_white(int[] source, PImage image) {
  for (int i = 0; i < source.length; i++) {
    if (source[i] == 0) {
      // 'background' and outline color
      image.pixels[i] = color(0);
    } 
    else {
      // This is the 'fill' color
      image.pixels[i] = color(255);
    }
  }
}

PImage create_masked_user_image(PImage user, int w, int h) {
  user.loadPixels();

  user.resize(w, h);
  PImage user_mask = new PImage(w, h);
  
  for (int i = 0; i < w * h; i++) {
    if (user.pixels[i] == 0 || user.pixels[i] == color(0)) {               // invisible
      user_mask.pixels[i] = color(0);
    } 
    else {
      user_mask.pixels[i] = color(255);      // visible
    }
  }
  
  user_mask.filter(DILATE);
  user.mask(user_mask);
  return user;
}

class Animation {
  PImage[] images;
  int imageCount, frame;
  
  Animation(String imagePrefix, int count, int w, int h) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      String filename = imagePrefix + (i+1) + ".png";
      images[i] = create_masked_user_image(loadImage(filename), w, h);
    }
  }

  void display(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos);
  }
  
  int getWidth() {
    return images[0].width;
  }
}
