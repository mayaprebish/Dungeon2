// Load map from JSON
void loadMapVals() {
  mapVals = loadJSONArray("Map.json");
}

// Draw map
void createMap() {
  for (int i = 0; i < MAPDIM; i++) {
    ArrayList<Screen> row = new ArrayList<Screen>();
    JSONArray mapRow = mapVals.getJSONArray(i);
    for (int j = 0; j < MAPDIM; j++) {
      JSONObject screen = mapRow.getJSONObject(j);
      row.add(new Screen(strToDoorConfig(screen.getString("doorConfig")), screen.getInt("i"), screen.getInt("j")));
    }
    map.add(row);
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
         print(currentScreen.j);
         currentScreen = map.get(currentScreen.i).get(currentScreen.j - 1);
       }
       break;
     case DDOWN:
       if (currentScreen.j < MAPDIM - 1) {
         currentScreen = map.get(currentScreen.i).get(currentScreen.j + 1);
       }
       break;
     case DLEFT:
       if (currentScreen.i > 0) {
         currentScreen = map.get(currentScreen.i - 1).get(currentScreen.j);
       }
       break;
     case DRIGHT:
       if (currentScreen.i < MAPDIM - 1) {
         currentScreen = map.get(currentScreen.i + 1).get(currentScreen.j); 
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

  int PIW = pIdleUpSS.width/PID;
  int PIH = pIdleUpSS.height;

  int PWW = pWalkUpSS.width/PWD;
  int PWH = pWalkUpSS.height;

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
}

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

/*
TBLR:
top top left ledge = 544x96 (0 <= x <= 544), (0 <= y <= 96)
top top right ledge = 528x88 (752 <= x <= 1280), (0 <= y <= 88)
top left left ledge = 136x280 (0 <= x <= 136), (0 <= y <= 280)
top right right ledge = 144x280 (1136 <= x <= 1280), (0 <= y <= 280)
bottom left left ledge = 136x280 (0 <= x <= 136), (488 <= y <= 768)
bottom bottom left ledge = 536x88 (0 <= x <= 536), (680 <= y <= 768)
bottom right right ledge = 144x280 (1136 <= x <= 1280), (488 <= y <= 768)
bottom bottom right ledge = 544x88 (736 <= x <= 1280), (680 <= y <= 768)

TBR:
left ledge = 144x768 (0 <= x <= 144)

TBL:
right ledge = 144x768 (1136 <= x <= 1280)

BLR:
top ledge = 1280x104 (0 <= y <= 104)

TLR:
bottom ledge = 1280x96 (672 <= y <= 768)
*/

boolean collide(DoorConfig dc, int x, int y) {
  switch(dc) {
    case T:
      return (0 <= (x-50) && (x-50) <= 544 && 0 <= y && y <= 96) || (0 <= x && x <= 144);
    case B:
      return false;
    case L:
      return false;
    case R:
      return false;
    case TL:
      return false;
    case TB:
      return false;
    case TR:
      return false;
    case BL:
      return false;
    case BR:
      return false;
    case LR:
      return false;
    case TLR:
      return false;
    case TBL:
      return false;
    case TBR:
      return false;
    case BLR:
      return false;
    case TBLR:
      return false;
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
