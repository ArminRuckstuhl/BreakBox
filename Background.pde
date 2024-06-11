class Background {
  //Initialises the positions to grab on the images. Used for parallax effect
  int bg1X, bg2X, bg3X;

  //Initialises the 3 backgrounds
  PImage bg1, bg2, bg3;

  int bgSpeed = 5;

  /**
    * Background Contructor
    * - loads the 3 background images
    * - sets where to start displaying the images
    */
  Background() {
    bg1 = loadImage("sprites/background/foregroundResized.png");
    bg2 = loadImage("sprites/background/midgroundResized.png");
    bg3 = loadImage("sprites/background/backgroundResized.png");

    bg1X = 2000;
    bg2X = 1000;
  }

  //Draws Background. Code is basically just copied from Assignment 3.
  void draw() {
    PImage bg1Frame = bg1.get(bg1X, 0, width, height);
    PImage bg2Frame = bg2.get(bg2X, 0, width, height);

    //Draws the image in the centre of the screen
    image(bg3, width/2, height/2);
    image(bg2Frame, width/2, height/2);
    image(bg1Frame, width/2, height/2);
  }

  //Code for the parallax effect
  void moveLeft() {
    bg1X -= bgSpeed * 5;
    bg2X -= bgSpeed * 2;
  }

  //Resets background to start position
  void reset() {
    bg1X = 2000;
    bg2X = 1000;
  }
}
