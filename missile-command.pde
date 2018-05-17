// Missiles and cities arrays

ArrayList<Missile> missiles = new ArrayList<Missile>();
ArrayList<Interceptor> interceptors = new ArrayList<Interceptor>();
City[] cities = new City[4];

// Game timers

int mTime = millis();
int iTime = millis();
int kTime = millis();

// Game text and background

String title = "MISSILE COMMAND";
String message = "See how long you can defend your cities.\nPress any key to begin.";
PImage bg;

// Game setup

void setup() { 
  size(500, 500); 
  noSmooth();
  bg = loadImage("MissileCommandBackground.png");
  background(0);
  textAlign(CENTER);
  textSize(50);
  fill(0, 0, 255);
  text(title, width/2, 150);
  textSize(25);
  fill(255);
  text(message, width/2, height/2);
  // Setup cities array
  
  for (int i = 0; i < 4; i++) {
    cities[i] = new City();
    cities[i].cityX = (i*100)+83;
  }
  noLoop();
} 

// Game loop

void draw() {  
  background(bg);
  int scoreTime = millis() - kTime;
  fill(255);
  textSize(15);
  textAlign(LEFT);
  text("SCORE: " + scoreTime, 20, 480);
  // text( message, 200, 200);


  int citiesRemaining = 0;
  for (int i = 0; i<4; i++) {
    if (!cities[i].destroyed) citiesRemaining++;
  }
  
  // Check if cities remaining otherwise game-over

  if (citiesRemaining > 0) {
    for (int i = 0; i<4; i++) {
      cities[i].drawCity();
    }
    
    // Create enemy missile every 1.5 seconds
    
    if (millis() > mTime + 1500) {
    createMissile();
    mTime = millis();
  }

  for (Missile missile : missiles) {
    missile.moveMissile();
  }
  
  // Create interceptor when mouse pressed

  if (mousePressed) {
    float sX, sY, dX, dY;
    if (millis() > iTime + 700) {

      if (mouseX < 250) {
        sX = 10; 
        sY = 275;
        dX = mouseX;
        dY = mouseY;
      } else {
        sX = 490;
        sY = 275;
        dX = mouseX;
        dY = mouseY;
      }
      Interceptor newInterceptor = new Interceptor(sX, sY, dX, dY);
      interceptors.add(newInterceptor);
      iTime = millis();
    }
  }

  for (Interceptor interceptor : interceptors) {
    interceptor.moveInterceptor();
  }

// Check if missile reached bottom or collided with city

  for (int i = 0; i < missiles.size(); i++) {
    Missile missile = missiles.get(i);
    if (missile.percent >= 1.0) {
      missiles.remove(i);
    }
    for (int j = 0; j < 4; j++) {
      if (!cities[j].destroyed) {
        if (dist(missile.currentX, missile.currentY, cities[j].cityX, cities[j].cityY-40) < 20) {
          cities[j].destroyed = true;
          missiles.remove(i);
        }
      }
    }
  }
  
  // Check if interceptor reached destination and collided with missile
  
  for (int i = 0; i < interceptors.size(); i++) {
    Interceptor interceptor = interceptors.get(i);

    if (interceptor.remove) {
      interceptors.remove(i);
    }

    for (int j = 0; j < missiles.size(); j++) {
      Missile missile = missiles.get(j);
      if (dist(interceptor.currentX, interceptor.currentY, missile.currentX, missile.currentY) <= interceptor.diameter-5) {
        missiles.remove(j);
        //interceptor.percent = 0.99;
        //interceptors.remove(i);
      }
    }
    if (interceptor.percent >= 1.0) {
      interceptor.explode = true;
    }
  }
    
  } else {
    
    // Game over screen
    
    fill(255);
    message = "YOU LOSE!\nFinal Score: " + scoreTime;
    setup();
    
  }

  
} 


void keyPressed() {
  kTime = millis();
  message = "";
  loop();
}

void createMissile () {
  Missile newMissile = new Missile();
  missiles.add(newMissile);
}


// Missile object

class Missile {
  float startX = random(50, 450);
  float endX = random(50, 450);
  float startY = 0;
  float endY = 450;
  float currentX = startX;
  float currentY = startY;
  float speed = random(0.0015, 0.0055);
  float percent = 0.0;

  Missile() {
  }
  
  // Calculate missiles new position and move

  void moveMissile() {
    if (percent < 1.0) {
      currentX = startX + ((endX - startX) * percent);
      currentY = startY + ((endY - startY) * percent);
      percent += speed;
    }

    stroke(255, 0, 0);
    strokeWeight(3);
    line(startX, startY, currentX, currentY);
  }
}

// City object

class City {
  int cityX;
  int cityY = 440;
  boolean destroyed;

  void drawCity () {
    if (!destroyed) {
      fill(169);
      noStroke();
      rect(cityX-15, cityY-40, 10, 40);
      rect(cityX-10, cityY-50, 10, 50);
      rect(cityX, cityY-40, 5, 40); 
      rect(cityX+5, cityY-60, 10, 60); 
      rect(cityX+15, cityY-20, 10, 20);
    }
  }
}

// Interceptor object

class Interceptor {
  float startX, startY, destX, destY;
  float speed = 0.04;
  float percent = 0.0;
  float currentX;
  float currentY;
  boolean explode = false;
  boolean remove = false;
  int diameter = 0;

  Interceptor(float sX, float sY, float dX, float dY) {
    startX = sX;
    startY = sY;
    destX = dX;
    destY = dY;
    currentX = sX;
    currentY = sY;
  }
  
  // Calculate interceptor position and move or explode if reached destination

  void moveInterceptor() {
    if (!explode) {
      currentX = startX + ((destX - startX) * percent);
      currentY = startY + ((destY - startY) * percent);
      percent += speed;
      stroke(255, 255, 255);
      strokeWeight(2);
      line(startX, startY, currentX, currentY);
    } else {
      fill(255);
      noStroke();
      ellipse(destX, destY, diameter, diameter);
      diameter += 2;
      if (diameter>50) {
        remove = true;
      }
    }
  }
}