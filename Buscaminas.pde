boolean[][] mineGrid, show, select;
int[][] count;
boolean[] click;
boolean diagonal, mouseClick, mouseControl, keyPress, auto_mark, auto_remove, clear, around, mouse_show;
int rows, cols, mines, mine, speedAnimation, x_, y_;
float timeClick, time, timeDie, _time, waitTime, keyTime, time_, keyWait;
boolean lose, win;
String[] data;
PGraphics pg_map, pg_guide;
PImage[] counter_mines;

void settings() {
  size(480, 480, P2D);
  PJOGL.setIcon("data\\icon.png");
}

void setup() {
  surface.setTitle("Minesweeper");
  surface.setResizable(true);
  if (fileExists(sketchPath()+"\\data\\Data.txt")) data = loadStrings("Data.txt");
  else data = new String[0];
  ini();
  x_ = 0;
  y_ = 0;
  mouseControl = true;
  if(diagonal) {
    counter_mines = new PImage[8];
    counter_mines[0] = loadImage("data\\sprites\\8\\1.png");
    counter_mines[1] = loadImage("data\\sprites\\8\\2.png");
    counter_mines[2] = loadImage("data\\sprites\\8\\3.png");
    counter_mines[3] = loadImage("data\\sprites\\8\\4.png");
    counter_mines[4] = loadImage("data\\sprites\\8\\5.png");
    counter_mines[5] = loadImage("data\\sprites\\8\\6.png");
    counter_mines[6] = loadImage("data\\sprites\\8\\7.png");
    counter_mines[7] = loadImage("data\\sprites\\8\\8.png");
  } else {
    counter_mines = new PImage[4];
    counter_mines[0] = loadImage("data\\sprites\\4\\1.png");
    counter_mines[1] = loadImage("data\\sprites\\4\\2.png");
    counter_mines[2] = loadImage("data\\sprites\\4\\3.png");
    counter_mines[3] = loadImage("data\\sprites\\4\\4.png");
  }
}
void ini() {
  cols = 30;
  rows = 20;
  diagonal = true;
  mines = ceil(random(cols*rows-2));
  speedAnimation = 10;
  waitTime = 250;
  keyWait = 100;
  auto_mark = false;
  auto_remove = false;
  around = false;
  mouse_show = false;
  for (int i = 0; i < data.length; i++) {
    String[] _d = split(data[i], ":");
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("columns")) {
      cols = int(_d[1].replaceAll("\\s", ""));
      cols = max(2, cols);
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("rows")) {
      rows = int(_d[1].replaceAll("\\s", ""));
      rows = max(2, rows);
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("diagonal")) {
      if (_d[1].toLowerCase().replaceAll("\\s", "").equals("false")) diagonal = false;
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("mines")) {
      mines = floor(cols*rows*float(_d[1].replaceAll("\\s", ""))/100.0);
      mines = min(cols*rows-2, mines);
      mines = max(2, mines);
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("speedanimation")) {
      speedAnimation = max(int(_d[1].replaceAll("\\s", "")), 1);
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("selectwait")) {
      waitTime = float(_d[1].replaceAll("\\s", ""));
      waitTime = max(0, waitTime);
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("keywait")) {
      keyWait = float(_d[1].replaceAll("\\s", ""));
      keyWait = max(0, keyWait);
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("remove")) {
      if (_d[1].toLowerCase().replaceAll("\\s", "").equals("true")) auto_remove = true;
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("mark")) {
      if (_d[1].toLowerCase().replaceAll("\\s", "").equals("true")) auto_mark = true;
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("around")) {
      if (_d[1].toLowerCase().replaceAll("\\s", "").equals("true")) around = true;
    }
    if (_d[0].toLowerCase().replaceAll("\\s", "").equals("mouseguide")) {
      if (_d[1].toLowerCase().replaceAll("\\s", "").equals("true")) mouse_show = true;
    }
  }
  int pg_map_w = cols*720/36, pg_map_h = rows*480/24;
  pg_map = createGraphics(pg_map_w, pg_map_h, P2D);
  pg_guide = createGraphics(pg_map.width, pg_map.height, P2D);
  clear = true;
  lose = false;
  win = false;
  click = new boolean[2];
  mouseClick = false;
  keyPress = false;
  timeClick = 0.0f;
  time = millis();
  timeDie = 0.0f;
  _time = millis();
  time_ = millis();
  mine = mines;
  mineGrid = new boolean[cols][rows];
  show = new boolean[cols][rows];
  select = new boolean[cols][rows];
  count = new int[cols][rows];
  generate();
  count(diagonal);
  boolean go = false;
  int number = 0;
  while (!go) {
    for (int j = rows-1; j >= 0; j--) {
      if (go) break;
      for (int i = cols - 1; i >= 0; i--) {
        if (go) break;
        if (count[i][j] == number && !mineGrid[i][j]) {
          show[i][j] = true;
          go = true;
        }
      }
    }
    number++;
  }
}
void keyPressed() {
  mouseControl = false;
  mouseClick = true;
  if (win || lose) {
    ini();
  }
  move();
  time_ = millis();
  keyPress = true;
}
void keyReleased() {
  if (keyCode == ENTER) {
    timeClick = millis() - time;
    if (timeClick >= waitTime) click[1] = true;
    else click[0] = true;
    timeClick = 0;
  }
  keyPress = true;
}
void mouseMoved() {
  mouseControl = true;
}
void mousePressed() {
  if (mouseButton == LEFT) mouseClick = true;
  if (win || lose) {
    ini();
  }
}
void mouseReleased() {
  if (mouseButton == RIGHT) click[1] = true;
  if (mouseButton == LEFT) {
    timeClick = millis() - time;
    if (timeClick >= waitTime) click[1] = true;
    else click[0] = true;
    timeClick = 0;
  }
}
void draw() {
  if (mouseControl) {
    if (mousePressed) cursor(MOVE);
    else cursor(HAND);
  } else cursor(WAIT);
  if (mouseClick) {
    time = millis();
    mouseClick = false;
  } else {
    keyTime = millis() - time_;
    if (keyTime >= keyWait && keyPress) {
      if (keyPressed) {
        move();
        time_ = millis();
      }
    }
  }
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      if (show[i][j] == mineGrid[i][j] && mineGrid[i][j]) {
        lose = true;
        for (int yy = 0; yy < rows; yy++) {
          for (int xx = 0; xx < cols; xx++) {
            show[xx][yy] = true;
          }
        }
        break;
      }
    }
  }
  int _c = 0;
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      if (show[i][j]) _c++;
    }
  }
  if (_c == rows*cols-mine) {
    win = true;
  }
  if (mines == 0) {
    boolean _win = true;
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        if (select[i][j] != mineGrid[i][j]) _win = false;
      }
    }
    if (!win) win = _win;
  }
  if (win || lose) {
    if (clear) mines = 0;
  } else timeDie = ((float)millis() - _time)/1000.0f;
  float w = pg_map.width/(cols+0.0), h = pg_map.height/(rows+0.0);
  if (clear) {
    pg_map.beginDraw();
    pg_map.colorMode(HSB, 360, 255, 255, 1);
    pg_map.textAlign(CENTER, CENTER);
    pg_map.background(255);
    pg_map.stroke(0);
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        pg_map.noFill();
        pg_map.rect(i*w, j*h, w, h);
        if (show[i][j]) {
          if (!mineGrid[i][j]) {
            pg_map.fill(0);
            pg_map.rect(i*w, j*h, w, h);
            if (count[i][j] != 0) {
              if (select[i][j]) {
                pg_map.text(".  "+count[i][j], w*(2*i+1)/2, h*(2*j+1)/2);
                pg_map.fill(255);
                pg_map.text("M  ", w*(2*i+1)/2, h*(2*j+1)/2);
              } else {
                pg_map.image(counter_mines[count[i][j]-1], w*i, h*j, w, h);
              }
            } else {
              if (select[i][j] && (win || lose)) {
                pg_map.fill(255);
                pg_map.text("-", w*(2*i+1)/2, h*(2*j+1)/2);
              }
            }
          } else {
            pg_map.fill(0);
            pg_map.rect(i*w, j*h, w, h);
            pg_map.fill(255);
            if (select[i][j]) {
              if (win || lose) mines++;
              pg_map.text("K", w*(2*i+1)/2, h*(2*j+1)/2);
              pg_map.stroke(0, 255, 0);
              pg_map.noFill();
              pg_map.rect(i*w, j*h, w, h);
            } else {
              pg_map.text("X", w*(2*i+1)/2, h*(2*j+1)/2);
              pg_map.stroke(255, 0, 0);
              pg_map.noFill();
              pg_map.rect(i*w, j*h, w, h);
            }
          }
        } else if (select[i][j]) {
          pg_map.fill(255);
          pg_map.rect(i*w, j*h, w, h);
          pg_map.fill(0);
          pg_map.text("M", w*(2*i+1)/2, h*(2*j+1)/2);
        }
      }
    }
    pg_map.endDraw();
    if (lose || win) {
      image(pg_map, 0, 0, width, height);
      String save = "games\\";
      save += year();
      save += "-";
      save += month();
      save += "-";
      save += day();
      save += "--";
      save += hour();
      save += "-";
      save += minute();
      save += "-";
      save += second();
      saveFrame(save+".png");
      PrintWriter output;
      output = createWriter(save+".txt");
      output.println(s_time(timeDie));
      if (win) output.println(mine+"/"+mine);
      else output.println(mines+"/"+mine);
      output.println("("+(float(mine)*100.0/float(cols*rows))+"%)");
      output.println(cols+" x "+rows);
      output.println();
      output.println("Diagonal: "+diagonal);
      output.println("Around: "+around);
      if (auto_remove) output.println("Auto removed");
      if (auto_mark) output.println("Auto marked");
      output.flush();
      output.close();
    }
  }
  pg_guide.beginDraw();
  pg_guide.image(pg_map, 0, 0);
  pg_guide.colorMode(HSB, 360, 255, 255, 1);
  if (mousePressed) {
    if (mouseButton == LEFT) {
      timeClick = millis() - time;
      float per = min(map(millis() - time, 0, waitTime, 0, PI*2), PI*2);
      pg_guide.strokeWeight(2);
      pg_guide.stroke(240, 255, 255);
      pg_guide.fill(270, 255, 255);
      pg_guide.arc(x_*w+w/2, y_*h+h/2, w, h, 0, per);
    }
  }
  if (keyPressed) {
    if (key == ENTER) {
      timeClick = millis() - time;
      float per = min(map(millis() - time, 0, waitTime, 0, PI*2), PI*2);
      pg_guide.strokeWeight(2);
      pg_guide.stroke(240, 255, 255);
      pg_guide.fill(270, 255, 255);
      pg_guide.arc(x_*w+w/2, y_*h+h/2, w, h, 0, per);
    }
  }
  if (mouseControl) {
    x_ = floor(map(mouseX, 0, width, 0, cols)); 
    y_ = floor(map(mouseY, 0, height, 0, rows));
  }
  int _x = x_, _y = y_;
  _x = max(0, _x);
  _x = min(_x, cols-1);
  _y = max(0, _y);
  _y = min(_y, rows-1);
  pg_guide.stroke(240, 255, 255);
  pg_guide.noFill();
  pg_guide.strokeWeight(3);
  pg_guide.rect(_x*w, _y*h, w, h);
  pg_guide.fill(240, 255, 255, .5);
  pg_guide.strokeWeight(1);
  if (mouse_show) {
    for (int j = -1; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        if (diagonal) {
          if ((abs(i) == 1) || (abs(j) == 1)) {
            if (around) {
              int xx = (_x+i) % cols;
              int yy = (_y+j) % rows;
              if (xx < 0 || xx >= cols) xx = cols - abs(xx);
              if (yy < 0 || yy >= rows) yy = rows - abs(yy);
              pg_guide.fill(240, 255, 255, .5);
              pg_guide.rect(xx*w, yy*h, w, h);
            } else {
              if ((i+_x >= 0 && i+_x < cols) && (j+_y >= 0 && j+_y < rows)) {
                pg_guide.fill(240, 255, 255, .5);
                pg_guide.rect((i+_x)*w, (j+_y)*h, w, h);
              }
            }
          }
        } else {
          if (abs(i) != abs(j)) {
            if (around) {
              int xx = (_x+i) % cols;
              int yy = (_y+j) % rows;
              if (xx < 0 || xx >= cols) xx = cols - abs(xx);
              if (yy < 0 || yy >= rows) yy = rows - abs(yy);
              pg_guide.fill(240, 255, 255, .5);
              pg_guide.rect(xx*w, yy*h, w, h);
            } else {
              if ((i+_x >= 0 && i+_x < cols) && (j+_y >= 0 && j+_y < rows)) {
                pg_guide.fill(240, 255, 255, .5);
                pg_guide.rect((i+_x)*w, (j+_y)*h, w, h);
              }
            }
          }
        }
      }
    }
  }
  pg_guide.noStroke();
  pg_guide.fill(255);
  int _s = speedAnimation;
  boolean[][] _show = new boolean[cols][rows];
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      _show[i][j] = show[i][j];
    }
  }
  if (clear && !click[0] && !click[1]) {
    boolean c1 = false, c2 = false;
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        if (show[i][j]) {
          if (_s <= 0) break;
          if (auto_remove || count[i][j] == 0) {
            if (!c1) c1 = nothing(i, j);
            else nothing(i, j);
          }
          if (auto_mark || count[i][j] == 0) { 
            if (!c2) c2 = mines(i, j);
            else mines(i, j);
          }
          _x = i;
          _y = j;
          for (int yy = 0; yy < rows; yy++) {
            for (int xx = 0; xx < cols; xx++) {
              if (show[xx][yy] != _show[xx][yy]) {
                _s--;
                break;
              }
            }
          }
        }
      }
    }
    clear = c1 || c2;
  }
  if (click[0]) {
    if (show[_x][_y]) nothing(_x, _y);
    if (select[_x][_y]) {
      select[_x][_y] = false;
      mines++;
    } else show[_x][_y] = true;
    click[0] = false;
    clear = true;
  }
  if (click[1]) {
    if (show[_x][_y]) clear = mines(_x, _y);
    else {
      select[_x][_y] = !select[_x][_y];
      if (select[_x][_y]) mines--;
      else mines++;
    }
    click[1] = false;
    clear = true;
  }
  boolean auto = auto_mark || auto_remove;
  if (auto) {
    pg_guide.stroke(240, 255, 255);
    pg_guide.noFill();
    pg_guide.strokeWeight(3);
    pg_guide.rect(_x*w, _y*h, w, h);
    pg_guide.strokeWeight(1);
    pg_guide.noStroke();
    pg_guide.fill(255);
  }
  if (lose) {
    pg_guide.fill(0, .375);
    pg_guide.rect(0, 0, pg_map.width, pg_map.height);
    pg_guide.textSize(cols*65/36);
    pg_guide.fill(255, .25);
    pg_guide.text("YOU LOSE", pg_map.width/2, pg_map.height/2.5);
    pg_guide.fill(0, 255, 255, .625);
    pg_guide.text("YOU LOSE", pg_map.width/2+1, pg_map.height/2.5+1);
    pg_guide.fill(0, .5);
    pg_guide.textSize(cols*33/36);
    pg_guide.text("\n\n\n"+mines+"/"+mine+" | "+s_time(timeDie)+"\nClick or key to restart", pg_map.width/2, pg_map.height/2.5);
    pg_guide.fill(255, .75);
    pg_guide.text("\n\n\n"+mines+"/"+mine+" | "+s_time(timeDie)+"\nClick or key to restart", pg_map.width/2+1, pg_map.height/2.5+1);
  }
  if (win) {
    pg_guide.fill(0, .375);
    pg_guide.rect(0, 0, pg_map.width, pg_map.height);
    pg_guide.textSize(cols*65/36);
    pg_guide.fill(120, 0, 255, .25);
    pg_guide.text("YOU WIN", pg_map.width/2, pg_map.height/2.5);
    pg_guide.fill(120, 255, 255, .625);
    pg_guide.text("YOU WIN", pg_map.width/2+1, pg_map.height/2.5+1);
    pg_guide.fill(0, .75);
    pg_guide.textSize(cols*33/36);
    pg_guide.text("\n\n\n"+mine+" - "+s_time(timeDie)+"\nClick or key to restart", pg_map.width/2, pg_map.height/2.5);
    pg_guide.fill(255, .75);
    pg_guide.text("\n\n\n"+mine+" - "+s_time(timeDie)+"\nClick or key to restart", pg_map.width/2+1, pg_map.height/2.5+1);
  }
  if (!lose && !win) {
    pg_guide.textAlign(LEFT, TOP);
    pg_guide.textSize(cols*34/36);
    pg_guide.fill(255, .5);
    pg_guide.text(mines+"\n"+s_time(((float)millis() - _time)/1000.0f), 0, 0);
    pg_guide.fill(0, .5);
    pg_guide.text(mines+"\n"+s_time(((float)millis() - _time)/1000.0f), 1, 1);
  }
  pg_guide.textAlign(CENTER, CENTER);
  pg_guide.textSize(11);
  pg_guide.endDraw();
  image(pg_guide, 0, 0, width, height);
}

