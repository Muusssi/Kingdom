public static final float SQRT_2 = 1.4142;
public static final float SIN_QUARTER_PI = 0.7071;



HashMap<Integer, Boolean> pressed_keys = new HashMap<Integer, Boolean>();


boolean pressed(int key) {
  if (pressed_keys.containsKey(key) ) {
    return pressed_keys.get(key);
  }
  return false;
}

void register_keypress() {
  pressed_keys.put(keyCode, true);
}

void register_keyrelease() {
  pressed_keys.put(keyCode, false);
}