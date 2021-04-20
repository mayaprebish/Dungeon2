import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Dungeon2 extends PApplet {

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
ArrayList<ArrayList<Screen>> dungeon = new ArrayList<ArrayList<Screen>>();
ArrayList<ArrayList<Cell>> map = new ArrayList<ArrayList<Cell>>();
JSONArray mapVals;
int MAPX = 8;
int MAPY = 9;
int[][] mapDoors = new int[9][10];

int sWidth = 1280;
int sHeight = 768;

boolean showMap;

PFont merchant32;
PFont merchant24;

Player player;
Screen currentScreen;

public void setup() {
  // General setup
  gameState = GameState.START;
  background(0, 0, 0);
  
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
  createDungeon();
  createMap();
  currentScreen=dungeon.get(0).get(0);

  // Create Player
  player = new Player(64, 3, 100, 300, 300);
}

// Handle key pressed
public void keyPressed() {
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
public void keyReleased() {
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

public void mouseClicked() {
  switch(gameState) {
  case INTRO:
    break;
  case START:
    if (showMap) {
      changePenColor();
      editDoors();
    }
    
    break;
  case GAMEOVER:
    break;
  }
}

public void draw() {
  currentScreen.drawBG(); 
  player.animate();

  if (showMap) {
    showMap();
  }
}
public enum GameState {
  INTRO, 
    START, 
    GAMEOVER
}

public enum Direction {
  DUP, 
    DDOWN, 
    DLEFT, 
    DRIGHT
}

public enum DoorConfig {
  T, 
    B, 
    L, 
    R, 
    TL, 
    TR, 
    BL, 
    BR, 
    TB, 
    LR, 
    TBL, 
    TBR, 
    TLR, 
    BLR, 
    TBLR, 
    None
}

public enum Color {
  RED, 
    VIOLET, 
    BLUE, 
    GREEN, 
    BLACK
}

// A Screen is the area of map the player is currently in.
public class Screen {
  // Position in map array
  int i, j;
  // Doors in the current room
  boolean t, b, l, r;
  DoorConfig dc;
  PImage background;

  Screen(DoorConfig dc, int i, int j) {
    this.dc = dc;
    this.i = i;
    this.j = j;
    this.t = topDoor(dc);
    this.b = bottomDoor(dc);
    this.l = leftDoor(dc);
    this.r = rightDoor(dc);
  }

  public void drawBG() {
    bg(this.dc);
  }
}

// Represents a single cell on the map
public class Cell {
  DoorConfig dc;
  boolean t, b, l, r;
  int i;
  int j;

  Cell(int i, int j) {
    this.i = i;
    this.j = j;
    this.dc = DoorConfig.None;
    //dungeon.get(i).get(j).dc;
    //this.t = true;
    //this.l = true;
    //this.b = true;
    //this.r = true;
  }

  public void setDoors(DoorConfig config) {
    this.dc = config;
  }

  public void editDoor(Direction d) {
    this.dc = doorToConfig(this.dc, d); 
    this.t = topDoor(dc);
    this.b = bottomDoor(dc);
    this.l = leftDoor(dc);
    this.r = rightDoor(dc);
  }

  public void drawCell() {
    noFill();
    stroke(171, 160, 132);
    strokeWeight(1);
    rect((i * 100) + mapX, (j * 50) + mapY, 100, 50);
    
    strokeWeight(3);
    drawPath(this.i, this.j, this.dc);

  }
}

public class Creature {
  float size; 
  float speed;
  int health;
  int xPos, yPos;

  int xMin, xMax, yMin, yMax;

  boolean up, down, left, right, run;
  boolean idleU, idleD, idleL, idleR;
  boolean isWalking;

  int buffer;

  Creature(float size, float speed, int health, int xPos, int yPos) {
    this.size = size;
    this.speed = speed;
    this.health = health;
    this.xPos = xPos;
    this.yPos = yPos;

    this.setHitBox();
    buffer = (int)this.speed;
    this.idleD = true;
  }

  public boolean collidingUp(DoorConfig dc) {
    return collide(dc, this.xMin, this.xMax, this.yMin - buffer, this.yMax);
  }

  public boolean collidingDown(DoorConfig dc) {
    return collide(dc, this.xMin, this.xMax, this.yMin, this.yMax + buffer);
  }

  public boolean collidingLeft(DoorConfig dc) {
    return collide(dc, this.xMin - buffer, this.xMax, this.yMin, this.yMax);
  }

  public boolean collidingRight(DoorConfig dc) {
    return collide(dc, this.xMin, this.xMax + buffer, this.yMin, this.yMax);
  }

  // Walk one step (or two if running) in direction the creature is currently moving
  public void walk() {
    DoorConfig dc = currentScreen.dc;
    this.setHitBox();
    this.travel();
    if (this.up && !this.collidingUp(dc)) {
      if (this.run) {
        this.yPos -= this.speed * 2;
      } else {
        this.yPos -= this.speed;
      }
    }
    if (this.down && !this.collidingDown(dc)) {
      if (this.run) {
        this.yPos += this.speed * 2;
      } else {
        this.yPos += this.speed;
      }
    }
    if (this.left && !this.collidingLeft(dc)) {
      if (this.run) {
        this.xPos -= this.speed * 2;
      } else {
        this.xPos -= this.speed;
      }
    }
    if (this.right && !this.collidingRight(dc)) {
      if (this.run) {
        this.xPos += this.speed * 2;
      } else {
        this.xPos += this.speed;
      }
    }
  }

  // Move or stop moving in a given direction
  public void move(Direction d, boolean move) {
    switch(d) {
    case DUP:
      this.up = move;
      if (move) {
        this.idleU = true;
        this.idleD = false;
        this.idleL = false;
        this.idleR = false;
      }
      break;
    case DDOWN:
      this.down = move;
      if (move) {
        this.idleU = false;
        this.idleD = true;
        this.idleL = false;
        this.idleR = false;
      }
      break;
    case DLEFT:
      this.left = move;
      if (move) {
        this.idleU = false;
        this.idleD = false;
        this.idleL = true;
        this.idleR = false;
      }
      break;
    case DRIGHT:
      this.right = move;
      if (move) {
        this.idleU = false;
        this.idleD = false;
        this.idleL = false;
        this.idleR = true;
      }
      break;
    }
  }

  public void setHitBox() {
    this.xMin = xPos - ((int)size/3);
    this.xMax = xPos + ((int)size/3);
    this.yMin = yPos - ((int)size/2);
    this.yMax = yPos + ((int)size/2);
  }

  public void travel() {
    int buffer = (int)this.speed;
    if (this.up) {
      if (edge(Direction.DUP, this.xMin, this.xMax, this.yMin - buffer, this.yMax)) {
        changeScreen(Direction.DUP);
        this.yPos = sHeight - buffer;
      }
    }
    if (this.down) {
      if (edge(Direction.DDOWN, this.xMin, this.xMax, this.yMin, this.yMax + buffer)) {
        changeScreen(Direction.DDOWN);
        this.yPos = buffer;
      }
    }
    if (this.left) {
      if (edge(Direction.DLEFT, this.xMin - buffer, this.xMax, this.yMin, this.yMax)) {
        changeScreen(Direction.DLEFT);
        this.xPos = sWidth - buffer;
      }
    }
    if (this.right) {
      if (edge(Direction.DRIGHT, this.xMin, this.xMax + buffer, this.yMin, this.yMax)) {
        changeScreen(Direction.DRIGHT);
        this.xPos = buffer;
      }
    }
  }
}

public class Player extends Creature {
  PImage[] idleUp, idleDown, idleLeft, idleRight;
  PImage[] walkUp, walkDown, walkLeft, walkRight;

  int walkFrameInterval = 12;
  int idleFrameInterval = 20;

  Player(float size, float speed, int health, int xPos, int yPos) {
    super(size, speed, health, xPos, yPos);

    this.idleUp = pIdleUp;
    this.idleDown = pIdleDown;
    this.idleLeft = pIdleLeft;
    this.idleRight = pIdleRight;
    this.walkUp = pWalkUp;
    this.walkDown = pWalkDown;
    this.walkLeft = pWalkLeft;
    this.walkRight = pWalkRight;
  }

  public void animate() {
    this.isWalking = (this.up || this.down || this.left || this.right);
    if (!this.isWalking) {
      if (this.idleU) {
        this.drawFrame(this.idleUp[frameCount/idleFrameInterval % this.idleUp.length]);
      } else if (this.idleL) {
        this.drawFrame(this.idleLeft[frameCount/idleFrameInterval % this.idleLeft.length]);
      } else if (this.idleR) {
        this.drawFrame(this.idleRight[frameCount/idleFrameInterval % this.idleRight.length]);
      } else if (this.idleD) {
        this.drawFrame(this.idleDown[frameCount/idleFrameInterval % this.idleDown.length]);
      }
    } else {
      super.walk();
      if (this.up) {
        this.drawFrame(this.walkUp[frameCount/walkFrameInterval % this.walkUp.length]);
      } else if (this.down) {
        this.drawFrame(this.walkDown[frameCount/walkFrameInterval % this.walkDown.length]);
      } else if (this.left) {
        this.drawFrame(this.walkLeft[frameCount/walkFrameInterval % this.walkLeft.length]);
      } else if (this.right) { 
        this.drawFrame(this.walkRight[frameCount/walkFrameInterval % this.walkRight.length]);
      }
    }
  }

  public void move(Direction d, boolean move) {
    super.move(d, move);
  }

  public void drawFrame(PImage frame) {
    image(frame, this.xPos, this.yPos, this.size, this.size);
  }
}

// Load map from JSON
public void loadMapVals() {
  mapVals = loadJSONArray("Map.json");
}

// Create the screens in the dungeon
public void createDungeon() {
  for (int i = 0; i < MAPX; i++) {
    ArrayList<Screen> row = new ArrayList<Screen>();
    JSONArray mapRow = mapVals.getJSONArray(i);
    for (int j = 0; j < MAPY; j++) {
      JSONObject screen = mapRow.getJSONObject(j);
      row.add(new Screen(strToDoorConfig(screen.getString("doorConfig")), screen.getInt("i"), screen.getInt("j")));
    }
    dungeon.add(row);
  }
}

// Create the cells on the map
public void createMap() {
  for (int i = 0; i < 8; i++) {
    ArrayList<Cell> row = new ArrayList<Cell>();
    for (int j = 0; j < 9; j++) {
      row.add(new Cell(i, j));
    }
    map.add(row);
  }
}

/*
- figure out what wall the mouse is on and which cell/cells it belongs to
 - if on the very top, bottom , right or left, only one cell gets a new door
 - otherwise two cells get a new door
 
 */

// Represents the top/left edges of the map grid
int mapX = 215;
int mapY = 159;

// Draw a door on the map
public void drawDoor() {
}


public void showMap() {
  int penX = mouseX - 35;
  int penY = mouseY + 35;
  fill(209, 192, 155);
  rectMode(CENTER);
  strokeWeight(1);
  rect(sWidth/2, sHeight/2, 1000, 600);

  rectMode(CORNER);
  noFill();
  stroke(171, 160, 132);
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 9; j++) {
      Cell currentCell = map.get(i).get(j);
      currentCell.drawCell();
      stroke(171, 160, 132);
      if (penColor == Color.BLACK) {
        if (penX > mapX + 10 && penY > mapY + 10) {
          strokeWeight(3);
          if (penX >= i*100 + mapX && penX <= i*100 + mapX + 100 && penY >= j*50 + mapY - 10 && penY <= j*50 + mapY + 10) {
            line(i*100 + mapX + 40, j*50 + mapY - 5, i*100 + mapX + 40, j*50 + mapY + 5);
            line(i*100 + mapX + 60, j*50 + mapY - 5, i*100 + mapX + 60, j*50 + mapY + 5);
          } else if (penX >= i*100 + mapX - 10 && penX <= i*100 + mapX + 10 && penY >= j*50 + mapY && penY < j*50 + mapY + 50) {
            line(i*100 + mapX - 5, j*50 + mapY + 15, i*100 + mapX + 5, j*50 + mapY + 15);
            line(i*100 + mapX - 5, j*50 + mapY + 35, i*100 + mapX + 5, j*50 + mapY + 35);
          }
        }
      }
    }
  }

  drawInk(sWidth - 220, sHeight - 196, 68);
  drawPen(penColor, 128);

  fill(0);
  textFont(merchant32);
  text(str(penX - mapX) + ", " + str(penY - mapY), mapX, mapY - 20);
}

public void editDoors() {
  int penX = mouseX - 35;
  int penY = mouseY + 35;
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 9; j++) {
      if (penColor == Color.BLACK) {
        if (penX > mapX + 10 && penY > mapY + 10) {
          if (penX >= i*100 + mapX && penX <= i*100 + mapX + 100 && penY >= j*50 + mapY - 10 && penY <= j*50 + mapY + 10) {
            map.get(i).get(j-1).editDoor(Direction.DDOWN);
            map.get(i).get(j).editDoor(Direction.DUP);
          } else if (penX >= i*100 + mapX - 10 && penX <= i*100 + mapX + 10 && penY >= j*50 + mapY && penY < j*50 + mapY + 50) {
            map.get(i-1).get(j).editDoor(Direction.DRIGHT);
            map.get(i).get(j).editDoor(Direction.DLEFT);
          }
        }
      }
    }
  }
}

