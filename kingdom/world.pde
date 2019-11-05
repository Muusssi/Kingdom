public static final int SEA_BUFFER = 3; // Must be at least 2
public static final float BASE_LINE_WATER = 0.01;
public static final float BASE_LINE_MOUNTAIN = 0.01;
public static final float NEIGHBOUR_EFFECT = 0.35;


Tile[][] world_grid = new Tile[WORLD_WIDTH][WORLD_HEIGHT];
PGraphics map_layer, dominion_layer;

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

        // if (world_grid[i - 2][j] instanceof WaterTile) water_likelyhood += NEIGHBOUR_EFFECT/2;
        // else if (world_grid[i - 2][j] instanceof MountainTile) mountain_likelyhood += NEIGHBOUR_EFFECT/2;
        // if (world_grid[i][j - 2] instanceof WaterTile) water_likelyhood += NEIGHBOUR_EFFECT/2;
        // else if (world_grid[i][j - 2] instanceof MountainTile) mountain_likelyhood += NEIGHBOUR_EFFECT/2;

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

}

void init_map_layer() {
  map_layer = createGraphics(TILE_SIZE*WORLD_WIDTH, TILE_SIZE*WORLD_WIDTH);
  map_layer.beginDraw();
  for (int i = 0; i < WORLD_WIDTH; ++i) {
    for (int j = 0; j < WORLD_HEIGHT; ++j) {
      world_grid[i][j].draw();
    }
  }
  map_layer.endDraw();
}


void draw_map() {
  image(map_layer, 0, 0);
}


public abstract class Tile {

  int x, y;
  float fertility = 0;
  float movement_cost = 1;
  boolean units_can_cross = false;

  boolean highlight = false;

  Building building = null;
  Unit unit = null;


  int red = 255;
  int green = 255;
  int blue = 255;



  public Tile (int x, int y) {
    this.x = x;
    this.y = y;
  }

  void draw() {
    if (highlight) map_layer.fill(0, 200, 255);
    else map_layer.fill(red, green, blue);
    map_layer.rect(x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE);

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
  LinkedList<Path> path;


  public Path (Tile tile, float movement_cost, Path previous_point) {
    this.tile = tile;
    this.movement_cost = previous_point.movement_cost + movement_cost;
    this.path = (LinkedList<Path>) previous_point.path.clone();
  }

  public Path (Tile tile) {
    this.tile = tile;
    this.movement_cost = 0;
    this.path = new LinkedList<Path>();
  }

}


public static int[] x_directions = { 0, 1, 0, -1,  1, 1, -1, -1};
public static int[] y_directions = {-1, 0, 1,  0, -1, 1,  1, -1};

public class Unit {

  int x = 10;
  int y = 10;
  Tile tile;

  float initial_movement_points = 5;
  float movement_points = 100;
  HashMap<Tile,Path> reachable = new HashMap<Tile,Path>();

  public Unit () {
    units.add(this);
    this.tile = world_grid[x][y];
    this.tile.unit = this;
  }

  void draw() {
    if (active_unit == this) {
      fill(255, 0, 0);
    }
    else {
      fill(255);
    }
    ellipse((x+0.5)*TILE_SIZE, (y+0.5)*TILE_SIZE, 2*TILE_SIZE/3, 2*TILE_SIZE/3);
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
