Table table;

String[] muscleNames = {"Shoulders", "Chest", "Back", "Biceps", "Triceps", "Forearms",
                        "Abs", "Glutes", "Adductors", "Quads", "Hamstrings", "Calves"};

float cx = 500;   // centre of the network (the body node)
float cy = 475;

void setup() {
  size(1000, 950);
  textAlign(CENTER);
  table = loadTable("workouts.csv", "header");
  println(table.getRowCount() + " rows loaded");
  noLoop();   // draw once, nothing moves
}

void draw() {
  background(15);

  // lines from the body to each muscle
  stroke(255, 90);
  strokeWeight(2);
  for (String m : muscleNames) {
    line(cx, cy, muscleX(m), muscleY(m));
  }

  // muscle nodes
  noStroke();
  for (String m : muscleNames) {
    fill(255, 170);
    ellipse(muscleX(m), muscleY(m), 16, 16);
    fill(255);
    textSize(12);
    text(m, muscleX(m), muscleY(m) - 16);
  }

  // body node in the middle
  fill(255);
  ellipse(cx, cy, 50, 50);
  fill(15);
  text("BODY", cx, cy + 4);
}

// returns the x position of a muscle on a ring around the body
float muscleX(String m) {
  int i = muscleIndex(m);
  return cx + 190 * cos(TWO_PI * i / muscleNames.length - HALF_PI);
}

// returns the y position of a muscle on a ring around the body
float muscleY(String m) {
  int i = muscleIndex(m);
  return cy + 190 * sin(TWO_PI * i / muscleNames.length - HALF_PI);
}

// returns the position of a muscle in the list (-1 if not found)
int muscleIndex(String m) {
  for (int i = 0; i < muscleNames.length; i++) {
    if (muscleNames[i].equals(m)) return i;
  }
  return -1;
}