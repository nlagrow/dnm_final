import SimpleOpenNI.*;

// Stand about 5 ft away
// position sensor about 2.5 ft high

int x = 0;
int MAX_FRAMES = 20;
int SIZE_W_KINECT = 640;      // width of the kinect capture screen
int SIZE_H_KINECT = 480;      // height of the kinect capture screen
int thresh = 40;              // frames to wait until capture starts - avoid choppiness

boolean save = false;

PImage img;
SimpleOpenNI context;

// to be changed per pose
int pose_number = 13;

void setup() {
  size(SIZE_W_KINECT, SIZE_H_KINECT);
  context = new SimpleOpenNI(this);
  
  if (!context.isInit()) {
    println("Cannot initialize OpenNI, make sure the camera is connected.");
    exit();
    return;
  }
  
  context.enableDepth();
  context.enableUser();
  img = new PImage(SIZE_W_KINECT, SIZE_H_KINECT);
  img.loadPixels();
}

void draw() {
  context.update();
  int[] user_pixels = context.userMap();
  convert_to_black_white(user_pixels, img);
  img.updatePixels();
  
  background(0);
  image(img, 0, 0);
 
  if (x < MAX_FRAMES + thresh) {
    for (int i = 0; i < SIZE_W_KINECT * SIZE_H_KINECT; i++) {
      if (img.pixels[i] != color(0)) {
        save = true;
      } 
    }
    if (save == true) {
      x++;
      if (x > thresh) {
        String filename_1 = "pose_"+pose_number+"/"+(x-thresh)+".png";
        String filename_2 = "pose_"+pose_number+"/"+(MAX_FRAMES*2-(x-thresh)+1)+".png";
        saveFrame(filename_1);
        saveFrame(filename_2);
        //print("save "+filename_1+"\n");
      }
    }
    save = false;
  }
}

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
