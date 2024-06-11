// States of the game help the program know what code to run and when
enum gameState {
  START, LEVEL1, LEVEL2, DEAD, COMPLETE, PLAYING, TRANSITION
};
gameState state;

//Initialising objects
Ball ball;
Bat bat;
Background bg;

//Initialising all the global variables for this class
int level;

//Images for start and end screen
PImage startScreenNoHover;
PImage startScreenHover;
PImage deathScreenNoHover;
PImage deathScreenHover;
PImage winScreenNoHover;
PImage winScreenHover;

//How the program knows the transistion is still running
int transitionCoolDown;

//Canvas dimensions
int canvasWidth = 1000;
int canvasHeight = 563;

//Variables for the grid of boxes on Level 1
int numRows = 5;
int numCols = 10;
int gap = 5; //Gap beteween boxes
float paddingX = 100; // Gap between grid to side of screen
float paddingY = 50; // Gap between grid and top of screen
float bottomPadding = 300; // Gap between grid and bottom of screen

// Calculate the available width and height for the grid after applying padding
float availableWidth = canvasWidth - 2 * paddingX;
float availableHeight = canvasHeight - paddingY - bottomPadding;

//Block width and height
//Set numbers because of sprites
int blockWidth = 77;
int blockHeight = 39;

//Variables for special blocks
float specialBlockChance = 0.1;
int ballSpeedTime;
int numOfMulti;
int numOfSpeed;

//Variables for level 2
int numCols2 = 13;
int numRows2 = 7;
float gap2 = 0;

//ArrayList to store objects
ArrayList<Bat> obstacles;
ArrayList<Bat> breakingObstacles = new ArrayList<Bat>();
ArrayList<Ball> balls;
ArrayList<Effect> effects;

//Temporary arraylists to store objects to be added/removed
ArrayList<Ball> newBalls;
ArrayList<Ball> removeBalls;
ArrayList<Bat> addObstacles;

/**
  * The setup method is called once when the game is first loaded
  *
  * The main purpose of the setup function is to setup up all the assets 
  * for the game, including the canvas, as well as spawn in the objects
 */
void setup() {

  //Makes sure all the images are loaded
  Bat loadBat = new Bat(0, 0, 0, 0, "no", 0);
  Ball loadBall = new Ball(0, 0, 0);

  //Specifications of canvas
  size(1000, 563);
  imageMode(CENTER);
  frameRate(30);

  //Loading all the screen images
  startScreenHover = loadImage("sprites/startScreen/startScreenHover.png");
  startScreenNoHover = loadImage("sprites/startScreen/startScreenNoHover.png");
  deathScreenHover = loadImage("sprites/death/deathScreenHover.png");
  deathScreenNoHover = loadImage("sprites/death/deathScreenNoHover.png");
  winScreenHover = loadImage("sprites/win/winScreenHover.png");
  winScreenNoHover = loadImage("sprites/win/winScreenNoHover.png");

  //Declaring background object
  bg = new Background();

  //Setting game state
  state = gameState.START;
}

/**
  * This method is the main functionality of the game, it is called each game tick
  *
  * Depending on what state the game is in, this method will call the relevant code
  */
void draw() {

  //Draws the end screens
  if (state == gameState.START || state == gameState.DEAD || state == gameState.COMPLETE) {
    cursor(HAND);
    drawStartDeathWinScreen(state);
  }
  //Constructs level 1, Resets all objects and arraylists
  else if (state == gameState.LEVEL1) {
    createLevel(1);
  }
  //Contructs Level 2, resets all objects and arraylists
  else if (state == gameState.LEVEL2) {
    createLevel(2);
  }
  //Plays the transition between level 1 and 2. The cooldown ensures that it isn't interrupted
  else if (state == gameState.TRANSITION) {
    handleTransition();
  }
  /**
   * This is the biggest state in the program.
   * All of the game's functionality are in this state
   **/
  else if (state == gameState.PLAYING) {
    //Draws the background. It is the first thing that is done as the background needs to be behind all other objects
    bg.draw();

    // Checking to see if all the boxes have been destroyed
    checkLevelComplete();

    handleBalls();

    //Draws the player's bat
    bat.draw();

    //Draws all the obstacles
    for (Bat obstacle : obstacles) {
      obstacle.draw();
    }

    //Handles effects
    effects();

    //Handles the breaking boxes
    breakingBoxes();
  }
}

/**
  * This method handles the shared set up between levels
  *
  * It resets variables and initializes the level, thel calls a method
  * to build the level
  *
  * @param levelNum is the level which is being constructed
  */