public void drawPen(Color c, int size) {
  switch(c) {
  case RED:
    image(quill[1], mouseX, mouseY, size, size);
    break;
  case VIOLET:
    image(quill[2], mouseX, mouseY, size, size);
    break;
  case BLUE:
    image(quill[3], mouseX, mouseY, size, size);
    break;
  case GREEN:
    image(quill[4], mouseX, mouseY, size, size);
    break;
  case BLACK:
    image(quill[0], mouseX, mouseY, size, size);
    break;
  }
}

public void drawInk(int xPos, int yPos, int size) {
  image(ink[4], xPos, yPos, size, size);
  image(ink[3], xPos, yPos - 60, size, size);
  image(ink[2], xPos, yPos - 120, size, size);
  image(ink[1], xPos, yPos - 180, size, size);
  image(ink[0], xPos, yPos - 400, size, size);
}


/* hitbox = mouse X - 35 -> mouse X - 15 mouse Y + 15 -> mouse X + 35 */
/* ink hitbox
 red: x > sWidth - 220 - 34 -> sWidth - 186, x > 
 
 */
public void changePenColor() {
  int penXMin = mouseX - 35;
  int penXMax = mouseX - 15;
  int penYMin = mouseY + 15;
  int penYMax = mouseY + 35;
  int inkXMin = sWidth - 254;
  int inkXMax = sWidth - 186;
  int inkYPos = sHeight - 196;
  boolean penX = (penXMin >= inkXMin && penXMax <= inkXMax);
  if (penX) {
    if (penYMin >= inkYPos - 214 && penYMax <= inkYPos - 146) {
      penColor = Color.RED;
    } else if (penYMin >= inkYPos - 154 && penYMax <= inkYPos - 86) {
      penColor = Color.VIOLET;
    } else if (penYMin >= inkYPos - 94 && penYMax <= inkYPos - 26) {
      penColor = Color.BLUE;
    } else if (penYMin >= inkYPos - 34 && penYMax <= inkYPos + 46) {
      penColor = Color.GREEN;
    } else if (penYMin >= inkYPos - 434 && penYMax <= inkYPos + 366) {
      penColor = Color.BLACK;
    }
  }
}

