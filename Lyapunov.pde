import java.util.Arrays;
import java.awt.event.KeyEvent;

/*String ab = "aaaaaabbbbbb";
int ITERATIONS = 1000;
double warmup = 0.3;
double x1 = 3.2411;
double x2 = 3.241101;
double y1 = 3.6956;
double y2 = 3.695601;
double SCALE;*/

String ab = "ababababababbbbbaaaababbbbababababa";
int ITERATIONS = 5000;
double warmup = 0.3;
double x1 = 1.5;
double x2 = 2.5;
double y1 = 3.5;
double y2 = 4;
double SCALE;

int aa = 1;

boolean[] vals = new boolean[ab.length()];
color[] data;
double ilog2 = 1 / log(2);


void setup() {
  fullScreen();
  //size(1000, 1000);
  frameRate(30);
  
  double dx = x2 - x1;
  double dy = y2 - y1;
  double rx = dx / width;
  double ry = dy / height;
  
  if(rx > ry) {
    SCALE = rx;
  } else {
    SCALE = ry;
  }
  
  loadPixels();
  data = new color[pixels.length];
  Arrays.fill(data, color(0));
  
  for(int i = 0; i < vals.length; i++) {
    vals[i] = (ab.charAt(i) == 'a');
  }
  
  new Thread(new Runnable() {
    public void run() {
      for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
          int num = 1;
          color c = color(0);
          for(int dy = 0; dy < aa; dy++) {
            for(int dx = 0; dx < aa; dx++) {
              c = lerpColor(c, ltog(lyap((x + (float)(dx) / aa) * SCALE + x1, (y + (float)(dy) / aa) * SCALE + y1)), 1.0 / num);
              num++;
            }
          }
          data[(height - y - 1) * width + x] = c;
          //data[(height - y - 1) * width + x] = ltod(lyap(x * SCALE + x1, y * SCALE + y1));
          /*data[(height - y - 1) * width + x] =
            lerp(ltod(lyap(x * SCALE + x1, y * SCALE + y1));*/
        }
      }
    }
  }).start();
}

void draw() {
  System.arraycopy(data, 0, pixels, 0, pixels.length);
  updatePixels();
  if(mousePressed) {
    fill(255, 255, 0);
    text((mouseX * SCALE + x1) + "\n" + ((height - mouseY) * SCALE + y1), mouseX, mouseY + 32);
  }
}

double lyap(double a, double b) {
  double total = 0;
  double x = 0.5;
  for(int n = 0; n < ITERATIONS; n++) {
    double r = (vals[n % vals.length] ? a : b);
    x = r * x * (1 - x);
    if(n > ITERATIONS * warmup) {
      total += Math.log(dabs(r - (2 * r * x)));
    }
  }
  return total / ITERATIONS * (1 - warmup) * ilog2;
}

double normalize(double l) {
  return normalize(l, 1);
}

double normalize(double l, float grad) {
  if(l == Double.NEGATIVE_INFINITY) {
    return 0;
  } else if(l >= 0) {
    return 1;
  } else {
    return -grad / ((double)l - grad);
  }
}

//grayscale
color ltog(double l) {
  double n = normalize(l, 0.1);
  if(n == 1) {
    return color(0);
  } else {
    return color((int)(n * 255));
  }
}

//two colors
color ltot(double l) {
  if(l >= 0) {
    return color(255, 142, 0);
  } else {
    return color(64, 96, 32);
  }
}

//rainbow(ish)
color ltod(double l) {
  float n = (float)normalize(l, 0.5);
  float t[] = {0.3, 0.35, 0.4, 0.45, 0.48, 0.55, 0.75, 0.9};
  if(n == 1) {
    return color(255, 142, 0);
  } else if(n < t[0]) {
    return color(182, 0, 0);
  } else if(n < t[1]) {
    return color(map(n, t[0], t[1], 182, 192), map(n, t[0], t[1], 0, 0), map(n, t[0], t[1], 0, 96));
  } else if(n < t[2]) {
    return color(192, 0, 96);
  } else if(n < t[3]) {
    return color(map(n, t[2], t[3], 192, 48), map(n, t[2], t[3], 0, 16), map(n, t[2], t[3], 96, 96));
  } else if(n < t[4]) {
    return color(48, 16, 96);
  } else if(n < t[5]) {
    return color(map(n, t[4], t[5], 48, 64), map(n, t[4], t[5], 16, 128), map(n, t[4], t[5], 96, 164));
  } else if(n < t[6]) {
    return color(64, 128, 164);
  } else if(n < t[7]) {
    return color(map(n, t[6], t[7], 64, 64), map(n, t[6], t[7], 128, 96), map(n, t[6], t[7], 164, 32));
  } else {
    return color(64, 96, 32);
  }
}

//abs for doubles
double dabs(double d) {
  return d > 0 ? d : -d;
}

void keyPressed() { // saves a screenshot when [S] key is pressed
  if(keyCode == KeyEvent.VK_S) {
    save(year() + nf(month(),2) + nf(day(),2) + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".png");
  }
}