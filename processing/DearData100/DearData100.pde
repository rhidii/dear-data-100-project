Table table;

// i made two classes, one for the muscles and one for the exercises (they're
// at the bottom of the file). each muscle and each exercise on the screen is an
// object made from one of these classes, and these lists keep all of the objects
ArrayList<Muscle> muscles = new ArrayList<Muscle>();
ArrayList<Exercise> exercises = new ArrayList<Exercise>();

// these are all the muscles i work with my set of exercises. i've placed them
// in a circle branching out from the main node "BODY" in the middle
String[] muscleNames = {"Shoulders", "Chest", "Back", "Biceps", "Triceps", "Forearms",
                        "Abs", "Glutes", "Adductors", "Quads", "Hamstrings", "Calves"};

// i picked a different colour for each level of the network
// (body, muscles, exercises). they're set in setup() because color()
// doesn't work properly before the sketch has started
color bodyColour;
color muscleColour;
color exerciseColour;
color primaryLine;
color secondaryLine;

float cx = 500;   // the middle of the network, this is where the body node goes
float cy = 475;

// these are for zooming and moving around the network
float zoom = 0.75;   // 1 is normal size, bigger means zoomed in
float offsetX;       // how far the whole network has been dragged across
float offsetY;       // and how far it's been dragged down

void setup() {
  size(900, 700);
  textAlign(CENTER);

  // start with the network in the middle of the window
  offsetX = width / 2 - cx * zoom;
  offsetY = height / 2 - cy * zoom;

  bodyColour = color(255);               // white
  muscleColour = color(255, 182, 210);   // light pink
  exerciseColour = color(170, 120, 255); // purple
  primaryLine = color(235, 90, 170);     // strong pink, for the main muscle of an exercise
  secondaryLine = color(150, 130, 220);  // pale lilac, for the secondary muscles

  // this loads my workouts.csv from the data folder. "header" tells processing
  // that the first row is the column names and not actual workout data
  table = loadTable("workouts.csv", "header");
  println(table.getRowCount() + " rows loaded");   // to check in the console that it worked
  noLoop();   // nothing is moving yet so draw() only has to run once

  // make one Muscle object for each muscle in my list. i give it its name, which
  // number it is in the list and how many muscles there are, so it can work out
  // where it goes on the circle
  for (int i = 0; i < muscleNames.length; i++) {
    muscles.add(new Muscle(muscleNames[i], i, muscleNames.length));
  }

  // go through every row of the csv and make an Exercise object the first time
  // i see each exercise. each exercise is in loads of rows (one for every workout
  // i did it in) but i only want it once, so hasExercise() checks if i've already made it
  for (TableRow row : table.rows()) {
    String name = row.getString("Exercise");
    if (!hasExercise(name)) {
      exercises.add(new Exercise(name, row.getString("Primary muscle"), row.getString("Secondary muscles")));
    }
  }

  // now every exercise needs a position on the outer circle, next to its main muscle.
  // if a muscle has more than one exercise they'd sit on top of each other, so for
  // each exercise i work out which number it is (k) out of the ones with the same
  // main muscle (total), and place() uses that to spread them out
  for (Exercise e : exercises) {
    int k = 0;
    int total = 0;
    for (Exercise other : exercises) {
      if (other.primary.equals(e.primary)) {
        total++;
        if (exercises.indexOf(other) < exercises.indexOf(e)) k++;
      }
    }
    e.place(k, total);
  }
}

void draw() {
  background(15);

  // everything drawn after this gets moved and zoomed with the mouse
  pushMatrix();
  translate(offsetX, offsetY);
  scale(zoom);

  // the lines get drawn first so the circles end up on top of them.
  // first level: a line from the body to each muscle
  for (Muscle m : muscles) {
    m.displayLine();
  }

  // second level: lines from each exercise to the muscles it works
  for (Exercise e : exercises) {
    e.displayLines();
  }

  // the muscle circles and their names
  for (Muscle m : muscles) {
    m.displayNode();
  }

  // the exercise circles and their names
  for (Exercise e : exercises) {
    e.displayNode();
  }

  // the body node in the middle. it's drawn last so it sits on top of the lines,
  // and the text is black so you can read it on the white circle
  noStroke();
  fill(bodyColour);
  ellipse(cx, cy, 50, 50);
  fill(0);
  textSize(12);
  text("BODY", cx, cy + 4);

  popMatrix();   // stops the zoom and move from affecting anything else
}

// this looks through the muscle objects for one with the name i give it and gives
// it back. if there isn't one (like "None") it gives back null, which means nothing
Muscle findMuscle(String name) {
  for (Muscle m : muscles) {
    if (m.name.equals(name)) return m;
  }
  return null;
}