// e.g. 'T' -> DoorConfig.T
public DoorConfig strToDoorConfig(String str) {
  return DoorConfig.valueOf(str);
}

// Switch to the next screen in the specified direction if one exists
public void changeScreen(Direction d) {
  switch(d) {
  case DUP:
    if (currentScreen.j > 0) {
      currentScreen = dungeon.get(currentScreen.i).get(currentScreen.j - 1);
    }
    break;
  case DDOWN:
    if (currentScreen.j < MAPY - 1) {
      currentScreen = dungeon.get(currentScreen.i).get(currentScreen.j + 1);
    }
    break;
  case DLEFT:
    if (currentScreen.i > 0) {
      currentScreen = dungeon.get(currentScreen.i - 1).get(currentScreen.j);
    }
    break;
  case DRIGHT:
    if (currentScreen.i < MAPX - 1) {
      currentScreen = dungeon.get(currentScreen.i + 1).get(currentScreen.j);
    }
    break;
  }
}

// Load Player spritesheets
public void loadSprites() {
  pIdleUpSS = loadImage("IdleUp.png");
  pIdleDownSS = loadImage("IdleDown.png");
  pIdleLeftSS = loadImage("IdleLeft.png");
  pIdleRightSS = loadImage("IdleRight.png");
  pWalkUpSS = loadImage("WalkUp.png");
  pWalkDownSS = loadImage("WalkDown.png");
  pWalkLeftSS = loadImage("WalkLeft.png");
  pWalkRightSS = loadImage("WalkRight.png");
  inkSS = loadImage("Ink.png");
  quillSS = loadImage("Quill.png");

  int PIW = pIdleUpSS.width/PID;
  int PIH = pIdleUpSS.height;

  int PWW = pWalkUpSS.width/PWD;
  int PWH = pWalkUpSS.height;

  int IW = inkSS.width/5;
  int IH = inkSS.height;

  int QW = quillSS.width/5;
  int QH = quillSS.height;

  // Populate Player sprite animations
  for (int i = 0; i < pIdleUp.length; i++) {
    pIdleUp[i] = pIdleUpSS.get(i%PID*PIW, i/PIH, PIW, PIH);
  }
  for (int i = 0; i < pIdleDown.length; i++) {
    pIdleDown[i] = pIdleDownSS.get(i%PID*PIW, i/PIH, PIW, PIH);
  }
  for (int i = 0; i < pIdleLeft.length; i++) {
    pIdleLeft[i] = pIdleLeftSS.get(i%PID*PIW, i/PIH, PIW, PIH);
  }
  for (int i = 0; i < pIdleRight.length; i++) {
    pIdleRight[i] = pIdleRightSS.get(i%PID*PIW, i/PIH, PIW, PIH);
  }
  for (int i = 0; i < pWalkUp.length; i++) {
    pWalkUp[i] = pWalkUpSS.get(i%PWD*PWW, i/PWH, PWW, PWH);
  }
  for (int i = 0; i < pWalkDown.length; i++) {
    pWalkDown[i] = pWalkDownSS.get(i%PWD*PWW, i/PWH, PWW, PWH);
  }
  for (int i = 0; i < pWalkLeft.length; i++) {
    pWalkLeft[i] = pWalkLeftSS.get(i%PWD*PWW, i/PWH, PWW, PWH);
  }
  for (int i = 0; i < pWalkRight.length; i++) {
    pWalkRight[i] = pWalkRightSS.get(i%PWD*PWW, i/PWH, PWW, PWH);
  }

  // Populate ink and quills sprites
  for (int i = 0; i < quill.length; i++) {
    quill[i] = quillSS.get(i%5*QW, i/QH, QW, QH);
    ink[i] = inkSS.get(i%5*IW, i/IH, IW, IH);
  }
}
//frameCount/DIM%DIM*H;
// Load backgrounds
public void loadBackgrounds() {
  T = loadImage("T.png");
  B = loadImage("B.png");
  L = loadImage("L.png");
  R = loadImage("R.png");
  TB = loadImage("TB.png");
  TL = loadImage("TL.png");
  TR = loadImage("TR.png");
  BL = loadImage("BL.png");
  BR = loadImage("BR.png");
  LR = loadImage("LR.png");
  TBL = loadImage("TBL.png");
  TBR = loadImage("TBR.png");
  TLR = loadImage("TLR.png");
  BLR = loadImage("BLR.png");
  TBLR = loadImage("TBLR.png");
}