void createLevel(int levelNum){
  
  // Reseting variables
  numOfMulti = 0;
  numOfSpeed = 0;
  noCursor();
  ballSpeedTime = -1;
  bg.reset();
  
  // Initialising level
  level = levelNum;
  balls = new ArrayList<Ball>();
  ball = new Ball(40, 300, 10);
  balls.add(ball);
  bat = new Bat(120, 20, mouseX, mouseY, "mouse", 0); 
  
  // Creating level
  if (levelNum == 1){
    createLevelOne();
  } else {
    createLevelTwo();
  }
  
  //Changes game state to playing
  state = gameState.PLAYING;
}

/**
  * This method handles the transition phase between the two levels
  *
  * If the transition is complete, it changes the game state to level 
  * two, otherwise it just continues the transition
  */
void handleTransition(){
  if (transitionCoolDown == 0) {//Means that the transition is over and the program should move on
      state = gameState.LEVEL2;
    } else {
      bg.moveLeft();//Moves the background
      bg.draw();
      transitionCoolDown--;
    }
}

/**
  * This method checks to see if the player has destroyed all the boxes
  *
  * If they have and they are on level 1, it starts the transition
  * If they are on level 2, it calls the win screen
  */
void checkLevelComplete() {
  //Checks to see if the player has destroyed all the boxes
    if (obstacles.size() == 0) {
      balls.clear();
      obstacles.clear();
      if (level == 1) {//Means that the player has completed level 1, starts the transition to level 2
        transitionCoolDown = 75;

        //Changes game state to transition
        state = gameState.TRANSITION;
      } else {//Means the player has beaten the second level and completed the game
        state = gameState.COMPLETE;
      }
    }
}

/**
  * This method handles the collisions between the balls, boxes, and the bat
  */
void handleBalls(){
  
  //These arraylists are temporary as I am unable to change the arraylists that are being iterated though
  newBalls = new ArrayList<Ball>();
  removeBalls = new ArrayList<Ball>();
  addObstacles = new ArrayList<Bat>();

  for (Ball ball : balls) {

    //Checks to see if the ball is off the bottom of the screen
    if (checkDead(ball)) {
      state = gameState.DEAD;
    }
    
    //Checks to see if the ball has hit the bat
    checkCollisionBat(bat.position.x, bat.position.y, bat.w, bat.h, ball);

    checkCollisionBox(ball);

    //Draws the ball on the screen
    ball.draw();
    if (ballSpeedTime >= 0) {
      ballSpeedTime--; // Decrements the speed effect
    }

    if (ballSpeedTime == 0) {//Means the speed effect is finished
      //Removes sped up ball and replaces it with a ball of normal speed
      removeBalls.add(ball);
      Ball newBall = new Ball(ball.position.x, ball.position.y, 10);
      newBalls.add(newBall);
    }
  }
  //Changes original arrayLists
  balls.addAll(newBalls);
  balls.removeAll(removeBalls);
  obstacles.addAll(addObstacles);
}

/**
  * Checks collisions between the ball and the player controlled bat
  * Also changes the velocity of the ball in the appropriate manor
  *
  * @return true if there is a collision
  * @return false if there isn't
  */
