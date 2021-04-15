GameState gameState;

int PID = 3; // Player Idle spritesheet dimension
int PWD = 4; // Player Walk spritesheet dimension

PImage pIdleUpSS, pIdleDownSS, pIdleLeftSS, pIdleRightSS;
PImage pWalkUpSS, pWalkDownSS, pWalkLeftSS, pWalkRightSS; 

PImage[] pIdleUp = new PImage[PID];
PImage[] pIdleDown = new PImage[PID];
PImage[] pIdleLeft = new PImage[PID];
PImage[] pIdleRight = new PImage[PID];

PImage[] pWalkUp = new PImage[PWD];
PImage[] pWalkDown = new PImage[PWD];
PImage[] pWalkLeft = new PImage[PWD];
PImage[] pWalkRight = new PImage[PWD];

// Backgrounds
PImage T, L, B, R, TL, TB, TR, LR, BL, BR, TLR, TBL, TBR, BLR, TBLR;
ArrayList<ArrayList<Screen>> map = new ArrayList<ArrayList<Screen>>();
JSONArray mapVals;
int MAPDIM = 3;

Player player;
Screen currentScreen;

void setup() {
  // General setup
  gameState = GameState.START;
  background(0, 0, 0);
  size(1280, 768);
  imageMode(CENTER);
  rectMode(CENTER);
  loadBackgrounds();
  loadSprites();

  // Create Player
  player = new Player(3, 100, 300, 300);
  loadMapVals();
  createMap();
  currentScreen=map.get(0).get(0);
}

// Handle key pressed
void keyPressed() {
  switch(keyCode) {
    case UP:
      changeScreen(Direction.DUP);
      break;
    case DOWN:
      changeScreen(Direction.DDOWN);
      break;
    case LEFT:
      changeScreen(Direction.DLEFT);
      break;
    case RIGHT:
      changeScreen(Direction.DRIGHT);
      break;
  }
  switch(gameState) {
    case INTRO:
      break;
    case START:
      switch(key) {
        case 'w':
          player.move(Direction.DUP, true);
          break;
        case 'a':
          player.move(Direction.DLEFT, true);
          break;
        case 's':
          player.move(Direction.DDOWN, true);
          break;
        case 'd':
          player.move(Direction.DRIGHT, true);
          break;
      }
      // if (keyCode == SHIFT) { player.run(true); }
      break;
    case GAMEOVER:
      break;
  }
}

// Handle key released
void keyReleased() {
  switch(gameState) {
    case INTRO:
      break;
    case START:
      switch(key) {
        case 'w':
          player.move(Direction.DUP, false);
          break;
        case 's':
          player.move(Direction.DDOWN, false);
          break;
        case 'a':
          player.move(Direction.DLEFT, false);
          break;
        case 'd':
          player.move(Direction.DRIGHT, false);
          break;
      }
      // if (keyCode == SHIFT) { player.run(false); }
      break;
    case GAMEOVER:
      break;
  }
}

void draw() {
  currentScreen.drawBG(); 
  player.animate();
  fill(255, 255, 255);
  text(str(currentScreen.i) + " " + str(currentScreen.j), 500, 500);
}