void generate() {
  int m = mines;
  while (mines != 0) {
    int _x = floor(random(cols)), _y = floor(random(rows));
    if (!mineGrid[_x][_y]) {
      mines--;
      mineGrid[_x][_y] = true;
    }
  }
  mines = m;
}
void count(boolean d) {
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      if (mineGrid[i][j]) {
        for (int _y = -1; _y <= 1; _y++) {
          for (int _x = -1; _x <= 1; _x++) {
            if (!d) {
              if (abs(_x) != abs(_y)) {
                if (around) {
                  int xx = (_x+i) % cols;
                  int yy = (_y+j) % rows;
                  if (xx < 0 || xx >= cols) xx = cols - abs(xx);
                  if (yy < 0 || yy >= rows) yy = rows - abs(yy);
                  if (mineGrid[i][j]) count[xx][yy]++;
                } else {
                  if ((i+_x >= 0 && i+_x < cols) && (j+_y >= 0 && j+_y < rows)) {
                    if (mineGrid[i][j]) count[_x+i][_y+j]++;
                  }
                }
              }
            } else {
              if (around) {
                int xx = (_x+i) % cols;
                int yy = (_y+j) % rows;
                if (xx < 0 || xx >= cols) xx = cols - abs(xx);
                if (yy < 0 || yy >= rows) yy = rows - abs(yy);
                if (mineGrid[i][j]) count[xx][yy]++;
              } else {
                if ((i+_x >= 0 && i+_x < cols) && (j+_y >= 0 && j+_y < rows)) {
                  if (mineGrid[i][j]) count[_x+i][_y+j]++;
                }
              }
            }
          }
        }
      }
    }
  }
}
boolean nothing(int x, int y) {
  int _m = 0;
  boolean c = false;
  if (diagonal) {
    for (int _y = -1; _y <= 1; _y++) {
      for (int _x = -1; _x <= 1; _x++) {
        if (around) {
          int xx = (_x+x) % cols;
          int yy = (_y+y) % rows;
          if (xx < 0 || xx >= cols) xx = cols - abs(xx);
          if (yy < 0 || yy >= rows) yy = rows - abs(yy);
          if (select[xx][yy]) _m++;
        } else {
          if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
            if (select[x+_x][y+_y]) _m++;
          }
        }
      }
    }
    if (count[x][y] == _m) {
      for (int _y = -1; _y <= 1; _y++) {
        for (int _x = -1; _x <= 1; _x++) {
          if (around) {
            int xx = (_x+x) % cols;
            int yy = (_y+y) % rows;
            if (xx < 0 || xx >= cols) xx = cols - abs(xx);
            if (yy < 0 || yy >= rows) yy = rows - abs(yy);
            if (!select[xx][yy]) {
              if (!show[xx][yy]) c = true;
              show[xx][yy] = true;
            }
          } else {
            if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
              if (!select[x+_x][y+_y]) {
                if (!show[x+_x][y+_y]) c = true;
                show[x+_x][y+_y] = true;
              }
            }
          }
        }
      }
    }
  } else {
    for (int _y = -1; _y <= 1; _y++) {
      for (int _x = -1; _x <= 1; _x++) {
        if (abs(_x) != abs(_y)) {
          if (around) {
            int xx = (_x+x) % cols;
            int yy = (_y+y) % rows;
            if (xx < 0 || xx >= cols) xx = cols - abs(xx);
            if (yy < 0 || yy >= rows) yy = rows - abs(yy);
            if (select[xx][yy]) _m++;
          } else {
            if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
              if (select[x+_x][y+_y]) _m++;
            }
          }
        }
      }
    }
    if (count[x][y] == _m) {
      for (int _y = -1; _y <= 1; _y++) {
        for (int _x = -1; _x <= 1; _x++) {
          if (abs(_x) != abs(_y)) {
            if (around) {
              int xx = (_x+x) % cols;
              int yy = (_y+y) % rows;
              if (xx < 0 || xx >= cols) xx = cols - abs(xx);
              if (yy < 0 || yy >= rows) yy = rows - abs(yy);
              if (!select[xx][yy]) {
                if (!show[xx][yy]) c = true;
                show[xx][yy] = true;
              }
            } else {
              if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
                if (!select[x+_x][y+_y]) {
                  if (!show[x+_x][y+_y]) c = true;
                  show[x+_x][y+_y] = true;
                }
              }
            }
          }
        }
      }
    }
  }
  return c;
}
boolean mines(int x, int y) {
  int _m = 0;
  boolean c = false;
  if (diagonal) {
    for (int _y = -1; _y <= 1; _y++) {
      for (int _x = -1; _x <= 1; _x++) {
        if (around) {
          int xx = (_x+x) % cols;
          int yy = (_y+y) % rows;
          if (xx < 0 || xx >= cols) xx = cols - abs(xx);
          if (yy < 0 || yy >= rows) yy = rows - abs(yy);
          if (!show[xx][yy]) _m++;
        } else {
          if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
            if (!show[x+_x][y+_y]) _m++;
          }
        }
      }
    }
    if (count[x][y] == _m) {
      for (int _y = -1; _y <= 1; _y++) {
        for (int _x = -1; _x <= 1; _x++) {
          if (around) {
            int xx = (_x+x) % cols;
            int yy = (_y+y) % rows;
            if (xx < 0 || xx >= cols) xx = cols - abs(xx);
            if (yy < 0 || yy >= rows) yy = rows - abs(yy);
            if (!show[xx][yy]) {
              if (!select[xx][yy]) {
                mines--;
                c = true;
              }
              select[xx][yy] = true;
            }
          } else {
            if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
              if (!show[x+_x][y+_y]) {
                if (!select[x+_x][y+_y]) {
                  mines--;
                  c = true;
                }
                select[x+_x][y+_y] = true;
              }
            }
          }
        }
      }
    }
  } else {
    for (int _y = -1; _y <= 1; _y++) {
      for (int _x = -1; _x <= 1; _x++) {
        if (abs(_x) != abs(_y)) {
          if (around) {
            int xx = (_x+x) % cols;
            int yy = (_y+y) % rows;
            if (xx < 0 || xx >= cols) xx = cols - abs(xx);
            if (yy < 0 || yy >= rows) yy = rows - abs(yy);
            if (!show[xx][yy]) _m++;
          } else {
            if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
              if (!show[x+_x][y+_y]) _m++;
            }
          }
        }
      }
    }
    if (count[x][y] == _m) {
      for (int _y = -1; _y <= 1; _y++) {
        for (int _x = -1; _x <= 1; _x++) {
          if (abs(_x) != abs(_y)) {
            if (around) {
              int xx = (_x+x) % cols;
              int yy = (_y+y) % rows;
              if (xx < 0 || xx >= cols) xx = cols - abs(xx);
              if (yy < 0 || yy >= rows) yy = rows - abs(yy);
              if (!show[xx][yy]) {
                if (!select[xx][yy]) {
                  mines--;
                  c = true;
                }
                select[xx][yy] = true;
              }
            } else {
              if ((x+_x >= 0 && x+_x < cols) && (y+_y >= 0 && y+_y < rows)) {
                if (!show[x+_x][y+_y]) {
                  if (!select[x+_x][y+_y]) {
                    mines--;
                    c = true;
                  }
                  select[x+_x][y+_y] = true;
                }
              }
            }
          }
        }
      }
    }
  }
  return c;
}

