
// Original JS code by Simon Sarris
// www.simonsarris.com
// sarris@acm.org

#import('dart:html');

class Shape {
  int x, y, w, h;
  String fill;
  Shape([this.x=0, this.y=0, this.w=0, this.h=0, this.fill='#AAAAAA']);
  
  draw(ctx) {
    ctx.fillStyle = this.fill;
    ctx.fillRect(this.x, this.y, this.w, this.h);
  }
  
  contains(mx, my) {
    // All we have to do is make sure the Mouse X,Y fall in the area between
    // the shape's X and (X + Height) and its Y and (Y + Height)
    return  (this.x <= mx) && (this.x + this.w >= mx) &&
            (this.y <= my) && (this.y + this.h >= my);
  }
}

class CanvasState {
  CanvasRenderingContext2D ctx;
  CanvasElement canvas;
  int width;
  int height;
  
  bool valid = false;
  List <Shape> shapes;
  bool dragging = false;
  Shape selection;

  int dragoffx; // See mousedown and mousemove events for explanation
  int dragoffy;
  
  String selectionColor;
  int selectionWidth; 
  
  CanvasState(this.canvas) {
    width = this.canvas.width;
    height = this.canvas.height;
    ctx = this.canvas.getContext("2d");
    shapes = [];
    dragoffx = 0; // See mousedown and mousemove events for explanation
    dragoffy = 0;
    
    canvas.on.selectStart.add((e)=>e.preventDefault());
    canvas.on.mouseDown.add((MouseEvent e) {
      var mx = e.offsetX;
      var my = e.offsetY;
      var l = shapes.length;
      for (var i = l-1; i >= 0; i--) {
        if (shapes[i].contains(mx, my)) {
          var mySel = shapes[i];
          // Keep track of where in the object we clicked
          // so we can move it smoothly (see mousemove)
          dragoffx = mx - mySel.x;
          dragoffy = my - mySel.y;
          dragging = true;
          selection = mySel;
          valid = false;
          return;
        }
      }
      
      // havent returned means we have failed to select anything.
      // If there was an object selected, we deselect it
      if (selection != null) {
        selection = null;
        valid = false; // Need to clear the old selection border
      }
    });
    
    canvas.on.mouseMove.add((MouseEvent e) {
      if (dragging){
        // We don't want to drag the object by its top-left corner, we want to drag it
        // from where we clicked. Thats why we saved the offset and use it here
        selection.x =  e.offsetX - dragoffx;
        selection.y =  e.offsetY - dragoffy; 
        valid = false; // Something's dragging so we must redraw
      }
    });
    
    canvas.on.mouseUp.add((e){
      dragging = false;
    });
    
    canvas.on.doubleClick.add((MouseEvent e) {
      addShape(new Shape(e.offsetX - 10, e.offsetY - 10, 20, 20, 'rgba(0,255,0,.6)'));
    });
    
    selectionColor = '#CC0000';
    selectionWidth = 2; 
    window.requestAnimationFrame(anim);
  }
  
  bool anim(int i) {
    window.requestAnimationFrame(anim);
    draw();
  }
  
  addShape(shape) {
    shapes.add(shape);
    valid = false;
  }
  
  clear() {
    ctx.clearRect(0, 0, width, height);
  }
  
  draw() {
    // if our state is invalid, redraw and validate!
    if (!valid) {
      clear();
      
      // ** Add stuff you want drawn in the background all the time here **
      
      // draw all shapes
      var l = shapes.length;
      for (var i = 0; i < l; i++) {
        var shape = shapes[i];
        // We can skip the drawing of elements that have moved off the screen:
        if (shape.x > this.width || shape.y > this.height ||
            shape.x + shape.w < 0 || shape.y + shape.h < 0) continue;
        shapes[i].draw(ctx);
      }
      
      // draw selection
      // right now this is just a stroke along the edge of the selected Shape
      if (this.selection != null) {
        ctx.strokeStyle = this.selectionColor;
        ctx.lineWidth = this.selectionWidth;
        var mySel = this.selection;
        ctx.strokeRect(mySel.x,mySel.y,mySel.w,mySel.h);
      }
      
      valid = true;
    }
  }  
}

init() {
  var s = new CanvasState(document.query('#canvas1'));
  s.addShape(new Shape(40,40,50,50)); // The default is gray
  s.addShape(new Shape(60,140,40,60, 'lightskyblue'));
  // Lets make some partially transparent
  s.addShape(new Shape(80,150,60,30, 'rgba(127, 255, 212, .5)'));
  s.addShape(new Shape(125,80,30,80, 'rgba(245, 222, 179, .7)'));
}

void main() {  
  init();  
}
