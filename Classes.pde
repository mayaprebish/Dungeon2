public enum GameState { //<>//
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
    TBLR
}

public enum Color {
  RED,
  VIOLET,
  BLUE,
  GREEN
}

// A Screen is the area of map the player is currently in.
public class Screen {
  // Position in map array
  int i, j;
  // Doors in the current room
  boolean t, b, l, r;
  public DoorConfig dc;
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

  void drawBG() {
    bg(this.dc);
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

  boolean collidingUp(DoorConfig dc) {
    return collide(dc, this.xMin, this.xMax, this.yMin - buffer, this.yMax);
  }

  boolean collidingDown(DoorConfig dc) {
    return collide(dc, this.xMin, this.xMax, this.yMin, this.yMax + buffer);
  }

  boolean collidingLeft(DoorConfig dc) {
    return collide(dc, this.xMin - buffer, this.xMax, this.yMin, this.yMax);
  }

  boolean collidingRight(DoorConfig dc) {
    return collide(dc, this.xMin, this.xMax + buffer, this.yMin, this.yMax);
  }

  // Walk one step (or two if running) in direction the creature is currently moving
  void walk() {
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
  void move(Direction d, boolean move) {
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

  void setHitBox() {
    this.xMin = xPos - ((int)size/3);
    this.xMax = xPos + ((int)size/3);
    this.yMin = yPos - ((int)size/2);
    this.yMax = yPos + ((int)size/2);
  }

  void travel() {
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

  void animate() {
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

  void move(Direction d, boolean move) {
    super.move(d, move);
  }

  void drawFrame(PImage frame) {
    image(frame, this.xPos, this.yPos, this.size, this.size);
  }
}
