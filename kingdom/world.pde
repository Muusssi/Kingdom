public static final int SEA_BUFFER = 3; // Must be at least 2
public static final float BASE_LINE_WATER = 0.01;
public static final float BASE_LINE_MOUNTAIN = 0.01;
public static final float NEIGHBOUR_EFFECT = 0.35;


Tile[][] world_grid = new Tile[WORLD_WIDTH][WORLD_HEIGHT];
PGraphics map_layer, reachable_layer;

void init_world() {
  // This function generates the random world
  float water_likelyhood;
  float mountain_likelyhood;
  for (int i = 0; i < WORLD_WIDTH; ++i) {
    for (int j = 0; j < WORLD_HEIGHT; ++j) {
      if (i < SEA_BUFFER || j < SEA_BUFFER) {
        world_grid[i][j] = new WaterTile(i, j);
      }
      else {
        water_likelyhood = BASE_LINE_WATER;
        mountain_likelyhood = BASE_LINE_MOUNTAIN;
        if (world_grid[i - 1][j] instanceof WaterTile) water_likelyhood += NEIGHBOUR_EFFECT;
        else if (world_grid[i - 1][j] instanceof MountainTile) mountain_likelyhood += NEIGHBOUR_EFFECT;
        if (world_grid[i][j - 1] instanceof WaterTile) water_likelyhood += NEIGHBOUR_EFFECT;
        else if (world_grid[i][j - 1] instanceof MountainTile) mountain_likelyhood += NEIGHBOUR_EFFECT;
        if (world_grid[i - 1][j - 1] instanceof WaterTile) water_likelyhood += NEIGHBOUR_EFFECT/2;
        else if (world_grid[i - 1][j - 1] instanceof MountainTile) mountain_likelyhood += NEIGHBOUR_EFFECT/2;

        float rand = random(1);
        if (rand < water_likelyhood) {
          world_grid[i][j] = new WaterTile(i, j);
        }
        else if (rand < water_likelyhood + mountain_likelyhood) {
          world_grid[i][j] = new MountainTile(i, j);
        }
        else {
          world_grid[i][j] = new LandTile(i, j);
        }
      }

    }
  }
  init_map_layer();
}

void init_map_layer() {
  map_layer = createGraphics(TILE_SIZE*WORLD_WIDTH, TILE_SIZE*WORLD_WIDTH);
  map_layer.beginDraw();
  for (int i = 0; i < WORLD_WIDTH; ++i) {
    for (int j = 0; j < WORLD_HEIGHT; ++j) {
      world_grid[i][j].draw(map_layer);
    }
  }
  map_layer.endDraw();
}


