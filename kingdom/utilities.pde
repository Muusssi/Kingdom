public static final float SQRT_2 = 1.4142;
public static final float SIN_QUARTER_PI = 0.7071;

HashMap<Integer, Boolean> pressed_keys = new HashMap<Integer, Boolean>();
ArrayList<Button> all_buttons = new ArrayList<Button>();


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

void draw_buttons() {
  draw_buttons(all_buttons);
}

void draw_buttons(ArrayList<Button> buttons) {
  for (Button button : buttons) {
    button.draw();
  }
}

void check_buttons() {
  for (Button button : all_buttons) {
    if (button.cursor_points()) {
      button.press();
    }
  }
}

public abstract class Button {

  public int x, y;
  public int button_width;
  public int button_height = 30;
  public String text;

  public int background_r = 255;
  public int background_g = 255;
  public int background_b = 255;

  public int active_background_r = 230;
  public int active_background_g = 230;
  public int active_background_b = 230;

  public int text_r = 0;
  public int text_g = 0;
  public int text_b = 0;

  public boolean stay_down = false;
  public boolean pressed = false;
  public int pressed_on_frame = -1;
  public int drawn_on_frame = -1;


  public Button(String text, int x, int y) {
      this.text = text;
      this.x = x;
      this.y = y;
      if (text.length() < 4) {
          this.button_width = 40;
      }
      else {
          this.button_width = text.length()*10;
      }
      all_buttons.add(this);
  }

  public boolean cursor_points() {
      if (frameCount == drawn_on_frame &&
          mouseX >= x && mouseX <= x + width &&
          mouseY >= y && mouseY <= y + height) {
          return true;
      }
      else {
          return false;
      }
  }

  public void draw() {
    drawn_on_frame = frameCount;
    pushStyle();
    if (pressed || cursor_points()){
        if (pressed || mousePressed) {
          fill(text_r, text_g, text_b);
        }
        else {
          fill(active_background_r, active_background_g, active_background_b);
        }
    }
    else {
      fill(background_r, background_g, background_b);
    }
    stroke(text_r, text_g, text_b);
    rect(x, y, button_width, button_height, 10);

    if (pressed || (cursor_points() && mousePressed)) {
      stroke(active_background_r, active_background_g, active_background_b);
      fill(active_background_r, active_background_g, active_background_b);
    }
    else {
      stroke(text_r, text_g, text_b);
      fill(text_r, text_g, text_b);
    }

    textAlign(PConstants.CENTER, PConstants.CENTER);
    text(text, x + button_width/2, y + button_height/2);
    popStyle();
  }

  public void background_color(int r, int g, int b) {
      this.background_r = r;
      this.background_g = g;
      this.background_b = b;
  }

  public void background_color(int c) {
    background_color(c, c, c);
  }

  public void active_background_color(int r, int g, int b) {
      this.active_background_r = r;
      this.active_background_g = g;
      this.active_background_b = b;
  }

  public void text_color(int r, int g, int b) {
      this.text_r = r;
      this.text_g = g;
      this.text_b = b;
  }

  public void text_color(int c) {
    text_color(c, c, c);
  }

  public void press() {
    if (pressed_on_frame != frameCount) {
      if (stay_down) {
        if (pressed) {
          pressed = false;
          release_action();
        }
        else {
          pressed = true;
          action();
        }
      }
      else {
        action();
      }
    }
    pressed_on_frame = frameCount;
  }

  //This is the method that the actual buttons should implement
  public abstract void action();

  public void release_action() {}

}