// Assign doors
public boolean topDoor(DoorConfig dc) {
  return (dc == DoorConfig.T || dc == DoorConfig.TL || dc == DoorConfig.TB ||
    dc == DoorConfig.TR || dc == DoorConfig.TLR || dc == DoorConfig.TBL || 
    dc == DoorConfig.TBR || dc == DoorConfig.TBLR);
}

public boolean bottomDoor(DoorConfig dc) {
  return (dc == DoorConfig.B || dc == DoorConfig.TB || dc == DoorConfig.BL ||
    dc == DoorConfig.BR || dc == DoorConfig.TBL || dc == DoorConfig.TBR ||
    dc == DoorConfig.BLR || dc == DoorConfig.TBLR);
}

public boolean leftDoor(DoorConfig dc) {
  return (dc == DoorConfig.L || dc == DoorConfig.TL || dc == DoorConfig.BL ||
    dc == DoorConfig.LR || dc == DoorConfig.TBL || dc == DoorConfig.BLR || 
    dc == DoorConfig.TLR || dc == DoorConfig.TBLR);
}

public boolean rightDoor(DoorConfig dc) {
  return (dc == DoorConfig.R || dc == DoorConfig.TR || dc == DoorConfig.BR ||
    dc == DoorConfig.LR || dc == DoorConfig.TBR || dc == DoorConfig.BLR ||
    dc == DoorConfig.TLR || dc == DoorConfig.TBLR);
}

