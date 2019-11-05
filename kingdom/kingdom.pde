import java.util.LinkedList;
import java.util.HashMap;
import java.util.Iterator;

public static final float SLIDE_SPEED = 7;
public static final float ZOOMIMG_SPEED = 0.03;
public static final float ZOOM_IN = 1 + ZOOMIMG_SPEED;
public static final float ZOOM_OUT = 1 - ZOOMIMG_SPEED;

public static final float MAX_ZOOM = 3;
public static final float MIN_ZOOM = 0.3;


public static final int WORLD_WIDTH = 300;
public static final int WORLD_HEIGHT = 300;
public static final int TILE_SIZE = 10;



float x_offset = 0;
float y_offset = 0;

float zoom = 1.0;

Unit active_unit = null;
LinkedList<Unit> units = new LinkedList<Unit>();

void setup() {
  //size(800, 600, P2D);
  fullScreen(P2D);
  init_world();
  //init_map_layer();
  Unit unit = new Unit();
  unit.find_reachable_paths();
  Iterator<Tile> itr = unit.reachable.keySet().iterator();
  while (itr.hasNext()) {
    itr.next().highlight = true;
  }
  init_map_layer();
}

void draw() {
  background(200);
  handle_wasd();
  set_world_coordinates();

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

Tile pointed_tile() {
  int x, y;
  float x_point = (mouseX - width/2)/zoom + width/2 - x_offset;
  if (x_point < 0 || x_point > WORLD_WIDTH*TILE_SIZE) {
    return null;
  }
  else {
    x = int(x_point)/TILE_SIZE;
  }
  float y_point = (mouseY - height/2)/zoom + height/2 - y_offset;
  if (y_point < 0 || y_point > WORLD_HEIGHT*TILE_SIZE) {
    return null;
  }
  else {
    y = int(y_point)/TILE_SIZE;
  }
  return world_grid[x][y];
}

void mousePressed() {
  Tile tile = pointed_tile();
  if (tile != null) {
    if (tile.unit != null) {
      //println("Active set");
      active_unit = tile.unit;
    }
    else {
      //println("Active cleared");
      active_unit = null;
    }
  }
  else {
    println("Out");
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
