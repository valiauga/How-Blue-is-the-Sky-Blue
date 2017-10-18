import processing.serial.*;
import processing.video.*;

Capture cam;

String localTimeStr;
int h, m;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

void setup() {
  size(600, 400);
  String[] cameras = Capture.list();


  for (int i = 0; i < cameras.length; i++) {
    println(cameras[i]);
  }  
  cam = new Capture(this, width, height, cameras[0], 30);
  //cam = new Capture(this, cameras[0]);
  cam.start();

  //String portName = Serial.list()[9]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, "/dev/tty.usbmodem1421", 9600);
  //println(Serial.list());
}
boolean ok=true;
void draw() {
  println("frame rate: " + frameRate);
  //if (frameCount % 60 == 0) screenshot();
  
  if (cam.available() == true) {
    cam.read();
  }

  if (millis()<5000)return;

  
  image (cam, 0, 0);

  loadPixels();
  cam.loadPixels();

  //red, green and blue accumulators
  float rAcc = 0;
  float gAcc = 0;
  float bAcc = 0;

  //red, green and blue value averages
  float rAvg = 0;
  float gAvg = 0;
  float bAvg = 0;

  //total number of pixels for calculating average color
  int numPix = cam.width * cam.height;

  // Loop through the pixels
  for (int x = 0; x < cam.width; x ++ ) {
    for (int y = 0; y < cam.height; y ++ ) {

      int loc = x + y*cam.width;            
      color current = cam.pixels[loc];      

      // Add the current red, green and blue values to the accumulators
      rAcc += red(current);
      gAcc += green(current);
      bAcc += blue(current);
    }
  }

  // Average red, green and blue values by dividing the accumulator by the number of pixels
  rAvg = rAcc / numPix;
  gAvg = gAcc / numPix;
  bAvg = bAcc / numPix;

  //Average color to HEX
  color averageRGB = color(rAvg, bAvg, bAvg);
  println(hex(averageRGB));
  //String averageHEX = hex(averageRGB);

  //Celeste color to HEX
  //color celesteRGB = color(178, 255, 255);
  color skyBlueRGB = color(138, 186, 211);
  //String celesteHEX = hex(averageRGB);
  // Set fill color to average value
  //fill(color(rAvg, gAvg, bAvg));

  CCielab ca = new CCielab(color(skyBlueRGB));
  CCielab cb = new CCielab(color(averageRGB));
  float delta = cb.deltaE(ca);
  //println(delta);

  //deltaE, inverted and turned into percentage value of color similarity
  float deltaInverted = map(delta, 77, 0, 0, 100);
  println("Sky is currently", deltaInverted + " %" + " sky blue");

  //MY FLOAT ROUNDING FORMULA
  float deltaInvertedRounded = ((int)(deltaInverted * 100 + .5) / 100.00);


  //fill rect with AVG color
  fill(color(rAvg, gAvg, bAvg));

  //-----------SENDING STUFF---------

  //LED LINE_1
  int index=floor(millis()/1000.0);
  String locationTime="T: "+localTimeStr+" <- "+"L: MILAN" + " <- ";
  String displayline_1="";
  for (int i=0; i<10; i++) {
    int char_index=(index+i)%locationTime.length();
    displayline_1+=locationTime.charAt(char_index);
  }
  h = hour();
  m = minute();


  //LED LINE_2
  String displayline_2 = "SKY IS NOW ";

  //LED LINE_3
  String skyColor =  "  "+(deltaInvertedRounded + "%");


  //LED LINE_4
  String text_displayline_4 = ">- EULB YKS / 8134-41 GPT ENOTNAP";
  String displayline_4="";
  for (int i = 11; i > 0; i--) {
    int char_index=(index+(i))%text_displayline_4.length();
    displayline_4+=text_displayline_4.charAt(char_index);
  }

  //CONSTRUCTING STRING FOR SENDING
  String fullstring="@255,255,255*"+displayline_1 +"@0,0,255*"+displayline_2+"@0,0,255*"+skyColor+" @255,255,255*"+displayline_4+"\n";
  //String fullstring="\t@255,255,255*"+displayline_1 +"@"+rAvg+","+gAvg+","+bAvg+"*"+displayline_2+"@0,0,255*"+skyColor+" @255,255,255*"+displayline_4+"\n";
  println(fullstring);
  myPort.write(fullstring);
  delay(500);
  if (myPort.available()>0) {
    println(myPort.readString());
  }
  time();
}



void time() {
  //println(h + "/" + m);
  localTimeStr = str(h) + "/" + str(m);
}