public void drawPath(int i, int j, DoorConfig dc) {
  switch(dc) {
  case None:
    break;
  case T:
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 35);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 35);
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 35);
    break;
  case B:
    line(i*100 + mapX + 40, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 60, j*50 + mapY + 50);
    line(i*100 + mapX + 40, j*50 + mapY + 15, i*100 + mapX + 60, j*50 + mapY + 15);
    break;
  case L:
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 60, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 35);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 60, j*50 + mapY + 35);
    break;
  case R:
    line(i*100 + mapX + 40, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    line(i*100 + mapX + 40, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 35);
    break;
  case TL:
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 35);
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 35);
    break;
  case TB:
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 50);
    break;
  case TR:
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 35);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    break;
  case BL:
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 60, j*50 + mapY + 50);
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 60, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 35);
    break;
  case BR:
    line(i*100 + mapX + 40, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 50);
    line(i*100 + mapX + 40, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    break;
  case LR:
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    break;
  case TLR:
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    break;
  case TBL:
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 50);
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 35);
    break;
  case TBR:
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 50);
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    break;
  case BLR:
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 35);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 50);
    break;
  case TBLR:
    line(i*100 + mapX, j*50 + mapY + 15, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY + 15, i*100 + mapX + 100, j*50 + mapY + 15);
    line(i*100 + mapX, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 35);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 100, j*50 + mapY + 35);
    line(i*100 + mapX + 40, j*50 + mapY, i*100 + mapX + 40, j*50 + mapY + 15);
    line(i*100 + mapX + 60, j*50 + mapY, i*100 + mapX + 60, j*50 + mapY + 15);
    line(i*100 + mapX + 40, j*50 + mapY + 35, i*100 + mapX + 40, j*50 + mapY + 50);
    line(i*100 + mapX + 60, j*50 + mapY + 35, i*100 + mapX + 60, j*50 + mapY + 50);
    break;
  }
}

