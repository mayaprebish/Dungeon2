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

// A Screen is the area of map the player is currently in.
public class Screen {
  // Doors in the current room
  boolean t, b, l, r;
  PImage background;
  
  Screen(boolean top, boolean bottom, boolean left, boolean right) {
    this.t = top;
    this.b = bottom;
    this.l = left;
    this.r = right;
  }
}

public class Creature {
  float speed;
  int health;
  int xPos, yPos;
  boolean up, down, left, right, run;
  boolean idleU, idleL, idleR;

  Creature(float speed, int health, int xPos, int yPos) {
    this.speed = speed;
    this.health = health;
    this.xPos = xPos;
    this.yPos = yPos;
  }

  // Walk one step (or two if running) in direction the creature is currently moving
  void walk() {
    if (this.left) {
      if (this.run) {
        this.xPos -= this.speed * 2;
      } else {
        this.xPos -= this.speed;
      }
    }
    if (this.right) {
      if (this.run) {
        this.xPos += this.speed * 2;
      } else {
        this.xPos += this.speed;
      }
    }
    if (this.up) {
      if (this.run) {
        this.yPos -= this.speed * 2;
      } else {
        this.yPos -= this.speed;
      }
    }
    if (this.down) {
      if (this.run) {
        this.yPos += this.speed * 2;
      } else {
        this.yPos += this.speed;
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
        this.idleL = false;
        this.idleR = false;
      }
      break;
    case DDOWN:
      this.down = move;
      if (move) {
        this.idleU = false;
        this.idleL = false;
        this.idleR = false;
      }
      break;
    case DLEFT:
      this.left = move;
      if (move) {
        this.idleU = false;
        this.idleL = true;
        this.idleR = false;
      }
      break;
    case DRIGHT:
      this.right = move;
      if (move) {
        this.idleU = false;
        this.idleL = false;
        this.idleR = true;
      }
      break;
    }
  }
}

public class Player extends Creature {
  PImage[] idleUp, idleDown, idleLeft, idleRight;
  PImage[] walkUp, walkDown, walkLeft, walkRight;

  int walkFrameInterval = 12;
  int idleFrameInterval = 20;

  Player(float speed, int health, int xPos, int yPos) {
    super(speed, health, xPos, yPos);

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
    if (this.idleU) {
      if (this.up) {
        super.walk();
        this.drawFrame(this.walkUp[frameCount/walkFrameInterval % this.walkUp.length]);
      } else {
        this.drawFrame(this.idleUp[frameCount/idleFrameInterval % this.idleUp.length]);
      }
    } else if (this.idleL) {
      if (this.left) {
        super.walk();
        this.drawFrame(this.walkLeft[frameCount/walkFrameInterval % this.walkLeft.length]);
      } else {
        this.drawFrame(this.idleLeft[frameCount/idleFrameInterval % this.idleLeft.length]);
      }
    } else if (this.down) {
      super.walk();
      this.drawFrame(this.walkDown[frameCount/walkFrameInterval % this.walkDown.length]);
    } else if (this.idleR) {
      if (this.right) {
        super.walk();
        this.drawFrame(this.walkRight[frameCount/walkFrameInterval % this.walkRight.length]);
      } else {
        this.drawFrame(this.idleRight[frameCount/idleFrameInterval % this.idleRight.length]);
      }
    } else {
      this.drawFrame(this.idleDown[frameCount/idleFrameInterval % this.idleDown.length]);
    }
  }

  void move(Direction d, boolean move) {
    super.move(d, move);
  }

  void drawFrame(PImage frame) {
    image(frame, this.xPos, this.yPos, 128, 128);
  }
}