boolean checkCollisionBat(float x, float y, float width, float height, Ball ball) {
  float halfWidth = width / 2.0;
  float halfHeight = height / 2.0;

  // Calculate the edges of the bat
  float batLeft = x;
  float batRight = x + width;
  float batTop = y;
  float batBottom = y + height;

  float topLeftDistance = dist(ball.position.x, ball.position.y, batLeft, batTop);
  float topRightDistance = dist(ball.position.x, ball.position.y, batRight, batTop);
  float bottomLeftDistance = dist(ball.position.x, ball.position.y, batLeft, batBottom);
  float bottomRightDistance = dist(ball.position.x, ball.position.y, batRight, batBottom);

  // Check if the ball collides with the bat
  if (ball.position.x + ball.radius / 2 >= batLeft && ball.position.x - ball.radius / 2 <= batRight &&
    ball.position.y + ball.radius / 2 >= batTop && ball.position.y - ball.radius / 2 <= batBottom) {

    // Ball hits the top part of the bat
    if (ball.position.y <= y + ball.radius / 2 && ball.position.x > x && ball.position.x < x + width) {
      ball.velocity.y *= -1; // Reverse the Y velocity to simulate a bounce off the top.
    }
    // Ball hits the bottom part of the bat
    else if (ball.position.y >= y + height - ball.radius / 2 && ball.position.x > x && ball.position.x < x + width) {
      ball.velocity.y *= -1; // Reverse the Y velocity to simulate a bounce off the bottom.
    }
    // Ball hits the left part of the bat
    else if (ball.position.x <= x + ball.radius / 2 && ball.position.y > y && ball.position.y < y + height) {
      ball.velocity.x  *= -1; // Reverse the X velocity to simulate a bounce off the left.
    }
    // Ball hits the right part of the bat
    else if (ball.position.x >= x + width - ball.radius / 2 && ball.position.y > y && ball.position.y < y + height) {
      ball.velocity.x *= -1; // Reverse the X velocity to simulate a bounce off the right.
    }

    // Ball hits the top-left corner of the bat
    else if (topLeftDistance <= ball.radius/2 && ball.position.x < x + ball.radius / 2 && ball.position.y < y + ball.radius / 2) {
      ball.velocity.set(-abs(ball.velocity.x), -abs(ball.velocity.y));
    }
    // Ball hits the top-right corner of the bat
    else if (topRightDistance <= ball.radius/2 && ball.position.x > x + width - ball.radius / 2 && ball.position.y < y + ball.radius / 2) {
      ball.velocity.set(abs(ball.velocity.x), -abs(ball.velocity.y));
    }
    // Ball hits the bottom-left corner of the bat
    else if (bottomLeftDistance <= ball.radius && ball.position.x < x + ball.radius / 2 && ball.position.y > y + height - ball.radius / 2) {
      ball.velocity.set(-abs(ball.velocity.x), abs(ball.velocity.y));
    }
    // Ball hits the bottom-right corner of the bat
    else if (bottomRightDistance <= ball.radius && ball.position.x > x + width - ball.radius / 2 && ball.position.y > y + height - ball.radius / 2) {
      ball.velocity.set(abs(ball.velocity.x), abs(ball.velocity.y));
    }
    return true;
  }
  return false;
}

/**
  * This method checks the collision between the ball and the boxes
  *
  * Iterates through all the obstacles
  *  - Checks to see if the ball has hit the obstacle
  *  - If yes, does the correct functionality
  *
  * @param ball is the current ball to check
  */
void checkCollisionBox(Ball ball){

  for (int i = 0; i < obstacles.size(); i++) {
    Bat box = obstacles.get(i);
    boolean hit = checkCollisionTarget(box.position.x, box.position.y, box.w, box.h, ball);
    if (hit) {//Box has been hit
      box.counter--;//Removes 1 from the health of the box

      handleSpecialBoxes(box, i); // Handling special Boxes

      
      if (box.counter < 0) {//Means the box has no health left
        //Creates a duplicate temp box and adds it to the breakingObstacles arraylist.
        //This arraylist is iterated over so the break animation plays without the box having collision
        Bat breaking = new Bat(blockWidth, blockHeight, box.position.x, box.position.y, box.type, 0);
        breakingObstacles.add(breaking);
        obstacles.remove(i);//Removes box
      }
    }
  }
}

/**
  * This method handles the behaviour of the special boxes
  *
  * A multi box spawns a new ball in
  * A speed box speeds up the current ball for a set period of time
  *
  * @param box is the box to check
  * @param i is the index of the box in the arraylist of boxes
  */
void handleSpecialBoxes(Bat box, int i){
  
  ///Gets the box's position, sets count and type for future use
  float blockX = box.position.x;
  float blockY = box.position.y;
  String type = "regular";
  int count = 0;
  
  //A multi-box spawns a new ball in
  if (box.type == "multi") {
    obstacles.remove(i);//Removes box

    //Spawns new ball in and adds it to arraylist of balls
    ball = new Ball(40, 300, 10);
    newBalls.add(ball);

    //Spawns in the effect icon
    Effect multi = new Effect("multi", box.position.x, box.position.y);
    effects.add(multi);
    Bat obstacle = new Bat(blockWidth, blockHeight, blockX, blockY, type, count);
    addObstacles.add(obstacle);
  }
  if (obstacles.get(i).type == "speed") {
    obstacles.remove(i);//Removes box

    //Sets the timer for how long the effect lasts
    ballSpeedTime = 150;

    //Creates a new ball with the updates speed and adds it to the arraylist of balls
    removeBalls.add(ball);
    Ball newBall = new Ball(ball.position.x, ball.position.y, 15);
    newBalls.add(newBall);

    //Spawns in speed effect
    Effect speed = new Effect("speed", box.position.x, box.position.y);
    effects.add(speed);


    Bat obstacle = new Bat(blockWidth, blockHeight, blockX, blockY, type, count);
    addObstacles.add(obstacle);
  }
}

