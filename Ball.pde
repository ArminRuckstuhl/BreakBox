class Ball {

  
  //initalising variables
  float vx;
  float vy;
  int radius;
  PVector velocity, position, closestPoint;

  PImage ball;

  //Constructor
  Ball(float x, float y, int v) {

    //Ensures that the ball image is only loaded once
    if (ball == null){
      ball = loadImage("sprites/ball/ball.png");
    }
    
    vx = vy = v;
    radius = 10;

    //vectors for position and velocity
    velocity = new PVector(vx, vy);
    position = new PVector(x, y);
  }
  
  void draw() {
    //updates circle and calls collision class
    collision();
    position.add(velocity);
    fill(255, 0, 0);

    //Draws the ball
    image(ball, position.x, position.y);
  }

  void collision() {
    //check if the ball has hit and if the 4 sides of the screen
    //if it has it will * the corrosponding velocity by -1
    if (position.x <= radius || position.x >= width - radius) {
      velocity.x *= -1;
    }

    if (position.y <= radius) {
      velocity.y *= -1;
    }
  }
}
