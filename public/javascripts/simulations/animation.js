var Animation = function(canvas) {
  canvas = $(canvas)
  this.ctx = canvas[0].getContext('2d');
  this.width = canvas[0].width;
  this.height = canvas[0].height;

  var self = this,
    center = new Physics.Vector(this.width * 0.5, this.height * 0.5),
    loop = function() {
      self.draw();
      self.update();
    }, 
    step = 30;
  
  this.draw = function() {
    this.clear();
    if (this.background) {
      this.ctx.drawImage(this.background, 0, 0, this.width, this.height);
    } else {
      this.ctx.fillStyle = "rgb(0,0,0)";
      this.ctx.fillRect(0, 0, this.width, this.height);
      this.ctx.fill();
    }
    this.earth.draw(this.ctx);
    this.moon.draw(this.ctx);
    this.ctx.strokeStyle = this.ctx.fillStyle = "rgba(255,155,155,0.5);"
    this.moon.mass.getForce().draw(this.ctx, this.moon.mass.getPos());
  };  
  this.update = function() {
    this.moon.move(0.1);
  };
  this.start = function() {
    this.interval = setInterval(loop, step);
  };
  this.restart = function() {
    this.stop();
    this.init();
    this.start();
  };
  this.stop = function() {
    clearInterval(this.interval);
  };
  this.clear = function() {
    this.ctx.clearRect(0, 0, this.width, this.height);
  };
  this.init = function() {
    var moonImg = new Image(), earthImg = new Image(), bgImage = new Image(), self = this;
    this.clear();
    this.earth = new Planet({mass: 20, radius: 20, position: center});
    this.moon = new Planet({mass: 10, radius: 10, position: new Physics.Vector(this.width * 0.5, 15), velocity: new Physics.Vector(20, 0)});
    this.moon.mass.setField(Physics.Gravity(this.earth.mass.getPos(), 10 * this.earth.mass.mass));
    bgImage.onload = function() {
      self.background = bgImage;
    };
    bgImage.src = '/images/simulations/sky600x500.png'
    moonImg.onload = function() { 
      self.moon.setImage(moonImg); 
    };
    moonImg.src = '/images/simulations/moon200x200.png';
    earthImg.onload = function() { 
      self.earth.setImage(earthImg); 
    };
    earthImg.src = '/images/simulations/earth200x200.png';
  };
  this.moveMoonTo = function(vector) {
    this.moon.mass.setVelocity(new Physics.Vector(20, 0))
    this.moon.mass.setPos(vector);
    this.draw();
  };
  this.setMoonVelocity = function(position) {
    var velocity = position.sub(this.moon.mass.getPos());
    this.draw();
    this.moon.mass.setVelocity(velocity.clone().scale(0.25));
    this.ctx.strokeStyle = this.ctx.fillStyle = "rgba(235,255,235,0.5);";
    velocity.draw(this.ctx, this.moon.mass.getPos());
  };
};

var Planet = function(options) {
  var self = this;
  this.mass = new Physics.Particle(options); 
  this.img = options.img;
  this.radius = options.radius;
  
  this.draw = function(ctx) {
    ctx.save();
    ctx.translate(this.mass.getXPos(), this.mass.getYPos());
    if (this.img) {
      ctx.drawImage(this.img, -1 * this.radius, -1 * this.radius, 2 * this.radius, 2 * this.radius);
    } else {
      ctx.fillStyle = 'rgba(255,255,255,0.25)';
      ctx.strokeStyle = 'rgb(255,255,255)';
      ctx.beginPath();
      ctx.arc(0, 0, this.radius, 0, Math.PI * 2);
      ctx.closePath();
      ctx.stroke();
      ctx.fill();
    }
    ctx.restore();
  };
  this.setImage = function(img) {
    this.img = img;
  };
  this.move = function(steps) {
    this.mass.move(steps);
  };
}

$(document).ready(function() {
  var animation = new Animation('#simulation');
  animation.init();
  animation.start();

  $("#stop_simulation").click(function(e) {
    e.preventDefault();
    animation.stop();
  });
  $("#start_simulation").click(function(e) {
    e.preventDefault();
    animation.start();
  });
  $("#restart_simulation").click(function(e) {
    e.preventDefault();
    animation.restart();
  });
  $('#simulation').mousedown(function(down) {
    down.preventDefault();
    animation.stop();
    var canvas = $('#simulation'),
      offset = canvas.offset(),
      relativePosition = function(e) {
        return new Physics.Vector(e.pageX - offset.left, e.pageY - offset.top);        
      },
      moonPosition = relativePosition(down);
    animation.moveMoonTo(moonPosition);
    
    $(this).unbind('mousemove').bind('mousemove', function(move) {
      animation.setMoonVelocity(relativePosition(move));
    });
  });
  
  $('#simulation').mouseup(function(up) {
    up.preventDefault();
    animation.start();
    $(this).unbind('mousemove');
  })
});