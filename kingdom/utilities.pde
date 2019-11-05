
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