// this checks if i've already made an Exercise object with this name and
// gives back true or false
boolean hasExercise(String name) {
  for (Exercise e : exercises) {
    if (e.name.equals(name)) return true;
  }
  return false;
}

// MUSCLE CLASS: one object for each muscle. it stores the muscle's name and
// where it is, and knows how to draw itself
class Muscle {
  String name;
  float angle;   // which direction around the body circle this muscle is in
  float x;
  float y;

  // the constructor runs when i do new Muscle(...). the three things in the
  // brackets are the parameters, and it uses them to work out the position.
  // the muscles are spread evenly around a circle so cos() gives how far across
  // and sin() gives how far down. 190 is how big the circle is (the radius)
  Muscle(String name, int index, int total) {
    this.name = name;
    angle = TWO_PI * index / total - HALF_PI;
    x = cx + 190 * cos(angle);
    y = cy + 190 * sin(angle);
  }

  // line from the body in the middle to this muscle
  void displayLine() {
    stroke(muscleColour, 90);
    strokeWeight(2);
    line(cx, cy, x, y);
  }

  // the circle and the name above it
  void displayNode() {
    noStroke();
    fill(muscleColour);
    ellipse(x, y, 16, 16);
    fill(255);
    textSize(12);
    text(name, x, y - 16);
  }
}


// EXERCISE CLASS: one object for each exercise. it stores the name and which
// muscles it works, and knows where it sits and how to draw itself
class Exercise {
  String name;
  String primary;         // the main muscle
  String[] secondaries;   // the other muscles it works
  float x;
  float y;
  float labelDy;          // moves the name above or below the circle

  // the constructor takes the info from the csv. the secondary muscles come
  // in as one bit of text like "Shoulders;Triceps" so split() cuts it at every ;
  Exercise(String name, String primary, String secondaryText) {
    this.name = name;
    this.primary = primary;
    secondaries = split(secondaryText, ';');
  }

  // works out the position on the outer circle. k is which number this exercise
  // is out of the ones with the same main muscle and total is how many there are,
  // so they get spread a little either side of the muscle's angle
  void place(int k, int total) {
    Muscle m = findMuscle(primary);
    if (m == null) return;   // if the muscle isn't found there's nowhere to put it
    float angle = m.angle + (k - (total - 1) / 2.0) * 0.2;
    x = cx + 400 * cos(angle);
    y = cy + 400 * sin(angle);

    // every other exercise in a group gets its name above the circle instead of
    // below, so the names next to each other don't write over each other
    if (k % 2 == 0) {
      labelDy = 18;
    } else {
      labelDy = -12;
    }
  }

  // lines from this exercise to the muscles it works
  void displayLines() {
    // the main muscle gets a thick bright line so it stands out
    Muscle p = findMuscle(primary);
    if (p != null) {
      stroke(primaryLine, 220);
      strokeWeight(3);
      line(x, y, p.x, p.y);
    }

    // the secondary muscles get thin faint lines
    stroke(secondaryLine, 45);
    strokeWeight(1);
    for (String s : secondaries) {
      Muscle m = findMuscle(s);
      if (m != null) {   // "None" isn't a muscle so findMuscle gives back null and it's skipped
        line(x, y, m.x, m.y);
      }
    }
  }

  // the circle and the name
  void displayNode() {
    noStroke();
    fill(exerciseColour);
    ellipse(x, y, 14, 14);
    fill(255);
    textSize(10);
    text(name, x, y + labelDy);
  }
}

// runs when i scroll the mouse wheel. scrolling up zooms in, down zooms out
void mouseWheel(MouseEvent event) {
  float change = 1.1;
  if (event.getCount() > 0) change = 0.9;   // positive count means scrolled down

  // keep the zoom between 0.3 and 4 so it can't get lost
  float newZoom = constrain(zoom * change, 0.3, 4);
  float actualChange = newZoom / zoom;

  // this makes it zoom towards where the mouse is, instead of the top left corner
  offsetX = mouseX - (mouseX - offsetX) * actualChange;
  offsetY = mouseY - (mouseY - offsetY) * actualChange;
  zoom = newZoom;
  redraw();   // draw() normally only runs once because of noLoop(), so i call it again
}

// runs when i click and drag, moves the whole network by how far the mouse moved
void mouseDragged() {
  offsetX += mouseX - pmouseX;
  offsetY += mouseY - pmouseY;
  redraw();
}

// press r to put the zoom and position back to how it started
void keyPressed() {
  if (key == 'r') {
    zoom = 0.75;
    offsetX = width / 2 - cx * zoom;
    offsetY = height / 2 - cy * zoom;
    redraw();
  }
}