public boolean collide(DoorConfig dc, int xMin, int xMax, int yMin, int yMax) {
  switch(dc) {
  case T:
    return left(xMin) || bottom(yMax) || right(xMax) 
      || topLeftTop(xMin, yMin) || topRightTop(xMax, yMin);
  case B:
    return top(yMin) || left(xMin) || right(xMax)
      || bottomLeftBottom(xMin, yMax) || bottomRightBottom(xMax, yMax);
  case L:
    return top(yMin) || bottom(yMax) || right(xMax)
      || topLeftLeft(xMin, yMin) || bottomLeftLeft(xMin, yMax);
  case R:
    return top(yMin) || bottom(yMax) || left(xMin)
      || topRightRight(xMax, yMin) || bottomRightRight(xMax, yMax);
  case TL:
    return right(xMax) || bottom(yMax)
      || topRightTop(xMax, yMin) || topLeftTop(xMin, yMin)
      || topLeftLeft(xMin, yMin) || bottomLeftLeft(xMin, yMax);
  case TB:
    return left(xMin) || right(xMax)
      || topLeftTop(xMin, yMin) || topRightTop(xMax, yMin)
      || bottomLeftBottom(xMin, yMax) || bottomRightBottom(xMax, yMax);
  case TR:
    return left(xMin) || bottom(yMax)
      || topLeftTop(xMin, yMin) || topRightTop(xMax, yMin)
      || topRightRight(xMax, yMin) || bottomRightRight(xMax, yMax);
  case BL:
    return top(yMin) || right(xMax)
      || topLeftLeft(xMin, yMin) || bottomLeftLeft(xMin, yMax)
      || bottomLeftBottom(xMin, yMax) || bottomRightBottom(xMax, yMax);
  case BR:
    return top(yMin) || left(xMin)
      || topRightRight(xMax, yMin) || bottomRightRight(xMax, yMax)
      || bottomRightBottom(xMax, yMax) || bottomLeftBottom(xMin, yMax);
  case LR:
    return top(yMin) || bottom(yMax)
      || topLeftLeft(xMin, yMin) || topRightRight(xMax, yMin)
      || bottomLeftLeft(xMin, yMax) || bottomRightRight(xMax, yMax);
  case TLR:
    return bottom(yMax) || bottomLeftLeft(xMin, yMax)
      || topLeftLeft(xMin, yMin) || topLeftTop(xMin, yMin)
      || topRightTop(xMax, yMin) || topRightRight(xMax, yMin)
      || bottomRightRight(xMax, yMax);
  case TBL:
    return right(xMax) || topRightTop(xMax, yMin)
      || topLeftTop(xMin, yMin) || topLeftLeft(xMin, yMin)
      || bottomLeftLeft(xMin, yMax) || bottomLeftBottom(xMin, yMax)
      || bottomRightBottom(xMax, yMax);
  case TBR:
    return left(xMin) || topLeftTop(xMin, yMin)
      || topRightTop(xMax, yMin) || topRightRight(xMax, yMin)
      || bottomRightRight(xMax, yMax) || bottomRightBottom(xMax, yMax)
      || bottomLeftBottom(xMin, yMax);
  case BLR:
    return top(yMin) || topLeftLeft(xMin, yMin)
      || bottomLeftLeft(xMin, yMax) || bottomLeftBottom(xMin, yMax)
      || bottomRightBottom(xMax, yMax) || bottomRightRight(xMax, yMax)
      || topRightRight(xMax, yMin);
  case TBLR:
    return topLeftTop(xMin, yMin) || topLeftLeft(xMin, yMin)
      || topRightTop(xMax, yMin) || topRightRight(xMax, yMin)
      || bottomRightRight(xMax, yMax) || bottomRightBottom(xMax, yMax)
      || bottomLeftLeft(xMin, yMax) || bottomLeftBottom(xMin, yMax);
  default:
    return false;
  }
}

// Collision values for ledges/walls
public boolean top(int yMin) {
  return (0 <= yMin && yMin <= 88);
}

public boolean bottom(int yMax) {
  return (672 <= yMax && yMax <= sHeight);
}

public boolean left(int xMin) {
  return (0 <= xMin && xMin < 144);
}

public boolean right(int xMax) {
  return (1136 <= xMax && xMax <= sWidth);
}

public boolean topLeftTop(int xMin, int yMin) {
  return (0 <= xMin && xMin <= 544 && 0 <= yMin && yMin <= 88);
}

