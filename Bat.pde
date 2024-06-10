class Bat {
  
  //Initialising Variables
  int w;
  int h;
  float easing;
  PVector position;
  String type;
  int counter;

  //Variables for the sprites and breaking animation
  PImage boxSpriteSheet;
  int frames = 9;
  int padding = 10;
  
  //Image for player controlled bat
  PImage bat;

  //Variables for the boxes
  PImage[] oneHealth;
  PImage twoHealth;
  PImage threeHealth;
  PImage[] multi;
  PImage[] speed;

  //What frame of animation it is on
  int frame;

  //Dimensions of boxes
  int bW = 77;
  int bH = 39;

  Bat(int w, int h, float x, float y, String type, int counter) {
    this.w = w;
    this.h = h;
    easing = 0.8;
    position = new PVector(x, y);
    this.type = type;
    this.counter = counter;
    frame = 0;
    
    //Ensures that sprutes are only loaded once
    if (multi == null) {
      loadSprites();
    }
  }

  void loadSprites() {
    bat = loadImage("sprites/bat/bat.png");
    boxSpriteSheet = loadImage("sprites/boxes/bricks.png");
    oneHealth = new PImage[frames];
    multi = new PImage[frames];
    speed = new PImage[frames];

    twoHealth = boxSpriteSheet.get(0, bH + padding, bW, bH);
    threeHealth = boxSpriteSheet.get(0, (bH + padding) * 2, bW, bH);
    
    //Populates the arrays of PImage which store the frames of animation
    for (int i = 0; i < frames; i++) {
      oneHealth[i] = boxSpriteSheet.get(i * (bW + padding), 0, bW, bH);
      multi[i] = boxSpriteSheet.get(i * (bW + padding), (bH + padding) * 3, bW, bH);
      speed[i] = boxSpriteSheet.get(i * (bW + padding), (bH + padding) * 4, bW, bH);
    }
  }

  //Draws bat
  void draw() {
    //Used for sprites - converts CORNER type to CENTER type
    float imageX = position.x + w / 2;
    float imageY = position.y + h / 2;

    //Checks the type of the box
    if (!type.equalsIgnoreCase("mouse")) {//Box isn't the player controlled bat
    
      //Changes image depending on the amount of health left
      if (counter == 0) {
        image(oneHealth[frame], imageX, imageY);
      } else if (counter == 1) {
        image(twoHealth, imageX, imageY);
      } else if (counter == 2) {
        image(threeHealth, imageX, imageY);
      }

      //Changes image from regular to the correct specialBox images
      if (type == "multi") {
        image(multi[frame], imageX, imageY);
      } else if (type == "speed") {
        image(speed[frame], imageX, imageY);
      }
    } 
    else {//Means the box is the player controlled bat
      outOfWindow();
      position.x = constrain(position.x, 0, width - w);
      position.y = height - h - 20;

      imageX = position.x + w / 2;
      imageY = position.y + h / 2;

      //Draws the bat in the correct location
      image(bat, imageX, imageY);
    }
  }

  //Increments the animation
  void incrementAnim() {
    frame++;
  }

  //Checks to see if the bat is out of the window
  void outOfWindow() {
    if (abs(mouseX -position.x) > 0.1) {
      position.x = position.x + (mouseX - position.x) * easing;
    }
  }
}
