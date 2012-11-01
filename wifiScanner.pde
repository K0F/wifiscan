float HIGH = -40;
float LOW = -90;
float SPEED = 300.0;

int CYCLE = 10;

boolean hasnew;

String raw[];
ArrayList <AccessPoint> ap;
ArrayList essids,signals;



void setup(){

  size(1024,600,P2D);

  textFont(loadFont("65Amagasaki-8.vlw"));
  textMode(SCREEN);
  
  noCursor();

  textAlign(RIGHT);

  colorMode(HSB);

  ap = new ArrayList();
  essids = new ArrayList();
  signals = new ArrayList();

  reload();

}

void reload(){

  raw = loadStrings("scan.txt");

  if(raw.length>0)
    parse();

}

void parse(){

  essids = new ArrayList();
  signals = new ArrayList();

  for(int i = 0 ; i < raw.length; i++){


    if(raw[i].indexOf("ESSID")>-1){
      String essidln = raw[i];
      String[] vars = splitTokens(essidln,":\"\t ");
      if(vars.length>=1)
      essids.add(vars[1]);
    }
    if(raw[i].indexOf("Quality")>-1){
      String essidln = raw[i];
      String[] vars = splitTokens(essidln,"= /:");
      if(vars.length>=5){
      float perc = parseFloat(vars[5]);
      
      //println(vars[5]);
      signals.add(perc);
      }
    }


  }

  castObjects();

}

void castObjects(){

  if(essids.size()==signals.size())
  for(int i = 0 ; i < essids.size();i++){
    String name = (String)essids.get(i);
    float signal = (Float)signals.get(i);


    boolean isonlist = false;
    for(int q =  0 ; q < ap.size();q++){
      AccessPoint tmp = (AccessPoint)ap.get(q);
      if(tmp.name.equals(name)){
        isonlist = true;
        tmp.setSignal(signal);
      }
    }

    if(!isonlist){
      ap.add(new AccessPoint(name,signal));
      hasnew = true;  
  }


  } 

}



void draw(){


  background(hasnew?255:0);
  
  
  hasnew = false;
  
  
  if(frameCount%CYCLE==0){
    reload();
  }


  fill(255);


  for(int i = 0 ; i < ap.size();i++){

    AccessPoint tmp  = (AccessPoint)ap.get(i);

    tmp.update();
    tmp.plot();
  }



}

class AccessPoint{

  String name;
  float signal,ssignal;
  ArrayList graph;
  color c; 
  float seen,lastseen;

  AccessPoint(String _name,float _signal){
    name = _name;

    ssignal = signal = _signal;
    c = color(random(255),200,255);
    graph = new ArrayList();
    seen = millis();
  }

  void setSignal(float _signal){
    signal = _signal;
    seen = millis();
  }

  void update(){
    ssignal += (signal-ssignal)/SPEED;
    graph.add(ssignal);
    if(graph.size()>width)
      graph.remove(0);
      
      lastseen = (millis()-seen);
      
      if(lastseen>60000)
      ap.remove(this);
      
  }

  void plot(){
    beginShape();
    stroke(c);
    noFill();

    float lastval = 0;
    for(int i = 0; i < graph.size();i++){
      float val = (Float)graph.get(i);
      float mapped = map(val,HIGH,LOW,0,height);
      vertex(i,mapped);
      lastval = mapped;
    }
    endShape();


    fill(c);
    text(name,graph.size(),lastval);

  }


}