void move() {
  if (keyCode == UP) {
    if (y_ - 1 >= 0) y_--;
    else y_ = rows - 1;
  }
  if (keyCode == DOWN) {
    if (y_ + 1 < rows) y_++;
    else y_ = 0;
  }
  if (keyCode == LEFT) {
    if (x_ - 1 >= 0) x_--;
    else x_ = cols - 1;
  }
  if (keyCode == RIGHT) {
    if (x_ + 1 < cols) x_++;
    else x_ = 0;
  }
}

String s_time(float seconds) {
  String time = "";
  int h = 0;
  int m = 0;
  float s = 0;

  h = floor(seconds/3600.0);
  m = floor((seconds - h*3600.0)/60.0);
  s = seconds - (h*3600.0 + m*60.0);

  if (h != 0) {
    time = h+" : "+m+"\' "+s+"\"";
  } else if (m != 0) {
    time = m+"\' "+s+"\"";
  } else {
    time = s+"\"";
  }
  return time;
}
boolean fileExists(String path) {
  File file=new File(path);
  println(path);
  println(file.getName());
  boolean exists = file.exists();
  if (exists) {
    println("true");
    return true;
  } else {
    println("false");
    return false;
  }
}
//https://forum.processing.org/two/discussion/7066/check-if-file-exist
//https://forum.processing.org/two/discussion/19478/can-you-reset-a-timer-using-millis