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

Player player;

void setup() {
  // General setup
  gameState = GameState.START;
  background(0, 0, 0);
  size(1280, 768);
  imageMode(CENTER);
  loadBackgrounds();
  loadSprites();

  // Create Player
  player = new Player(3, 100, 300, 300);
}

// Handle key pressed
void keyPressed() {
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
  background(TL);
      
  player.animate();
}
