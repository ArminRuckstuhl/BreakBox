class Effect {
  //Initialising variables
  PImage icon;

  float x;
  float y;

  float v;

  Effect(String type, float x, float y) {
    this.x = x;
    this.y = y;

    //Check to get the correct icon for the effect
    if (type == "speed") {
      icon = loadImage("sprites/effects/speed.png");
    } else {
      icon = loadImage("sprites/effects/multi.png");
    }
  }

  //Draws icon in position
  void draw() {
    image(icon, x, y);
  }

  //Moves icon down
  void move(int distance) {
    y += distance;
  }
}