public boolean topLeftLeft(int xMin, int yMin) {
  return (0 <= xMin && xMin <= 136 && 0 <= yMin && yMin <= 280);
}

public boolean topRightTop(int xMax, int yMin) {
  return (752 <= xMax && xMax <= sWidth && 0 <= yMin && yMin <= 88);
}

public boolean topRightRight(int xMax, int yMin) {
  return (1142 <= xMax && xMax <= sWidth && 0 <= yMin && yMin <= 280);
}

public boolean bottomLeftBottom(int xMin, int yMax) {
  return (0 <= xMin && xMin <= 546 && 680 <= yMax && yMax < sHeight);
}

public boolean bottomLeftLeft(int xMin, int yMax) {
  return (0 <= xMin && xMin <= 136 && 488 <= yMax && yMax <= sHeight);
}

public boolean bottomRightBottom(int xMax, int yMax) {
  return (736 <= xMax && xMax <= sWidth && 680 <= yMax && yMax <= sHeight);
}

public boolean bottomRightRight(int xMax, int yMax) {
  return (1142 <= xMax && xMax <= sWidth && 488 <= yMax && yMax <= sHeight);
}

public boolean edge(Direction d, int xMin, int xMax, int yMin, int yMax) {
  switch(d) {
  case DUP:
    return yMin < 0;
  case DDOWN:
    return yMax > sHeight;
  case DLEFT:
    return xMin < 0;
  case DRIGHT:
    return xMax > sWidth;
  default:
    return false;
  }
}

public void bg(DoorConfig dc) {
  switch(dc) {
  case T:
    background(T);
    break;
  case B:
    background(B);
    break;
  case L:
    background(L);
    break;
  case R:
    background(R);
    break;
  case TL:
    background(TL);
    break;
  case TB:
    background(TB);
    break;
  case TR:
    background(TR);
    break;
  case BL:
    background(BL);
    break;
  case BR:
    background(BR);
    break;
  case LR:
    background(LR);
    break;
  case TLR:
    background(TLR);
    break;
  case TBL:
    background(TBL);
    break;
  case TBR:
    background(TBR);
    break;
  case BLR:
    background(BLR);
    break;
  case TBLR:
    background(TBLR);
    break;
  }
}

public DoorConfig doorToConfig(DoorConfig dc, Direction d) {
  switch(dc) {
  case None:
    switch(d) {
    case DUP:
      return DoorConfig.T;
    case DDOWN:
      return DoorConfig.B;
    case DLEFT:
      return DoorConfig.L;
    case DRIGHT:
      return DoorConfig.R;
    }
  case T:
    switch(d) {
    case DUP:
      return DoorConfig.None;
    case DDOWN:
      return DoorConfig.TB;
    case DLEFT:
      return DoorConfig.TL;
    case DRIGHT:
      return DoorConfig.TR;
    }
  case B:
    switch(d) {
    case DUP:
      return DoorConfig.TB;
    case DDOWN:
      return DoorConfig.None;
    case DLEFT:
      return DoorConfig.BL;
    case DRIGHT:
      return DoorConfig.BR;
    }
  case L:
    switch(d) {
    case DUP:
      return DoorConfig.TL;
    case DDOWN:
      return DoorConfig.BL;
    case DLEFT:
      return DoorConfig.None;
    case DRIGHT:
      return DoorConfig.LR;
    }
  case R:
    switch(d) {
    case DUP:
      return DoorConfig.TR;
    case DDOWN:
      return DoorConfig.BR;
    case DLEFT:
      return DoorConfig.LR;
    case DRIGHT:
      return DoorConfig.None;
    }
  case TL:
    switch(d) {
    case DUP:
      return DoorConfig.L;
    case DDOWN:
      return DoorConfig.TBL;
    case DLEFT:
      return DoorConfig.T;
    case DRIGHT:
      return DoorConfig.TLR;
    }
  case TB:
    switch(d) {
    case DUP:
      return DoorConfig.B;
    case DDOWN:
      return DoorConfig.T;
    case DLEFT:
      return DoorConfig.TBL;
    case DRIGHT:
      return DoorConfig.TBR;
    }
  case TR:
    switch(d) {
    case DUP:
      return DoorConfig.R;
    case DDOWN:
      return DoorConfig.TBR;
    case DLEFT:
      return DoorConfig.TLR;
    case DRIGHT:
      return DoorConfig.T;
    }
  case BL:
    switch(d) {
    case DUP:
      return DoorConfig.TBL;
    case DDOWN:
      return DoorConfig.L;
    case DLEFT:
      return DoorConfig.B;
    case DRIGHT:
      return DoorConfig.BLR;
    }
  case BR:
    switch(d) {
    case DUP:
      return DoorConfig.TBR;
    case DDOWN:
      return DoorConfig.R;
    case DLEFT:
      return DoorConfig.BLR;
    case DRIGHT:
      return DoorConfig.B;
    }
  case LR:
    switch(d) {
    case DUP:
      return DoorConfig.TLR;
    case DDOWN:
      return DoorConfig.BLR;
    case DLEFT:
      return DoorConfig.R;
    case DRIGHT:
      return DoorConfig.L;
    }
  case TLR:
    switch(d) {
    case DUP:
      return DoorConfig.LR;
    case DDOWN:
      return DoorConfig.TBLR;
    case DLEFT:
      return DoorConfig.TR;
    case DRIGHT:
      return DoorConfig.TL;
    }
  case TBL:
    switch(d) {
    case DUP:
      return DoorConfig.BL;
    case DDOWN:
      return DoorConfig.TL;
    case DLEFT:
      return DoorConfig.TB;
    case DRIGHT:
      return DoorConfig.TBLR;
    }
  case TBR:
    switch(d) {
    case DUP:
      return DoorConfig.BR;
    case DDOWN:
      return DoorConfig.TR;
    case DLEFT:
      return DoorConfig.TBLR;
    case DRIGHT:
      return DoorConfig.TB;
    }
  case BLR:
    switch(d) {
    case DUP:
      return DoorConfig.TBLR;
    case DDOWN:
      return DoorConfig.LR;
    case DLEFT:
      return DoorConfig.BR;
    case DRIGHT:
      return DoorConfig.BL;
    }
  case TBLR:
    switch(d) {
    case DUP:
      return DoorConfig.BLR;
    case DDOWN:
      return DoorConfig.TLR;
    case DLEFT:
      return DoorConfig.TBR;
    case DRIGHT:
      return DoorConfig.TBL;
    }
  default:
    return DoorConfig.None;
  }
}

