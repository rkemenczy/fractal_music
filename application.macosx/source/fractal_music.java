import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.signals.*; 
import ddf.minim.effects.*; 
import ddf.minim.analysis.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class fractal_music extends PApplet {

/* "RESPONSIVE MUSIC VISUALIZATION USING 2D FRACTAL STRUCTURES"

August 4th 2013
!!!!! ALPHA CODE !!!!! PLEASE READ !!!!! USAGE BELOW !!!!!

This code isn't meant for general release, but it works!
I intend to significantly improve, streamline and extend
it in the coming weeks. Replace "track.mix" below to
enable live music input! Allow the visualization to
run for a few minutes to adapt the amplitude range
to your selected track/type of music.

If you manage to upload a high-quality screencast and send
me the link before I manage to do so, I'd be very happy.

Feel free to contact me for any feedback and inquiries.


Enjoy!

Raffael K\u00e9m\u00e9nczy

contact@kemenczy.at
www.kemenczy.at


+++++USAGE+++++

Press "m" to cycle between 1) demo 2) music analysis and 3) manual user input mode.
Press "p" to loop the file named "track.mp3" located in the "data" subdirectory.
You may insert a supported MP3 file you own for this - pick you favourite track!
You may also use the supplied track which is free to use!

For music analysis mode:

Press "g" to reset learned amplitudes for all frequencies.

For manual mode:

Press "k" to clear the screen.
Press "i" to invert colours.
Press/hold "o" to dilate the drawing. [very slow in current implementation]
Press/hold "w" to increase size.
Press/hold "e" to decrease size.
Press/hold "r" to increase the number of sides / change the fractal shape.
Press/hold "t" to decrease the number of sides / change the fractal shape.

Left-click drag the mouse in order to change the strut factor along the X (width) axis.


*****Sources/Inspirations*****

Processing Reference and Tutorials
http://processing.org/

Fractal Code (Sutcliffe Pentagon) adapted from/inspired by the book Generative Art: A Practical Guide by Matt Pearson
http://abandonedart.org/

Music Analysis Code adapted from/inspired by @JoelleSnaith
http://www.openprocessing.org/sketch/101123

Switch Mechanics adapted from/inspired by Revlin John (Phono Divinoro)
http://stylogicalmaps.blogspot.hu/

Visualization of Fractal Structures inspired by Bashar Communications
http://bashar.org
*/







Minim minim;
AudioInput in;
AudioPlayer track;
//Waveline input_sketcher;

FFT fft;
  
int sampleRate = 44100;
int bufferSize = 512;
 
int fft_base_freq = 86; 
int fft_band_per_oct = 1;
int numZones = 0;

Frequency freq;
float[] freqArr;
float[] freqArrLast;
float[] maxArr;

float avgAvgNorm = 0;
float sumAvgNorm = 0;
float sumAvgNormLast = 0;

boolean play_track;

//=============================

float _strutFactor = 1;
float _strutNoise;
float _strutMin = -1;
float _strutMax = 2;
int _maxlevels = 3; //values 1-3 (performance)
int _minlevels = 1;
int _numSides = 3;
int _numMin = 3; // lower value breaks the code
int _numMax = 6; //reduced to 6 (performance)
int[] _numForbidden = {7, 11, 19, 21, 23, 25}; // make array with prohibited _numSide numbers because they don't create a symmetric(?) fractal
int _degCount = 360;
int mode = 0;
int cx = width/2;
int cy = height/2;
int lastcx, lastcy;
float _xNoise, _yNoise;
float _rad = 150;
float _radMin = 100;
float _radMax = 500;
int _r, _g;
int _b = 50;
int _alph = 100;
int val, val2, val3;
int _recursion = 0;


FractalRoot shape1;
FractalRoot shape2;
FractalRoot shape3;

// Remove to disable automatic fullscreen
public boolean sketchFullScreen() {
  return true;
}

public void setup() {
  size(displayWidth, displayHeight, OPENGL);
  smooth();
  frameRate(60);

  _strutNoise = random(10);
  _xNoise = random(10);
  _yNoise = random(10);
  
  
  //==============================================
  minim = new Minim(this);
  track = minim.loadFile("track.mp3", bufferSize);
  //track.loop();
  
  
  in = minim.getLineIn(Minim.STEREO, bufferSize);
  //==============================================
  

  freq = new Frequency();
  freq.initialize();
  
}

public void mouseDragged() {
  
  _strutFactor = map(mouseX, 0, width, _strutMin, _strutMax);
}

public void keyPressed() {
    if (key == 'm' || key == 'M') {
      
      if (mode < 2) { mode += 1; }
      else {mode = 0;}
    }
    if (key == 'p' || key == 'P') {
      playMode(0);
    }
    if (key == 'l' || key == 'L') {
      playMode(1);
    }
    
    if (key == 'g' || key == 'G') { 
    for (int i = 0; i < numZones; i++) {
      maxArr[i] = 0;
      }
    }
    
     if (key == 'k' || key == 'K') {
            fill(255, 255);
      rect(0, 0, width, height);
    }
    if (key == 'i' || key == 'I') {
      filter(INVERT);
  }
  if (key == 'o' || key == 'O') { filter(DILATE); }
      
      if (key == 'w' || key == 'W') { _rad += 10;}
      if (key == 'e' || key == 'E') { _rad -= 10;}
      
      if (key == 'r' || key == 'R') { if (_numSides <= _numMax) { _numSides += 1; println("Sides: "+_numSides);} }
      if (key == 't' || key == 'T') { if (_numSides > _numMin) { _numSides -= 1; println("Sides: "+_numSides);} }
  }

public void playMode(int i) {
  if(i == 0) {
    track.loop();
    //in.removeListener(input_sketcher);
    //groove.addListener(input_sketcher);
    play_track = true;
  } 
  if (i == 1) {
    //groove.removeListener(input_sketcher);
    //in.addListener(input_sketcher);
    track.pause();
    play_track = false;
  }
}

public void draw() {
  //background(255);
  fill(0, 20);
  rect(0,0,width,height);
  
  _strutNoise += 0.01f;
  _xNoise += 0.01f;
  _yNoise += 0.001f;
  
  freqArr = freq.analyze(1);
    
    
    // MUTED MODE
    
  if (mode == 0) { 
  _strutFactor = (noise(_strutNoise) * _strutMax) + _strutMin; // play with this
  _rad = (noise(_xNoise) * _radMax) + _radMin; //map(mouseX, 0, width, _radMin, _radMax)
  
  _numSides = _numMin + round(noise(_yNoise) * (_numMax - _numMin));
  
    for (int i = 0; i < _numForbidden.length; i++) {
  if (_numSides == _numForbidden[i]) {_numSides -= 1; println("numSides - 1:"+_numSides); break;}
  }
  
  
  _r = round(255*(noise(_yNoise)));
  _g = round(255*(noise(_xNoise)));
  _b = round(255*(noise(_strutNoise)));
  _alph = 100;
  
  _rad = 150;
  _radMin = 150;
  _radMax = 500;
  _recursion = 3;
  }
  
    // MUSIC ANALYSIS MODE
  
  if (mode == 1) { 
    
    // FREQUENCY AVERAGE PRINTOUT
   sumAvgNormLast = sumAvgNorm;
   float avgNorm = 0;
   
   for (int i = 0; i < freqArr.length; i++) {
    avgNorm += freqArr[i];
   }
   avgNorm /= freqArr.length;
   sumAvgNorm += avgNorm;
   avgAvgNorm = sumAvgNorm /frameCount;
   println("Average Norm: "+avgNorm+" Overall Average Norm: "+avgAvgNorm);
   
   
   // APPLY FREQUENCY ANALYSIS LOGIC HERE
   
   // OVERALL AMPLITUDE
   
   /*
   float vTotal = avgNormLast - avgNorm;
   
   if (vTotal >= 0) { boolean positive = true; }
   if (vTotal < 0) { boolean positive = false; }
   
   float vTotalPos = abs(vTotal); 
   float vBuffer = vTotalPos //log(vTotal*1000)*10
   
   if (positive = true) {vBuffer *= -1}
   if (positive = false) {vBuffer *= -1}
   */
   
   _alph = 100;
   
   _rad = round(map(avgNorm, 0, 1, _radMin, _radMax)); 
   //_radMax * avgNorm;
  //if (_rad < _radMin) {_rad = _radMin;}
  
   //_rad = (avgNorm * _radMax) + _radMin;
   
   // 0 ***** 0 Hz - 86 Hz ***** //
  // colour? 
   int i = 0;
   _b = round(freqArr[i] * 255);
   if (_b < 50) {_b = 50;}
   
   // 1 ***** 86 Hz - 172 Hz ***** //
   // KICK DRUM BOTTOM 80-100 Hz
   i = 1;
   
   //_recursion = round(map(freqArr[i], 0, 1, 1, 3));
   if (freqArr[i] <= 0.1f) {_recursion = 1;}
   if (freqArr[i] <= 0.6f) {_recursion = 2;}
   else {_recursion = 3;}
   
   
   // 2 ***** 172 Hz - 344 Hz ***** //
   // SNARE THUMP 200-300hz
   i = 2;
   
   if (freqArr[i] >= 0.66f) {
     if (_numSides >= _numMax) {_numSides = _numMin;}
     else {_numSides += 1;}
   }
   
   
   // 3 ***** 344 Hz - 689 Hz ***** //
   
   // 4 ***** 689 Hz - 1378 Hz ***** //
   i = 4;
   _g = round(freqArr[i] * 255) - 50;
   if (_g < 30) {_g = 0;}
   
   // 5 ***** 1378 Hz - 2756 Hz ***** // XXX snare? 
   // SNARE THWACK 1.5K - 2.5K, ++++
   i = 5;
   _strutFactor = map(freqArr[i], 0, 1, _strutMin, _strutMax);
   
   // 6 ***** 2756 Hz - 5512 Hz ***** //
   
   // 7 ***** 5512 Hz - 11025 Hz ***** //
   // SNARE SIZZLE 7K-10k
   i = 7;
   
   if (freqArr[i] <= 0.1f) {_maxlevels = 1;}
   if (freqArr[i] <= 0.5f) {_maxlevels = 2;}
   else {_maxlevels = 3;}
   //_maxlevels = round(map(freqArr[i], 0, 1, _minlevels, 3));
   
   // 8 ***** 11025 Hz - 22050 Hz ***** // XXX highest pitch +++++
   i = 8;
   _r = round(freqArr[i] * 255) - 25;
   if (_r < 25) {_r = 0;}
  }
  
  // GENERAL DRAWINGS AND VALUES
  
  cx = width/2;
  cy = height/2;
  
  for (int i = 0; i < _numForbidden.length; i++) {
  if (_numSides == _numForbidden[i]) {_numSides -= 1; println("numSides - 1:"+_numSides); break;}
  }
  

  shape1 = new FractalRoot(90+frameCount, _degCount, _rad, cx, cy, _r, _g, _b, _alph, _recursion); //use frameCount to spin
  shape1.drawShape();
  
  _strutNoise += 0.02f;
  _xNoise += 0.02f;
  _yNoise += 0.002f;

  shape3 = new FractalRoot(270+frameCount, _degCount+180, _rad/_numSides, cx, cy, _r, _g, _b, _alph-50, 2);
  shape3.drawShape();
  
}

  class PointObj {
    float x, y;
    PointObj(float ex, float why) {
      x = ex; 
      y = why;
    }
  }

  class FractalRoot {
    PointObj[] pointArr = {};
    Branch rootBranch;
    

    FractalRoot(float startAngle, float degCount, float radius, float centX, float centY, float r, float g, float b, float alph, int rec) {
      float angleStep = 360.0f/_numSides;
      
      int recLocal = rec;
      recLocal -= 1;
      
      
      
      for (float i = 0; i< _degCount; i += angleStep) {
        float x = centX + (radius * cos(radians(startAngle + i)));
        float y = centY + (radius * sin(radians(startAngle + i)));
        pointArr = (PointObj[])append(pointArr, new PointObj(x, y));
        
        if (recLocal > 0) {
          shape2 = new FractalRoot(270-frameCount, _degCount+180, _rad/_numSides, x, y, r, g, b, alph, recLocal);
          //if (recLocal < _recursion) {r -= 10; alph -= 10;}
          stroke(r, g, b, alph);
          shape2.drawShape();
        }
        
      }
      
      

      rootBranch = new Branch(0, 0, pointArr);
    }

    public void drawShape() {
      
      rootBranch.drawMe();
    }
  }

  class Branch {
    int level, num;
    PointObj[] outerPoints = {
    };
    PointObj[] midPoints = {
    };
    PointObj[] projPoints = {
    };
    Branch[] myBranches = {
    };

    Branch(int lev, int n, PointObj[] points) {
      level = lev;
      num = n;
      outerPoints = points;
      midPoints = calcMidPoints();
      projPoints = calcStrutPoints();

      if ((level+1) < _maxlevels) {
        Branch childBranch = new Branch(level+1, 0, projPoints);
        myBranches = (Branch[])append(myBranches, childBranch);

        for (int k = 0; k < outerPoints.length; k++) {
          int nextk = k-1;
          if (nextk < 0) { 
            nextk += outerPoints.length;
          }
          PointObj[] newPoints = { 
            projPoints[k], midPoints[k], outerPoints[k], midPoints[nextk], projPoints[nextk]
          };
          childBranch = new Branch(level+1, k+1, newPoints);
          myBranches = (Branch[])append(myBranches, childBranch);
        }
      }
    }

    public void drawMe() {
      strokeWeight(5 - level);
      
      
      for (int i = 0; i < outerPoints.length; i++) {
        int nexti = i+1;
        if (nexti == outerPoints.length) { 
          nexti = 0;
        }
        line(outerPoints[i].x, outerPoints[i].y, outerPoints[nexti].x, outerPoints[nexti].y);
      }

  

      for (int k = 0; k < myBranches.length; k++) {
        myBranches[k].drawMe();
      }
    }

    public PointObj[] calcMidPoints() {
      PointObj[] mpArray = new PointObj[outerPoints.length];
      for (int i = 0; i < outerPoints.length; i++) {
        int nexti = i+1;
        if (nexti == outerPoints.length) { 
          nexti = 0;
        }
        PointObj thisMP = calcMidPoint(outerPoints[i], outerPoints[nexti]);
        mpArray[i] = thisMP;
      }
      return mpArray;
    }

    public PointObj calcMidPoint(PointObj end1, PointObj end2) {
      float mx, my;
      if (end1.x > end2.x) { 
        mx = end2.x + ((end1.x - end2.x)/2);
      }
      else { 
        mx = end1.x + ((end2.x - end1.x)/2);
      }

      if (end1.y > end2.y) {
        my = end2.y + ((end1.y - end2.y)/2);
      }
      else { 
        my = end1.y + ((end2.y - end1.y)/2);
      }

      return new PointObj(mx, my);
    }

    public PointObj[] calcStrutPoints() {
      PointObj[] strutArray = new PointObj[midPoints.length];

      for (int i = 0; i < midPoints.length; i++) {
        int nexti = i+3;
        if (nexti >= midPoints.length) { 
          nexti -= midPoints.length;
        }
        PointObj thisSP = calcProjPoint(midPoints[i], outerPoints[nexti]);
        strutArray[i] = thisSP;
      }
      return strutArray;
    }

    public PointObj calcProjPoint(PointObj mp, PointObj op) {
      float px, py;
      float adj, opp;
      if (op.x > mp.x) { 
        opp = op.x - mp.x;
      }
      else { 
        opp = mp.x - op.x;
      }

      if (op.y > mp.y) { 
        adj = op.y - mp.y;
      }
      else { 
        adj = mp.y - op.y;
      }

      if (op.x > mp.x) { 
        px = mp.x + (opp * _strutFactor);
      }
      else { 
        px = mp.x - (opp * _strutFactor);
      }

      if (op.y > mp.y) { 
        py = mp.y + (adj * _strutFactor);
      }
      else { 
        py = mp.y - (adj * _strutFactor);
      }
      return new PointObj(px, py);
    }
  }

public void stop() {
  in.close();
  track.close();
  minim.stop();
}

//====================================================================
class Frequency 
{
  /*
  Minim minim;
  AudioInput in;
  AudioPlayer track;
  
  FFT fft;
    
  int sampleRate = 44100;
  int bufferSize = 512;
   
  int fft_base_freq = 86; 
  int fft_band_per_oct = 1;
  int numZones = 0;
  */
  //Frequency()  {}
  
  
  public void initialize() {
   /*
    minim = new Minim(this);
    track = minim.loadFile("track.mp3", bufferSize);
    track.loop();
    */
    fft = new FFT(bufferSize, sampleRate);    
    fft.logAverages(fft_base_freq, fft_band_per_oct);
   
    fft.window(FFT.HAMMING);
   
    numZones = fft.avgSize(); 
    
    float[] freqArr = new float[numZones];
    freqArrLast = new float[numZones];
    maxArr = new float[numZones]; // WAS "float[]" THE ISSUE??!
    
    println("numZones: "+numZones);
    println("freqArr: "+freqArr.length+" maxArr: "+maxArr.length);
    
    for (int i = 0; i < numZones; i++) {
     freqArr[i] = 0;
     freqArrLast[i] = 0;
     maxArr[i] = 0;
     println("freqArr: "+freqArr[i]+"maxArr: "+maxArr[i]);
    }
    
    
    println("Initialized...");
  }
  
  public void store(float[] fArr) {
    freqArrLast = new float[fArr.length];
    arrayCopy(fArr, freqArrLast);
    //for (int i = 0; i < fArr.length; i++) {
    //freqArrLast[i] = fArr[i];
    //}
  }
  
  public float[] analyze(int n) {
    
    println("=========="+frameCount+"==========");
    
    float[] freqArr = new float[numZones];
   //println("Start: freqArr: "+freqArr.length+"maxArr: "+maxArr.length);
    
    if (play_track = true) { 
    fft.forward(track.mix); // change to "fft.forward(in.mix)" for live input [works at least with integrated microphones]
    }
    if (play_track = false) {
      println("mixing input");
      fft.forward(in.mix);
    }
    
    int highZone = numZones - 1;
    
   
    for (int i = 0; i < numZones; i++) {
   
      float average = fft.getAvg(i); 
   
      float avg = 0;
      int lowFreq;
   
      if ( i == 0 ) {
        lowFreq = 0;
      }
      else {
        lowFreq = (int)((sampleRate/2) / (float)Math.pow(2, numZones - i)); // 0, 86, 172, 344, 689, 1378, 2756, 5512, 11025
      }
      int hiFreq = (int)((sampleRate/2) / (float)Math.pow(2, highZone - i)); // 86, 172, 344, 689, 1378, 2756, 5512, 11025, 22050
  
   
      int lowBound = fft.freqToIndex(lowFreq);
      int hiBound = fft.freqToIndex(hiFreq);
   
      for (int j = lowBound; j <= hiBound; j++) { // j is 0 - 256
   
        float spectrum = fft.getBand(j); 
   
        avg += spectrum; 
      }
   
      avg /= (hiBound - lowBound + 1);
      average = avg;
      
      
      freqArr[i] = avg;
      
        if (n == 0) {
        println("f: ("+i+") "+avg); 
        }
      
      
      if (n == 1) {  
       
       if (avg > maxArr[i]) {
         maxArr[i] = avg;
       }
         float norm = map(avg, 0, maxArr[i], 0, 1);
         freqArr[i] = norm;
       
       //println("End: freqArr: "+freqArr.length+"maxArr: "+maxArr.length);
       println("f: ("+i+") Value: "+avg+" Norm: "+freqArr[i]+" Max: "+maxArr[i]);
       
       
       /*
       if (avg != freqArrLast[i]) {
         freqArrLast[i] = avg;
       }
       */
       
       }
       
    }
  
  //store(freqArr);
  return freqArr;
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "fractal_music" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