void draw_map() {
  image(map_layer, 0, 0);
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


public abstract class Tile {

  int x, y;
  float fertility = 0;
  float movement_cost = 1;
  boolean units_can_cross = false;

  Building building = null;
  Unit unit = null;


  int red = 255;
  int green = 255;
  int blue = 255;

  public Tile (int x, int y) {
    this.x = x;
    this.y = y;
  }

  void draw(PGraphics layer) {
    this.draw(layer, false);
  }

  void draw(PGraphics layer, boolean highlight) {
    if (highlight) layer.fill(0, 200, 255);
    else layer.fill(red, green, blue);
    layer.rect(x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
  }

}

public class LandTile extends Tile {
  public LandTile (int x, int y) {
    super(x, y);
    red = 0;
    green = 255;
    blue = 0;
    units_can_cross = true;
  }
}

public class SandTile extends LandTile {
  public SandTile (int x, int y) {
    super(x, y);
    red = 229;
    green = 173;
    blue = 28;
    movement_cost = 2;
  }
}


public class WaterTile extends Tile {
  public WaterTile (int x, int y) {
    super(x, y);
    red = 0;
    green = 0;
    blue = 255;
  }

}

public class MountainTile extends Tile {
  public MountainTile (int x, int y) {
    super(x, y);
    red = 51;
    green = 17;
    blue = 0;
  }

}



public class Building {

  public Building () {

  }

}


void draw_units() {
  for (int i = 0; i < units.size(); ++i) {
    Unit unit = units.get(i);
    unit.draw();
  }
}


public class Path {
  Tile tile;
  float movement_cost;
  LinkedList<Tile> path;

  public Path (Tile tile, float movement_cost, Path previous_path) {
    this.tile = tile;
    this.movement_cost = previous_path.movement_cost + movement_cost;
    this.path = (LinkedList<Tile>) previous_path.path.clone();
    this.path.add(tile);
  }

  public Path (Tile tile) {
    this.tile = tile;
    this.movement_cost = 0;
    this.path = new LinkedList<Tile>();
    this.path.add(tile);
  }

  void draw() {
    pushStyle();
      strokeWeight(3);
      for (int i = 1; i < this.path.size(); ++i) {
        Tile tile1 = this.path.get(i - 1);
        Tile tile2 = this.path.get(i);
        line((tile1.x + 0.5)*TILE_SIZE, (tile1.y + 0.5)*TILE_SIZE, (tile2.x + 0.5)*TILE_SIZE, (tile2.y + 0.5)*TILE_SIZE);
      }
    popStyle();
  }

}


public static int[] x_directions = { 0, 1, 0, -1,  1, 1, -1, -1};
public static int[] y_directions = {-1, 0, 1,  0, -1, 1,  1, -1};

public class Unit {

  float x = 10;
  float y = 10;
  Tile tile;

  float initial_movement_points = 50;
  float movement_points = initial_movement_points;
  HashMap<Tile,Path> reachable = new HashMap<Tile,Path>();

  float speed = 0.1;

  public Unit () {
    units.add(this);
    this.tile = world_grid[int(x)][int(y)];
    this.tile.unit = this;
  }

  void draw() {
    if (active_unit == this) {
      fill(255, 0, 0);
      this.draw_reachable_layer();
      this.draw_path_to_pointed_tile();
    }
    else {
      fill(255);
    }
    ellipse((x+0.5)*TILE_SIZE, (y+0.5)*TILE_SIZE, 2*TILE_SIZE/3, 2*TILE_SIZE/3);
    move();
  }

  void draw_path_to_pointed_tile() {
    Path path = path_to_pointed_tile();
    if (path != null) {
      path.draw();
    }
  }

  Path path_to_pointed_tile() {
    Path path = null;
    Tile tile = pointed_tile();
    if (tile != null && this.reachable.containsKey(tile)) {
      path = this.reachable.get(tile);
    }
    return path;
  }

  void move() {
    // TODO: moving iteration
  }

  void find_reachable_paths() {
    reachable = new HashMap<Tile,Path>();
    LinkedList<Path> queue = new LinkedList<Path>();

    queue.add(new Path(this.tile));
    int x, y;
    Tile tile;
    while (queue.size() > 0) {
      Path current = queue.removeFirst();
      x = current.tile.x;
      y = current.tile.y;
      for (int i = 0; i < 8; ++i) {
        int next_x = x - x_directions[i];
        int next_y = y - y_directions[i];
        if (are_coordinates_inside(next_x, next_y)) {
          tile = world_grid[next_x][next_y];
          float movement_cost = this.movement_cost(current.tile, tile, i >= 4);
          if (tile.units_can_cross && (movement_points - current.movement_cost - movement_cost >= 0)) {
            Path new_path = new Path(tile, movement_cost, current);
            if (reachable.containsKey(tile)) {
              Path old_path = reachable.get(tile);
              if (old_path.movement_cost > current.movement_cost + movement_cost) {
                reachable.put(tile, new_path);
                queue.remove(old_path);
                queue.add(new_path);
              }
            }
            else {
              reachable.put(tile, new_path);
              queue.add(new_path);
            }

          }
        }
      }

    }
  }


  float movement_cost(Tile tile1, Tile tile2, boolean diagonal) {
    if (diagonal) {
      return (tile1.movement_cost/2 + tile2.movement_cost/2)*1.414;
    }
    return tile1.movement_cost/2 + tile2.movement_cost/2;
  }

  void draw_reachable_layer() {
    if (reachable_layer == null) {
      update_reachable_layer(this);
    }
    image(reachable_layer, 0, 0);
  }

  void move_to(Tile tile) {
    if (this.reachable.containsKey(tile)) {
      // TODO: move
    }
    else {
      println("Can't go there!");
    }
  }

}

void update_reachable_layer(Unit unit) {
  unit.find_reachable_paths();
  reachable_layer = createGraphics(TILE_SIZE*WORLD_WIDTH, TILE_SIZE*WORLD_WIDTH);
  reachable_layer.beginDraw();

  Iterator<Tile> itr = unit.reachable.keySet().iterator();
  while (itr.hasNext()) {
    itr.next().draw(reachable_layer, true);
  }
  reachable_layer.endDraw();
}

boolean are_coordinates_inside(int x, int y) {
  if (x < 0 || x >= WORLD_WIDTH) {
    return false;
  }
  if (y < 0 || y >= WORLD_HEIGHT) {
    return false;
  }
  return true;
}
