var Physics = (function() {
  var Vector, Particle, ForceField, ConstantField;
  
  Vector = function(x, y) {
    this.x = x; 
    this.y = y;
  };
  $.extend(Vector.prototype, {
    equal: function(v) {
      return this.x == v.getX() && this.y == v.getY();
    },
    getX: function() {
      return this.x;
    },
    getY: function() {
      return this.y;
    },
    getTheta: function() {
      return Math.atan2(this.y, this.x);
    },
    setX: function(x) {
      this.x = x;
      return this;
    },
    setY: function(y) {
      this.y = y;
      return this;
    },
    addX: function(x) {
      this.x += x;
    },
    addY: function(y) {
      this.y += y;
    },
    set: function(v) {
      this.x = v.getX();
      this.y = v.getY();
      return this;
    },
    add: function(v) {
      this.x += v.getX();
      this.y += v.getY();
      return this;
    },
    sub: function(v) {
      this.x -= v.getX();
      this.y -= v.getY();
      return this;
    },
    rotate: function(theta) {
      var curX = this.x,
        curY = this.y;
      this.x = curX * Math.cos(theta) + curY * Math.sin(theta);
      this.y = curY * Math.cos(theta) + curX * Math.sin(theta);
    },
    dotProd: function(v) {
      return this.x * v.getX() + this.y * v.getY();
    },
    dist: function(v) {
      return Math.sqrt((this.x - v.getX()) * (this.x - v.getX()) + (this.y - v.getY()) * (this.y - v.getY()));
    },
    length: function() {
      return Math.sqrt(this.x * this.x + this.y * this.y);
    },
    setLength: function(len) {
      var theta = this.getTheta();
      this.x = len * Math.cos(theta);
      this.y = len * Math.sin(theta);
      return this;
    },
    scale: function(scaleFactor) {
      this.x *= scaleFactor;
      this.y *= scaleFactor;
      return this;
    },
    clone: function() {
      return new Vector(this.x, this.y);
    },
    normalize: function() {
      var l = this.length();
      this.x /= l;
      this.y /= l;
      return this;
    },
    toString: function() {
      return " X: " + this.x + " Y: " + this.y;
    },
    draw: function(ctx, pos) {
      pos = pos || new Vector(0, 0);
      ctx.save();
      ctx.translate(pos.x, pos.y);
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(this.x, this.y);
      ctx.stroke();
      ctx.lineWidth = 2;
      ctx.translate(this.x, this.y);
      ctx.rotate(this.getTheta());
      ctx.moveTo(0, 0);
      ctx.lineTo(-5, -3);
      ctx.lineTo(-5, 3);
      ctx.lineTo(0, 0);
      ctx.fill();
      ctx.stroke();
      ctx.restore();
    }
  });
  
  ForceField = function(fn) {
    this.calculator = fn;
  };
  
  $.extend(ForceField.prototype, {
    forceAgainst: function(particle) {
      return this.calculator.call(this, particle);
    }
  });
  
  ConstantField = function() {
    var vector = arguments.length == 1 ? arguments[0] : new Vector(arguments[0], arguments[1]);
    new ForceField(function() { return vector; })
  };
    
  Particle = function(options) {
    options = options || {};
    this.options = options;
    this.position = options.position || new Vector(0, 0);
    this.velocity = options.velocity || new Vector(0, 0); 
    this.force = new Vector(0, 0);
    this.mass = options.mass || 0;
    this.charge = options.charge || 0; 
    this.field = options.field || Physics.NullField; 
    this.friction = options.friction ? options.friction : 0; 
  };
  
  $.extend(Particle.prototype, {
    clone: function() {
      return new Particle(this.options);
    },
    getXPos: function() {
      return this.position.getX(); 
    },
    getYPos: function() {
      return this.position.getY(); 
    },
    getPos: function() {
      return this.position; 
    },
    setPos: function(v) {
      this.position.set(v);
      return this;
    },
    addXPos: function(dx) {
      this.position.addX(dx); 
    },
    addYPos: function(dy) {
      this.position.addY(dy); 
    },
    setForce: function(force) {
      this.force.set(force); 
    },
    setField: function(field) {
      this.field = field;
    },
    getField: function(field) {
      return this.field;
    },
    getForce: function() {
      return this.field ? this.field.forceAgainst(this) : this.force;
    },
    addForce: function(force) {
      this.force.add(force); 
    },
    getMass: function() {
      return this.mass; 
    },
    setMass: function(mass) {
      this.mass = mass; 
    },
    move: function(dt) {
      var a, vdt, hlfadtdt, nxtp, nxta, avgadt, nxtv; 

      if (this.field) {
        this.setForce(this.field.forceAgainst(this));
      }
      
      dtdt = dt * dt;
      
      // Calculate Next Position
      a = this.force.clone().scale(1.0 / this.mass);
      vdt = this.velocity.clone().scale(dt);
      hlfadtdt = a.clone().scale(dtdt * 0.5);
      nxtp = this.position.clone().add(vdt).add(hlfadtdt);
      
      // Calculate Next Velocity
      nxta = this.field.forceAgainst(this.clone().setPos(nxtp)).scale(1.0 / this.mass);
      avgadt = nxta.add(a).scale(0.5 * dt);
      nxtv = avgadt.add(this.velocity);
      
      this.position = nxtp;
      this.velocity = nxtv;
    },
    setFriction: function(friction) {
      this.friction = friction; 
    },
    setVelocity: function(value) {
      this.velocity = value;
      return this;
    },
    getVelocity: function() {
      return this.velocity;
    }
  });
  
  return {
    Vector: Vector,
    Particle: Particle,
    ForceField: ForceField,
    SimpleGravity: function(strength) {
      return ConstantField(0, strength || 10);
    },
    NullField: ConstantField(0, 0),
    ConstantField: ConstantField,
    Gravity: function(origin, strength) {
      return new ForceField(function(particle) {
        var force = new Vector(0, 0), rSq;
        if (particle.getXPos() >= 0 && particle.getYPos() >= 0) {
          force.set(origin);
          force.sub(particle.getPos());
          rSq = force.dotProd(force);
          force.setLength((strength * particle.mass)/rSq);
        }
        return force;
      });
    }    
  };
}());