/*
sWidth = 1280
sHeight = 768

map width = 1000
left margin, right margin = 140
map height = 600
top margin, right margin = 84

map square height = 50
total map height = 450
map square width = 100
total map width = 700

map margins = 75
map xMin = 140 + 75 = 215
map yMin = 84 + 75 = 159
*/

/*void changePenColor(Color current, Direction d) {
   switch(current) {
      case RED:
        if (d == Direction.DDOWN) {
          penColor = Color.VIOLET;
        } else if (d == Direction.DUP) {
          penColor = Color.GREEN; 
        }
        break;
      case VIOLET:
        if (d == Direction.DDOWN) {
          penColor = Color.BLUE;
        } else if (d == Direction.DUP) {
          penColor = Color.RED; 
        }
        break;
      case BLUE:
        if (d == Direction.DDOWN) {
          penColor = Color.GREEN;
        } else if (d == Direction.DUP) {
          penColor = Color.VIOLET; 
        }
        break;
      case GREEN:
        if (d == Direction.DDOWN) {
          penColor = Color.RED;
        } else if (d == Direction.DUP) {
          penColor = Color.BLUE; 
        }
        break;
   }
}


*/
  
  //switch(c) {
  //  case RED:
  //    image(quill[4], xPos, sHeight - 230, size, size);
  //    image(quill[1], xPos, sHeight - 290, size, size);
  //    image(quill[2], xPos, sHeight - 350, size, size);
  //    image(quill[3], xPos, sHeight - 410, size, size);
  //    break;
  //  case VIOLET:
  //    image(quill[0], xPos, sHeight - 230, size, size);
  //    image(quill[5], xPos, sHeight - 290, size, size);
  //    image(quill[2], xPos, sHeight - 350, size, size);
  //    image(quill[3], xPos, sHeight - 410, size, size);
  //    break;
  //  case BLUE:
  //    image(quill[0], xPos, sHeight - 230, size, size);
  //    image(quill[1], xPos, sHeight - 290, size, size);
  //    image(quill[6], xPos, sHeight - 350, size, size);
  //    image(quill[3], xPos, sHeight - 410, size, size);
  //    break;
  //  case GREEN:
  //    image(quill[0], xPos, sHeight - 230, size, size);
  //    image(quill[1], xPos, sHeight - 290, size, size);
  //    image(quill[2], xPos, sHeight - 350, size, size);
  //    image(quill[7], xPos, sHeight - 410, size, size);
  //    break;
  //  default:
  //    image(quill[0], xPos, sHeight - 230, size, size);
  //    image(quill[1], xPos, sHeight - 290, size, size);
  //    image(quill[2], xPos, sHeight - 350, size, size);
  //    image(quill[3], xPos, sHeight - 410, size, size);
  //    break;
  //}
  public void settings() {  size(1280, 768); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Dungeon2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
