class Particle{
  PVector pos, vel;
  int r = 1;
  ArrayList<PVector> trail;
  float allForce = 0;
  
  // List containing the particles that were collided with during the current frame, so redundant collision calculations are avoided
  ArrayList<Particle> collided = new ArrayList();
  
  public Particle(PVector pos, PVector vel){
     this.pos = pos;
     this.vel = vel;
     trail = new ArrayList();
  }
  
  void update(Particle[] ps){
        
    // pop from the stack, if the trail reaches maximum size - if trails are turned on
    if (hasTrails && trail.size() >= trailSize){
      trail.remove(0);
    }
    // save position to stack, before overwriting it - if trails are turned on
    if (hasTrails) trail.add(new PVector(pos.x, pos.y));
    
    // update position with velocity times the pace of the animation (slower animPace results in more accurate calculations)
    pos.add(vel.x * animPace, vel.y * animPace);
    
    allForce = 0; // all the force affecting p[i] particle
    
    for (int j = 0; j < n; j++){
      if (this != ps[j]){
        float ang = atan2(pos.y - ps[j].pos.y, pos.x - ps[j].pos.x);
        //float dist = pos.dist(ps[j].pos);
        float dist = sqrt((pos.x-ps[j].pos.x)*(pos.x-ps[j].pos.x) + (pos.y-ps[j].pos.y)*(pos.y-ps[j].pos.y));
        float g = 1;//6.6743 * pow(10, -11) * p[j].mass/pow(dist,2);
        float force = 1/pow(dist,2);
        
        if (dist >= ps[j].r+r){ // update velocity according to force calculations - if the particles are not colliding
          vel.x -= force*cos(ang);
          vel.y -= force*sin(ang);
          allForce += force;
        } else if (hasCollisions && !collided.contains(ps[j])){ // calculate bounces - if collisions are turned on
        
          // OLD COLLISION MECHANISM
          /*double d = Math.sqrt(Math.pow(pos.x - ps[j].pos.x, 2) + Math.pow(pos.y - ps[j].pos.y, 2)); 
          double nx = (ps[j].pos.x - pos.x) / d; 
          double ny = (ps[j].pos.y - pos.y) / d; 
          double p = 2 * (vel.x * nx + vel.y * ny - ps[j].vel.x * nx - ps[j].vel.y * ny) / 2; 
          vel.x = (float)(vel.x - p * nx) *friction; 
          vel.y = (float)(vel.y - p * ny) * friction; 
          ps[j].vel.x = (float)(ps[j].vel.x + p * nx) * friction; 
          ps[j].vel.y = (float)(ps[j].vel.y + p * ny) * friction;*/
          
          // NEW COLLISION MECHANISM
          collided.add(ps[j]);
          ps[j].collided.add(this);
          calculateCollisionVelocities(pos, vel, 1, ps[j].pos, ps[j].vel, 1);
        }
      }
    }
    
    // bounce back the particle - if borders are turned on
    if (hasBorders){
      if (pos.x > width || pos.x < 0) vel.x = -vel.x;
      if (pos.y > height || pos.y < 0) vel.y = -vel.y;
    }
  }
  
  void paintTrail(){ // draw trails - if trails are turned on
    for (int i = 0; i < trail.size(); i++){
        noStroke();
        fill(255, 5*i);
        ellipse(trail.get(i).x, trail.get(i).y, 1, 1);
      }
  }
  
  void paint(){ // draw particle - color is dependant on the amount of forces affecting the particle
    noStroke();
    float col = map(allForce, 0, 0.5, 160, 0);
    fill(col, 255, 255);
    ellipse(pos.x, pos.y, r*2, r*2);
  }
  
  void calculateCollisionVelocities(PVector position1, PVector velocity1, float mass1, PVector position2, PVector velocity2, float mass2) {
    PVector collisionNormal = PVector.sub(position2, position1).normalize();  // Normalized direction of collision

    // Relative velocity between the particles along the collision normal
    PVector relativeVelocity = PVector.sub(velocity2, velocity1);
    float velAlongNormal = relativeVelocity.dot(collisionNormal);

    // Check if the particles are moving towards each other
    if (velAlongNormal > 0) {
      // Calculate the impulse (change in momentum) along the collision normal
      float restitution = 0.9;
      float impulse = ((1 + restitution) * velAlongNormal) / (mass1 + mass2);
      allForce += impulse/3;
  
      // Calculate the new velocities after the collision
      PVector impulse1 = PVector.mult(collisionNormal, impulse * mass2);
      PVector impulse2 = PVector.mult(collisionNormal, impulse * mass1);

      velocity1.add(PVector.div(impulse1, mass1));
      velocity2.sub(PVector.div(impulse2, mass2));
    }
  }
}