/**
  * This method checks the collision between the bat and the balls ensuring correct bouncage
  *
  * @param x the x position of the top left of the bat
  * @param y the y position of the top left of the bat
  * @param width is the width of the bat
  * @param height is the height of the bat
  * @param ball is the ball to check contact with
  */
boolean checkCollisionTarget(float x, float y, float width, float height, Ball ball) {
  float halfWidth = width / 2.0;
  float halfHeight = height / 2.0;

  // Calculate the edges of the bat
  float batLeft = x;
  float batRight = x + width;
  float batTop = y;
  float batBottom = y + height;

  float topLeftDistance = dist(ball.position.x, ball.position.y, batLeft, batTop);
  float topRightDistance = dist(ball.position.x, ball.position.y, batRight, batTop);
  float bottomLeftDistance = dist(ball.position.x, ball.position.y, batLeft, batBottom);
  float bottomRightDistance = dist(ball.position.x, ball.position.y, batRight, batBottom);

  // Check if the ball collides with the bat
  if (ball.position.x + ball.radius / 2 >= batLeft && ball.position.x - ball.radius / 2 <= batRight &&
    ball.position.y + ball.radius / 2 >= batTop && ball.position.y - ball.radius / 2 <= batBottom) {

    // Ball hits the top part of the bat
    if (ball.position.y <= y + ball.radius / 2 && ball.position.x > x && ball.position.x < x + width) {
      ball.velocity.y *= -1; // Reverse the Y velocity to simulate a bounce off the top.
    }
    // Ball hits the bottom part of the bat
    else if (ball.position.y >= y + height - ball.radius / 2 && ball.position.x > x && ball.position.x < x + width) {
      ball.velocity.y *= -1; // Reverse the Y velocity to simulate a bounce off the bottom.
    }
    // Ball hits the left part of the bat
    else if (ball.position.x <= x + ball.radius / 2 && ball.position.y > y && ball.position.y < y + height) {
      ball.velocity.x  *= -1; // Reverse the X velocity to simulate a bounce off the left.
    }
    // Ball hits the right part of the bat
    else if (ball.position.x >= x + width - ball.radius / 2 && ball.position.y > y && ball.position.y < y + height) {
      ball.velocity.x *= -1; // Reverse the X velocity to simulate a bounce off the right.
    }

    // Ball hits the top-left corner of the bat
    else if (topLeftDistance <= ball.radius/2 && ball.position.x < x + ball.radius / 2 && ball.position.y < y + ball.radius / 2) {
      ball.velocity.set(-abs(ball.velocity.x), -abs(ball.velocity.y));
    }
    // Ball hits the top-right corner of the bat
    else if (topRightDistance <= ball.radius/2 && ball.position.x > x + width - ball.radius / 2 && ball.position.y < y + ball.radius / 2) {
      ball.velocity.set(abs(ball.velocity.x), -abs(ball.velocity.y));
    }
    // Ball hits the bottom-left corner of the bat
    else if (bottomLeftDistance <= ball.radius && ball.position.x < x + ball.radius / 2 && ball.position.y > y + height - ball.radius / 2) {
      ball.velocity.set(-abs(ball.velocity.x), abs(ball.velocity.y));
    }
    // Ball hits the bottom-right corner of the bat
    else if (bottomRightDistance <= ball.radius && ball.position.x > x + width - ball.radius / 2 && ball.position.y > y + height - ball.radius / 2) {
      ball.velocity.set(abs(ball.velocity.x), abs(ball.velocity.y));
    }
    return true;
  }
  return false;
}


/**
  * Creates the first level
  *
  * Spawns in the grid of boxes, including the special boxes
  *
  */
void createLevelOne() {

  //Resets the arraylists for the boxes and the effects
  obstacles = new ArrayList<Bat>();
  effects = new ArrayList<Effect>();

  //Constructs grid of boxes
  for (int row = 0; row < 4; row++) {

    //Row gap adjusted
    float blockY = paddingY + row * (blockHeight + gap);

    for (int col = 0; col < 10; col++) {

      //Column gap adjusted
      float blockX = paddingX + col * (blockWidth + gap);

      //Default values of the boxes
      String type = "regular";
      int count = 0;

      //Adds the design of the boxes with two health
      if ((row == 1 && (col == 0 || col == 9)) || (row == 2 && (col == 0 || col == 1 || col == 2 || col == 7 || col == 8 || col ==9)) || row == 3) {
        count = 1;
      }

      //How special boxes are decided - Each box has a 10% chance of being a special box
      if (random(1) < specialBlockChance) {
        count = 0;
        float blockType = random(1);
        if (blockType < 0.5 && numOfMulti < 1) {// 50/50 chance between multi and speed
          type = "multi";
          numOfMulti++;
          println(numOfMulti);
        } else if (blockType >= 0.5 && numOfSpeed < 2) {
          type = "speed";
          numOfSpeed++;
        }
      }

      //Creates box
      obstacles.add(new Bat(blockWidth, blockHeight, blockX, blockY, type, count));
    }
  }
}

