import java.util.LinkedList;
import java.util.HashMap;
import java.util.Iterator;

public static final float SLIDE_SPEED = 7;
public static final float ZOOMIMG_SPEED = 0.03;
public static final float ZOOM_IN = 1 + ZOOMIMG_SPEED;
public static final float ZOOM_OUT = 1 - ZOOMIMG_SPEED;

public static final float MAX_ZOOM = 3;
public static final float MIN_ZOOM = 0.3;


public static final int WORLD_WIDTH = 200;
public static final int WORLD_HEIGHT = 200;
public static final int TILE_SIZE = 20;



float x_offset = 0;
float y_offset = 0;

float zoom = 1.0;

Unit active_unit = null;
LinkedList<Unit> units = new LinkedList<Unit>();


void setup() {
  size(800, 600, P2D);
  //fullScreen(P2D);
  init_world();
  new Unit(world_grid[10][10]);
  new Unit(world_grid[15][15]);
}

void draw() {
  background(200);
  handle_wasd();

  // Things drawn before this are draw in screen coordinates
  set_world_coordinates();
  // Things drawn after this are draw in the world coordinates

  draw_map();
  draw_units();

}


void handle_wasd() {
  if (pressed('W')) {
    y_offset += SLIDE_SPEED/zoom;
    if (y_offset > height/2) {
      y_offset = height/2;
    }
  }
  else if (pressed('S')) {
    y_offset -= SLIDE_SPEED/zoom;
    if (y_offset < -WORLD_HEIGHT*TILE_SIZE+height/2) {
      y_offset = -WORLD_HEIGHT*TILE_SIZE+height/2;
    }

  }
  if (pressed('A')) {
    x_offset += SLIDE_SPEED/zoom;
    if (x_offset > width/2) {
      x_offset = width/2;
    }
  }
  else if (pressed('D')) {
    x_offset -= SLIDE_SPEED/zoom;
    if (x_offset < -WORLD_WIDTH*TILE_SIZE+width/2) {
      x_offset = -WORLD_WIDTH*TILE_SIZE+width/2;
    }
  }
  if (pressed('Q')) {
    zoom *= ZOOM_IN;
    if (zoom > MAX_ZOOM) {
      zoom = MAX_ZOOM;
    }
  }
  else if (pressed('E')) {
    zoom *= ZOOM_OUT;
    if (zoom < MIN_ZOOM) {
      zoom = MIN_ZOOM;
    }
  }
}

void set_world_coordinates() {
  translate(width/2, height/2);
  scale(zoom, zoom);
  translate(-width/2, -height/2);
  translate(x_offset, y_offset);
}

void mousePressed() {
  Tile tile = pointed_tile();

  if (mouseButton == LEFT) {
    if (tile != null) {
      if (tile.unit != null) {
        select_unit(tile.unit);
      }
      else {
        active_unit = null;
      }
    }
  }
  else if (mouseButton == RIGHT) {
    if (active_unit != null) {
      active_unit.move_to(tile);
    }
  }


}



void keyPressed() {
  register_keypress();
  if (keyCode == 'O') {
    zoom = 1;
  }
}

void keyReleased() {
  register_keyrelease();
}
