GameState gameState;

int PID = 3; // Player Idle spritesheet dimension
int PWD = 4; // Player Walk spritesheet dimension

PImage pIdleUpSS, pIdleDownSS, pIdleLeftSS, pIdleRightSS;
PImage pWalkUpSS, pWalkDownSS, pWalkLeftSS, pWalkRightSS; 
PImage inkSS;
PImage quillSS;

PImage[] pIdleUp = new PImage[PID];
PImage[] pIdleDown = new PImage[PID];
PImage[] pIdleLeft = new PImage[PID];
PImage[] pIdleRight = new PImage[PID];

PImage[] pWalkUp = new PImage[PWD];
PImage[] pWalkDown = new PImage[PWD];
PImage[] pWalkLeft = new PImage[PWD];
PImage[] pWalkRight = new PImage[PWD];

PImage[] ink = new PImage[5];
PImage[] quill = new PImage[5];
Color penColor;

// Backgrounds
PImage T, L, B, R, TL, TB, TR, LR, BL, BR, TLR, TBL, TBR, BLR, TBLR;
ArrayList<ArrayList<Screen>> map = new ArrayList<ArrayList<Screen>>();
JSONArray mapVals;
int MAPDIM = 3;
int[][] mapDoors = new int[9][10];

int sWidth = 1280;
int sHeight = 768;

boolean showMap;

PFont merchant32;
PFont merchant24;

Player player;
Screen currentScreen;

void setup() {
  // General setup
  gameState = GameState.START;
  background(0, 0, 0);
  size(1280, 768);
  imageMode(CENTER);
  rectMode(CENTER);
  noCursor();
  merchant32 = createFont("Merchant Copy.ttf", 32);
  merchant24 = createFont("Merchant Copy.ttf", 24);
  textFont(merchant32);
  loadBackgrounds();
  loadSprites();
  penColor = Color.BLACK;

  // Create Map
  loadMapVals();
  createMap();
  currentScreen=map.get(0).get(0);

  // Create Player
  player = new Player(64, 3, 100, 300, 300);
}

// Handle key pressed
void keyPressed() {

  //case LEFT:
  //  changeScreen(Direction.DLEFT);
  //  break;
  //case RIGHT:
  //  changeScreen(Direction.DRIGHT);
  //  break;
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
    case 'm':
      showMap = !showMap;
      break;
    }

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

void mouseClicked() {
  switch(gameState) {
  case INTRO:
    break;
  case START:
    changePenColor();
    break;
  case GAMEOVER:
    break;
  }
}

void draw() {
  currentScreen.drawBG(); 
  player.animate();

  if (showMap) {
    showMap();
  }

  fill(255, 255, 255);
  //text(str(currentScreen.i) + " " + str(currentScreen.j), 35, 35);
  text(penColor.name(), 35, 35);
}
