
int turn = 0;
int active_faction_index = 0;
ArrayList<Faction> factions = new ArrayList<Faction>();
ArrayList<Building> buildings = new ArrayList<Building>();
ArrayList<Resource> all_resources = new ArrayList<Resource>();

public static Resource GOLD, WOOD;

void create_resources() {
  WOOD = new Resource("Wood");
  GOLD = new Resource("Gold");
}


Faction active_faction() {
  return factions.get(active_faction_index);
}


public class Faction {

  ArrayList<Unit> units = new ArrayList<Unit>();
  ArrayList<Unit> buildings = new ArrayList<Unit>();
  HashMap<Resource,Integer> resources = new HashMap<Resource,Integer>();

  public Faction () {
    factions.add(this);
    for (Resource resource : all_resources) {
      this.resources.put(resource, 0);
    }
    this.resources.put(GOLD, 1000);
  }

  void draw_resources() {
    int offset = 50;
    int line_offset = 20;
    pushStyle();
    fill(200);
    rect(0, 0, 100, offset + all_resources.size()*line_offset);
    fill(0);
    text("Turn: " + turn, 20, 20);
    for (Resource resource : all_resources) {
      text(resource.name + ": " +this.resources.get(resource), 10, offset);
      offset += line_offset;
    }
    popStyle();
  }

  void end_turn() {
    for (Unit unit : this.units) {
      unit.movement_points = unit.initial_movement_points;
    }
    this.resources.put(GOLD, 100);
    active_faction_index += 1;
    if (active_faction_index >= factions.size()) {
      turn++;
      active_faction_index = 0;
    }
  }

}

public class PlayerFaction extends Faction {

  public PlayerFaction () {
    super();
  }

}


public class Building {

  public Building () {
    buildings.add(this);
  }

}



public class Resource  {
  String name;

  public Resource (String name) {
    this.name = name;
    all_resources.add(this);
  }
}



public class TurnButton extends Button {

  public TurnButton () {
    // TODO: TurnButton
    super("End turn", width - 100, height - 50);
  }

  public void action() {
    active_faction().end_turn();
  }

}