/**
  * Creates the second level
  *
  * Spawns in the pattern of boxes, including the special boxes
  *
  * The difference between the construction of the first and second level is that the 
  * second level's layout is harder and the boxes have more health
  *
  */
void createLevelTwo() {
  
  // Creating new arraylists
  obstacles = new ArrayList<Bat>();
  effects = new ArrayList<Effect>();
  
  // Creating boxes
  for (int row = 0; row < numRows2; row++) {
    for (int col = 0; col < numCols2; col++) {
      float blockX2 = col * (blockWidth + gap2);
      float blockY2 = row * (blockHeight + gap2);
      int count = 0;
      String type = "regular";

      // Alternate between blocks and air spaces
      if ((row % 2 == 0 && col % 2 == 0) || (row % 2 != 0 && col % 2 != 0)) {

        //Changes the health of specific boxes
        if (row == 6 || row == 5) {
          count = 2;
        }
        if (row == 4 || row == 3) {
          count = 1;
        }
        
        // Creating the special boxes
        if (random(1) < specialBlockChance) {
          count = 1;
          float blockType = random(1);
          if (blockType < 0.5 && numOfMulti < 3) {
            type = "multi";
            numOfMulti++;
          } else if ( blockType >= 0.5 && numOfSpeed < 4) {
            type = "speed";
            numOfSpeed++;
          }
        }
        
        // Adding the box to the world
        obstacles.add(new Bat(blockWidth, blockHeight, blockX2, blockY2, type, count));
        
      } else {
        // Air space
      }
    }
  }
}

/**
  * Draws the start, death, and win screen
  *
  * Does the math for how the hitbox of the start button works
  * If the start button is clicked, it starts the game
  *
  * @param state is the current state of the game, this tells the program what image to draw
  */
void drawStartDeathWinScreen(gameState state) {
  
  //Calculates the hit box of the button
  float buttonX = (width/2+7) - (151 / 2);
  float buttonY = (height - 100) - (50 / 2);
  float buttonWidth = 151;
  float buttonHeight = 50;

  //Checks if the mouse is in the hitbox of the button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth && mouseY >= buttonY && mouseY <= buttonY + buttonHeight) {
    if (state.equals(gameState.START)){
      image(startScreenHover, width/2, height/2);
    } else if (state.equals(gameState.DEAD)) {
      image(deathScreenHover, width/2, height/2);
    } else {
      image(winScreenHover, width/2, height/2);
    }
    if (mousePressed) {
      this.state = gameState.LEVEL1;
    }
  } else {
    if (state.equals(gameState.START)){
      image(startScreenNoHover, width/2, height/2);
    } else if (state.equals(gameState.DEAD)){
      image(deathScreenNoHover, width/2, height/2);
    } else {
       image(winScreenNoHover, width/2, height/2);
    }
  }
}

/**
  * Checks if the ball is below the bottom of the canvas
  * 
  * @return true if it has, false if not
  */
boolean checkDead(Ball ball) {
  if (ball.position.y >= canvasHeight + ball.radius) {
    return true;
  } else {
    return false;
  }
}

/**
  * Handles the animation of the breaking boxes, incrementing through each frame
  * After the animation is over, it removes the box from the arraylist
  */
void breakingBoxes() {
  //Resets temp arraylist of breakingBoxes to remove
  ArrayList<Bat> removeBreakingObstacles = new ArrayList<Bat>();
  if (!breakingObstacles.isEmpty()) {
    for (Bat box : breakingObstacles) {
      if (box.frame > 7) {//Means the animation has played out fully and the box shouldn't exist anymore
        removeBreakingObstacles.add(box);
      } else {
        box.incrementAnim();//Moves animation to next frame
        box.draw();
      }
    }
    breakingObstacles.removeAll(removeBreakingObstacles);
  }
}

/**
  * Handles the animation of the effects as it moves them down the screen
  * Removes the effect when it is off the screen
  */
void effects() {
  ArrayList<Effect> removeEffect = new ArrayList<Effect>();
  for (Effect effect : effects) {
    if (effect.y > canvasHeight) {
      removeEffect.add(effect);
    }
    effect.draw();
    effect.move(10);
  }
  effects.removeAll(removeEffect);
}
