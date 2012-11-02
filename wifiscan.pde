/* Wi-fi scanner by Kof 2012
 *
 */

float HIGH = -40;
float LOW = -100;
float SPEED = 300.0;

float slow = -100;
float shigh = 100;

int CYCLE = 10;

boolean hasnew;

String raw[];
ArrayList <AccessPoint> ap;
ArrayList essids, signals, locked;
PFont font;
PImage lck;

void setup() {

  size(1024, 600, P2D);

  font = loadFont("65Amagasaki-8.vlw");
  textFont(font);
  textMode(SCREEN);

  lck = loadImage("lock.png");

  noCursor();

  textAlign(RIGHT);

  colorMode(HSB);

  ap = new ArrayList();
  essids = new ArrayList();
  signals = new ArrayList();

  locked = new ArrayList();

  reload();
}

void reload() {

  raw = loadStrings("scan.txt");

  if (raw.length>0)
    parse();
}

void parse() {

  essids = new ArrayList();
  signals = new ArrayList();
  locked = new ArrayList(); 
  for (int i = 0 ; i < raw.length; i++) {


    if (raw[i].indexOf("ESSID")>-1) {
      String essidln = raw[i];
      String[] vars = splitTokens(essidln, ":\"\t ");
      try {
        essids.add(vars[1]);
      }
      catch(Exception e) {
        ;
      }
    }
    if (raw[i].indexOf("Quality")>-1) {
      String essidln = raw[i];
      String[] vars = splitTokens(essidln, "= /:");
      try {
        float perc = parseFloat(vars[5]);

        //println(vars[5]);
        signals.add(perc);
      }
      catch(Exception e) {
        ;
      }
    }

    if (raw[i].indexOf("Encryption")>-1) {
      String essidln = raw[i];
      String[] vars = splitTokens(essidln, ":");
      try {
        boolean on = vars[1].equals("on");

        //println(vars[5]);
        locked.add(on);
      }
      catch(Exception e) {
        ;
      }
    }
  }


  castObjects();
}

void castObjects() {

  if (essids.size()==signals.size() && 
      essids.size()==locked.size())
    for (int i = 0 ; i < essids.size();i++) {
      String name = (String)essids.get(i);
      float signal = (Float)signals.get(i);
      boolean lock = (Boolean)locked.get(i);

      boolean isonlist = false;
      for (int q =  0 ; q < ap.size();q++) {
        AccessPoint tmp = (AccessPoint)ap.get(q);
        if (tmp.name.equals(name)) {
          isonlist = true;
          tmp.setSignal(signal);
        }
      }

      if (!isonlist) {
        ap.add(new AccessPoint(name, signal, lock));
        hasnew = true;
      }
    }
}



void draw() {


  background(0);

  if (hasnew) {
    fill(255);
    noStroke();
    rect(10, 10, 30, 30);
  }


  hasnew = false;


  if (frameCount%CYCLE==0) {
    reload();
  }


  fill(255);

  HIGH = -200;
  LOW = 200;
  for (int i = 0 ; i < ap.size();i++) {

    AccessPoint tmp  = (AccessPoint)ap.get(i);
    tmp.minmax();
  }

  slow+=(LOW-slow)/20.0;
  shigh+=(HIGH-shigh)/20.0;

  for (int i = 0 ; i < ap.size();i++) {

    AccessPoint tmp  = (AccessPoint)ap.get(i);

    tmp.update();
    tmp.plot();
  }

  textAlign(LEFT);
  fill(255);
  text(ap.size()+" siti v dosahu",10,height-5);

  stroke(255,30);
  fill(255,40);
  for(int i = -120; i < 0 ;i++){
    float m = map(i,slow,shigh,height-10,10);
    line(0,m,width,m);
    text(i+" dBm",10,m);
  }

  textAlign(RIGHT);

}

class AccessPoint {

  String name;
  float signal, ssignal;
  ArrayList graph;
  color c; 
  float seen, lastseen;
  boolean lock;

  AccessPoint(String _name, float _signal, boolean _lock) {
    name = _name;

    lock = _lock;

    ssignal = signal = _signal;
    c = color(random(255), 200, 255);
    graph = new ArrayList();
    seen = millis();
  }

  void setSignal(float _signal) {
    signal = _signal;
    seen = millis();
  }

  void update() {
    ssignal += (signal-ssignal)/SPEED;
    graph.add(ssignal);
    if (graph.size()>width)
      graph.remove(0);

    lastseen = (millis()-seen);

    if (lastseen>60000)
      ap.remove(this);
  }

  void minmax() {
    for (int i = 0; i < graph.size();i++) {
      float val = (Float)graph.get(i);
      if (val>HIGH)
        HIGH = val;
      if (val<LOW)
        LOW = val;
    }
  }

  void plot() {
    beginShape();
    stroke(c, 90);
    noFill();

    float lastval = 0;
    for (int i = 0; i < graph.size();i++) {
      float val = (Float)graph.get(i);
      float mapped = map(val, slow, shigh, height-10, 10);
      vertex(i+(width-graph.size()), mapped);
      lastval = mapped;
    }
    endShape();


    fill(c);
    text(name, width, lastval);

    if (lock) {
      //tint(c);
      image(lck, width - textWidth(name)-7, (int)lastval-6);
    }
  }
}

