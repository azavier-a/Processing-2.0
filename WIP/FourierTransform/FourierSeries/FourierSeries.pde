import CiSlib.*;

Cam cam;

ArrayList<CNum> in;
CNum[] input, dft;

void setup() {
  size(900, 900);
  cam = new Cam();
  frameRate(60);
  noFill();
  ellipseMode(RADIUS);
  colorMode(HSB, 100, 100, 100);
  
  in = new ArrayList();
  
  CNum tot = CiSMath.fromCart(0, 0);
  double th = random(0, TAU), tol = TAU/18  , am = 0.25;
  for(int i = 0; i < 600; i++) {
    in.add(tot.clone());
    tot.add(CiSMath.fromCart(am*Math.cos(th), am*Math.sin(th)));
    
    th += random((float)-tol, (float)tol);
  }
  
  dft = CiSMath.FSCDFT(in.toArray(new CNum[in.size()]));
  quicksort(dft, 0, dft.length-1);
}

void mouseDragged() {
  cam.acc.add(CiSMath.fromCart( (mouseX-pmouseX)*0.2717, (mouseY-pmouseY)*0.2717) );
}

void mouseWheel(MouseEvent e) {
  cam.loZoom = e.getCount() > 0 ? cam.loZoom - 0.15 : cam.loZoom + 0.15;
  println(cam.loZoom);
}

double t = 0;
void draw() {
  background(60);
  cam.update();
  double[]camInf = cam.pos.get(), camInf2 = cam.anchor.get();
  translate((float)(camInf[0]+camInf2[0]), (float)(camInf[1]+camInf2[1]));
  scale((float)cam.loZoom);
  
  for(int i = 0; i < in.size(); i++) {
    double[] inf = in.get(i).get();
    strokeWeight(1);
    stroke(map(i, 0, in.size(), 0, 100), 100, 100);
    point((float)inf[0], (float)inf[1]);
  }
  
  int N = dft.length;
  CNum tot = CiSMath.fromCart(0, 0);
  for(int n = 0; n < N; n++) {
    double bef[] = tot.get(), aft[], inf[] = dft[n].get(), th = inf[2]+inf[4]*t;
    
    tot.add(CiSMath.fromCart(inf[3]*Math.cos(th), inf[3]*Math.sin(th)));
    aft = tot.get();
    
    strokeWeight(0.05);
    stroke(0);
    line((float)bef[0], (float)bef[1], (float)aft[0], (float)aft[1]);
    strokeWeight(1);
    //point((float)aft[0], (float)aft[1]);
  }
  cam.fixate(tot);
  
  double[] tmpInf = tot.get();
  strokeWeight(0.2);
  stroke(0, 0, 100);
  point((float)tmpInf[0], (float)tmpInf[1]);
  
  //t = (t + N/TAU*S)%N;
  t = (t + TAU/N)%N;
}

void quicksort(CNum[] arr, int low, int high) {
  if (low < high) {
    CNum p = arr[high];
    int ind, i = low-1;

    for (int j = low; j < high; j++)
      if (arr[j].get()[3] > p.get()[3]) {
        i++;
        swap(arr, i, j);
      }
    swap(arr, i+1, high);
    ind = i+1;

    quicksort(arr, low, ind-1);
    quicksort(arr, ind+1, high);
  }
}
void swap(CNum[] arr, int a, int b) {
  CNum tmp = arr[a];
  arr[a] = arr[b];
  arr[b] = tmp;
}

class Cam {
  CNum pos, vel, acc, anchor;
  double maxspeed = 5, loZoom = 3;
  Cam() {
    this.pos = CiSMath.fromPolar(0, 0);
    this.vel = CiSMath.fromPolar(0, 0);
    this.acc = CiSMath.fromPolar(0, 0);
    this.anchor = CiSMath.fromPolar(0, 0);
  }
  
  void fixate(CNum pos) { // D = T - P : S = D - V
    CNum t = pos.clone();
    t.sub(CiSMath.fromCart(width/(2*loZoom), height/(2*loZoom)));
    this.anchor = CiSMath.mult(t, -loZoom);
  }
  
  void update() {
    this.vel.add(this.acc);
    this.vel.limitMag(this.maxspeed);
    this.pos.add(this.vel);
    
    this.acc.setP(0, 0);
    this.vel.mult(0.75);
    this.loZoom = loZoom >= 50 ? 50 : loZoom;
    this.loZoom = loZoom <= 0.05 ? 0.05 : loZoom;
  } 
}
