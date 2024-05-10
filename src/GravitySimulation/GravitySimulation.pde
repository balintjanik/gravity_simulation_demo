// base settings
int n = 3000;
Particle[] ps;
int R;
float friction = 0.995;

// animation settings
float animPace = 10;
boolean hasCollisions = false;
boolean hasBorders = true;
boolean hasTrails = false;
int trailSize = 25; // length of trail (should be between 5 and 50)

// NOTE: these settings may be overwritten in the prewritten setup functions, if they are called

void setup(){
  fullScreen();
  frameRate(60);
  colorMode(HSB);
  
  // spawn particles randomly placed in a circle with center of screen and radius R
  R = height/2-100;
  ps = new Particle[n];
  for (int i = 0; i < n; i++){
    float r = R * sqrt(random(0,1));
    float theta = random(0,1) * 2 * PI;
    float x = width/2 + r * cos(theta);
    float y = height/2 + r * sin(theta);
    ps[i] = new Particle(new PVector(x,y), new PVector(random(-1,1),random(-1,1)));
  }
  
  setup_circular();
  //setup_stable_slow();
  //setup_randomness();
  //setup_sun_planet();
  //setup_fullscreen();
}

// setup with a sun and a single planet
void setup_sun_planet(){
  n = 600;
  ps = new Particle[n];
  animPace = 1;
  hasCollisions = true;
  hasBorders = false;
  hasTrails = true;
  trailSize = 20;
  friction = 0.3;
  R = 20;
  ps[0] = new Particle(new PVector(width-900,height/2), new PVector(0,3/*random(-1,1),random(-1,1)*/));
  ps[1] = new Particle(new PVector(width-800,height/2), new PVector(0,-1.8/*random(-1,1),random(-1,1)*/));
  for (int i = 2; i < n; i++){
    float r = R * sqrt(random(0,1));
    float theta = random(0,1) * 2 * PI;
    float x = width/2 + r * cos(theta);
    float y = height/2 + r * sin(theta);
    ps[i] = new Particle(new PVector(x,y), new PVector(0,0/*random(-1,1),random(-1,1)*/));
  }
}

// setup with randomly positioned particles spawned with random speeds
void setup_stable_slow(){
  n = 100;
  ps = new Particle[n];
  friction = 0.995;
  animPace = 1;
  hasCollisions = true;
  hasBorders = false;
  hasTrails = true;
  trailSize = 20;
  R = height/2-100;
  for (int i = 0; i < n; i++){
    float r = R * sqrt(random(0,1));
    float theta = random(0,1) * 2 * PI;
    float x = width/2 + r * cos(theta);
    float y = height/2 + r * sin(theta);
    ps[i] = new Particle(new PVector(x,y), new PVector(0,0/*random(-1,1),random(-1,1)*/));
  }
}

// setup with randomly positioned particles spawned with random speeds - sped up
void setup_randomness(){
  n = 600;
  ps = new Particle[n];
  friction = 0.995;
  animPace = 0.5;
  hasCollisions = true;
  hasBorders = true;
  hasTrails = true;
  trailSize = 20;
  R = height/2-100;
  for (int i = 0; i < n; i++){
    float r = R * sqrt(random(0,1));
    float theta = random(0,1) * 2 * PI;
    float x = width/2 + r * cos(theta);
    float y = height/2 + r * sin(theta);
    ps[i] = new Particle(new PVector(x,y), new PVector(random(-1,1),random(-1,1)));
  }
}

void setup_circular(){
  n = 600;
  ps = new Particle[n];
  friction = 0.995;
  animPace = 1;
  hasCollisions = true;
  hasBorders = false;
  hasTrails = true;
  trailSize = 13;
  R = 50;
  
  for (int i = 0; i < 100; i++){
    float r = R * sqrt(random(0,1));
    float theta = random(0,1) * 2 * PI;
    float x = width/2 + r * cos(theta);
    float y = height/2 + r * sin(theta);
    
    // circular speed around center
    float angToCent = atan2(y - height/2, x - width/2);
    float ang = angToCent+90;
    float dist = new PVector(x,y).dist(new PVector(width/2, height/2));
    float spd = 0;
    float randx = random(0.7, 2);
    float randy = random(0.7, 2);
    PVector vel = new PVector(spd*cos(ang)*randx, spd*sin(ang)*randy);
    
    ps[i] = new Particle(new PVector(x,y), vel /*new PVector(0,0/*random(-1,1),random(-1,1))*/);
  }
  
  R = height/2-50;
  for (int i = 100; i < n; i++){
    float r = R * sqrt(random(0,1));
    float theta = random(0,1) * 2 * PI;
    float x = width/2 + r * cos(theta);
    float y = height/2 + r * sin(theta);
    
    // circular speed around center
    float angToCent = atan2(y - height/2, x - width/2);
    float ang = angToCent+90;
    float dist = new PVector(x,y).dist(new PVector(width/2, height/2));
    float spd = map (dist, 50, R, 0.5, 3);
    if (dist < 50) spd = 0;
    PVector vel = new PVector(spd*cos(ang), spd*sin(ang));
    
    ps[i] = new Particle(new PVector(x,y), vel /*new PVector(0,0/*random(-1,1),random(-1,1))*/);
  }
}

void setup_fullscreen(){
  n = 600;
  ps = new Particle[n];
  animPace = 0.5;
  hasCollisions = true;
  hasBorders = false;
  hasTrails = true;
  trailSize = 20;
  friction = 0.995;
  for (int i = 0; i < n; i++){
    ps[i] = new Particle(new PVector(random(width), random(height)), new PVector(0,0/*random(-1,1),random(-1,1)*/));
  }
}

void draw(){
  background(0);
  
  for (int i = 0; i < n; i++){
    ps[i].update(ps);
  }
  
  // draw trails - if trails are turned on
  if(hasTrails){
    for (int i = 0; i < n; i++){
      ps[i].paintTrail();
    }
  }
  
  // draw particle - color is dependant on the amount of forces affecting the particle
  for (int i = 0; i < n; i++){
      ps[i].paint();
    }
  
  
 for (int i = 0; i < n; i++){
    ps[i].collided = new ArrayList<>();
  }
  
  // save frames as png-s
  //saveFrame("frame-######.png");
}
