// Load map from JSON
void loadMapVals() {
  mapVals = loadJSONArray("Map.json");
}

// Create the screens in the dungeon
void createDungeon() {
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
void createMap() {
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
void drawDoor() {
}


void showMap() {
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

void editDoors() {
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

void drawPen(Color c, int size) {
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

void drawInk(int xPos, int yPos, int size) {
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
void changePenColor() {
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
DoorConfig strToDoorConfig(String str) {
  return DoorConfig.valueOf(str);
}

// Switch to the next screen in the specified direction if one exists
void changeScreen(Direction d) {
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
void loadSprites() {
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
void loadBackgrounds() {
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
boolean topDoor(DoorConfig dc) {
  return (dc == DoorConfig.T || dc == DoorConfig.TL || dc == DoorConfig.TB ||
    dc == DoorConfig.TR || dc == DoorConfig.TLR || dc == DoorConfig.TBL || 
    dc == DoorConfig.TBR || dc == DoorConfig.TBLR);
}

boolean bottomDoor(DoorConfig dc) {
  return (dc == DoorConfig.B || dc == DoorConfig.TB || dc == DoorConfig.BL ||
    dc == DoorConfig.BR || dc == DoorConfig.TBL || dc == DoorConfig.TBR ||
    dc == DoorConfig.BLR || dc == DoorConfig.TBLR);
}

boolean leftDoor(DoorConfig dc) {
  return (dc == DoorConfig.L || dc == DoorConfig.TL || dc == DoorConfig.BL ||
    dc == DoorConfig.LR || dc == DoorConfig.TBL || dc == DoorConfig.BLR || 
    dc == DoorConfig.TLR || dc == DoorConfig.TBLR);
}

boolean rightDoor(DoorConfig dc) {
  return (dc == DoorConfig.R || dc == DoorConfig.TR || dc == DoorConfig.BR ||
    dc == DoorConfig.LR || dc == DoorConfig.TBR || dc == DoorConfig.BLR ||
    dc == DoorConfig.TLR || dc == DoorConfig.TBLR);
}

void drawPath(int i, int j, DoorConfig dc) {
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

boolean collide(DoorConfig dc, int xMin, int xMax, int yMin, int yMax) {
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
boolean top(int yMin) {
  return (0 <= yMin && yMin <= 88);
}

boolean bottom(int yMax) {
  return (672 <= yMax && yMax <= sHeight);
}

boolean left(int xMin) {
  return (0 <= xMin && xMin < 144);
}

boolean right(int xMax) {
  return (1136 <= xMax && xMax <= sWidth);
}

boolean topLeftTop(int xMin, int yMin) {
  return (0 <= xMin && xMin <= 544 && 0 <= yMin && yMin <= 88);
}

boolean topLeftLeft(int xMin, int yMin) {
  return (0 <= xMin && xMin <= 136 && 0 <= yMin && yMin <= 280);
}

boolean topRightTop(int xMax, int yMin) {
  return (752 <= xMax && xMax <= sWidth && 0 <= yMin && yMin <= 88);
}

boolean topRightRight(int xMax, int yMin) {
  return (1142 <= xMax && xMax <= sWidth && 0 <= yMin && yMin <= 280);
}

boolean bottomLeftBottom(int xMin, int yMax) {
  return (0 <= xMin && xMin <= 546 && 680 <= yMax && yMax < sHeight);
}

boolean bottomLeftLeft(int xMin, int yMax) {
  return (0 <= xMin && xMin <= 136 && 488 <= yMax && yMax <= sHeight);
}

boolean bottomRightBottom(int xMax, int yMax) {
  return (736 <= xMax && xMax <= sWidth && 680 <= yMax && yMax <= sHeight);
}

boolean bottomRightRight(int xMax, int yMax) {
  return (1142 <= xMax && xMax <= sWidth && 488 <= yMax && yMax <= sHeight);
}

boolean edge(Direction d, int xMin, int xMax, int yMin, int yMax) {
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

void bg(DoorConfig dc) {
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

DoorConfig doorToConfig(DoorConfig dc, Direction d) {
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
