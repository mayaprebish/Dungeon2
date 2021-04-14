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
