/* "RESPONSIVE MUSIC VISUALIZATION USING 2D FRACTAL STRUCTURES"

GITHUB: https://github.com/rkemenczy/fractal_music

Feel free to contact me for any feedback and inquiries.

Enjoy!

Raffael Kéménczy

contact@kemenczy.at
www.kemenczy.at
*/

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
AudioPlayer track;

// Setup for music analysis

FFT fft;
int sampleRate = 44100;
int bufferSize = 512;
int fft_base_freq = 86; 
int fft_band_per_oct = 1;
int numZones = 0;

Frequency freq;

float avgAvgNorm = 0;
float sumAvgNorm = 0;
float sumAvgNormLast = 0;

boolean play_track;

//=============================

float _strutFactor = 1; // Initialisation of strut factor
float _strutNoise;
float _strutMin = -1; // Minimum strut value
float _strutMax = 2; // Maximum strut value
int _maxlevels = 3; // 
int _minlevels = 1; // 
int _numSides = 3; // Initialisation value of sides of the fractal
int _numMin = 3; // Minimum number of sides of the fractal, need 3 to make a triangle, lower value breaks the code
int _numMax = 6; // Maximum number of sides of the fractal (capped at 6 performance)
int[] _numForbidden = {7, 11, 19, 21, 23, 25}; // make array with prohibited _numSide numbers because they don't create a symmetric(?) fractal and look ugly
int _degCount = 360;
int mode = 0;
int cx = width/2;
int cy = height/2;
int lastcx, lastcy;
float _xNoise, _yNoise; // Noise values for random mode
float _rad = 150; // Initialisation value of radius
float _radMin = 100; // Minimum radius allowed - adjust to screen size
float _radMax = 500; // Maximum radius allowed - adjust to screen size
int _r, _g; //
int _b = 50;
int _alph = 100;
int val, val2, val3;
int _recursion = 0; // Initialisation value of drawn fractal recursion
int play_mode = -1;


FractalRoot shape1;
FractalRoot shape2;
FractalRoot shape3;

// +++ UNCOMMENT TO ENABLE AUTOMATIC FULLSCREEN +++
//boolean sketchFullScreen() {
//  return true;
//}

void setup() {
  size(displayWidth, displayHeight, OPENGL); // Adjust to screen resolution as needed
  smooth();
  frameRate(60); // 60 FPS for high quality

  _strutNoise = random(10);
  _xNoise = random(10);
  _yNoise = random(10);
  
  
  //==============================================
  minim = new Minim(this);
  track = minim.loadFile("track.mp3", bufferSize); // need a "track.mp3" file in "/data" folder
  in = minim.getLineIn(Minim.STEREO, bufferSize);
  //==============================================
  

  freq = new Frequency(minim, in, track, fft, sampleRate,
    bufferSize, fft_base_freq, fft_band_per_oct, numZones );
  freq.initialize();
  
  /* Starting with track playing in analysis mode because this seems to fix an initial faulty analysis of line-in data */
  mode = 1;
  play_mode = 0;
  playMode( play_mode );
  
}

void mouseDragged() {
  
  _strutFactor = map(mouseX, 0, width, _strutMin, _strutMax);
}

void keyPressed() {
  // Press "m" to toggle between random, manual mouse input and music analysis modes.
    if (key == 'm' || key == 'M') {
      if (mode < 2) { mode += 1; }
      else {mode = 0;}
    }
    // Press "p" to toggle music play mode
    if (key == 'p' || key == 'P') {
      if( play_mode != 0 ) {
        play_mode = 0;
        playMode( play_mode );
      } else {
        play_mode = -1;
        playMode( play_mode );
      }
    }
    // Press "l" to toggle line-in mode
    if (key == 'l' || key == 'L') {
      println("Line-in");
      playMode(1);
    }
    // Press "g" to re-set maximum absolute frequency values detected (used to enable percentage-based processing)
    if (key == 'g' || key == 'G') { 
    for (int i = 0; i < numZones; i++) {
      freq.maxArr[i] = 0;
      }
    }
    // Press "k" to fill black
     if (key == 'k' || key == 'K') {
            fill(255, 255);
      rect(0, 0, width, height);
    }
    // Press "i" to invert colours
    if (key == 'i' || key == 'I') {
      filter(INVERT);
  }
  // Press "o" to dilate (uses processing power)
  if (key == 'o' || key == 'O') { filter(DILATE); }
      
      // Change radius and number of sides in manual input mode
      if (key == 'w' || key == 'W') { _rad += 10;}
      if (key == 'e' || key == 'E') { _rad -= 10;}
      
      if (key == 'r' || key == 'R') { if (_numSides <= _numMax) { _numSides += 1; println("Sides: "+_numSides);} }
      if (key == 't' || key == 'T') { if (_numSides > _numMin) { _numSides -= 1; println("Sides: "+_numSides);} }
  }

void playMode(int i) {
  if(i == 0) {
    //in.removeListener(freq);
    track.loop();
    play_track = true;
  } else if (i == 1) {
    track.pause();
    in.addListener(freq);
    play_track = false;
  } else if (i < 0) {
    track.pause();
    play_track = false;
  }
}

void draw() {
  fill(0, 18); // Change value for different fade effect intensity [Idea: Influence via music or implement real blur?]
  rect(0,0,width,height);
  
  _strutNoise += 0.01;
  _xNoise += 0.01;
  _yNoise += 0.001;
  
  float[] drawFreqArr = freq.analyze(1, play_track);
    
    
  // +++ Random Mode calculations (mode == 0) +++
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
  
  // +++ Music Analysis calculations (mode == 1) +++
  
  if (mode == 1) { 
   // Determine overall volume through frequency average
   sumAvgNormLast = sumAvgNorm;
   float avgNorm = 0;
   
   for (int i = 0; i < drawFreqArr.length; i++) {
    avgNorm += drawFreqArr[i];
   }
   avgNorm /= drawFreqArr.length;
   sumAvgNorm += avgNorm;
   avgAvgNorm = sumAvgNorm /frameCount;
   //println("Average Norm: "+avgNorm+" Overall Average Norm: "+avgAvgNorm); // Frequency Average Printout
   
   // +++ APPLY FURTHER FREQUENCY ANALYSIS LOGIC HERE +++
   
   _alph = 100; // Alpha value of drawn fractals, manually adjust to screen/projector brightness
   
   // Overall Volume (avgNorm)
   // Radius _rad is determined by overall volume, within allowed range
   
   _rad = round(map(avgNorm, 0, 1, _radMin, _radMax)); 
 
   // 0 ***** 0 Hz - 86 Hz ***** //
   // BASS
   int i = 0;
   
   // Blue _b is tied to this spectrum
   _b = round(drawFreqArr[i] * 255); 
   if (_b < 50) {_b = 50;} // Minimum blue value so fractal is always visible
   
   // 1 ***** 86 Hz - 172 Hz ***** //
   // KICK DRUM BOTTOM 80-100 Hz
   i = 1;
   
   // _recursion is tied to this spectrum
   if (drawFreqArr[i] <= 0.1) {_recursion = 1;}
   if (drawFreqArr[i] <= 0.6) {_recursion = 2;}
   else {_recursion = 3;}
   
   
   // 2 ***** 172 Hz - 344 Hz ***** //
   // SNARE THUMP 200-300hz
   i = 2;
   
   // _numSides is tied to this spectrum
   if (drawFreqArr[i] >= 0.66) {
     if (_numSides >= _numMax) {_numSides = _numMin;}
     else {_numSides += 1;}
   }
   
   
   // 3 ***** 344 Hz - 689 Hz ***** //
   i = 3;
   
   // no variable tied to this spectrum yet - invent your own!
   
   
   // 4 ***** 689 Hz - 1378 Hz ***** //
   i = 4;
   
   // Green _g is tied to this spectrum
   _g = round(drawFreqArr[i] * 255) - 50;
   if (_g < 30) {_g = 0;} // Green is only made visible if at least 30/255 (11,7%)
   
   // 5 ***** 1378 Hz - 2756 Hz ***** 
   // SNARE THWACK 1.5K - 2.5K
   i = 5;
   
   // Fractal's _strutFactor is tied to this spectrum within allowed range 
   _strutFactor = map(drawFreqArr[i], 0, 1, _strutMin, _strutMax);
   
   // 6 ***** 2756 Hz - 5512 Hz ***** //
   i = 6;
   
   // no variable tied to this spectrum yet - invent your own!

   
   // 7 ***** 5512 Hz - 11025 Hz ***** //
   // SNARE SIZZLE 7K-10k
   i = 7;
   
   // _maxlevels is tied to this spectrum
   if (drawFreqArr[i] <= 0.1) {_maxlevels = 1;}
   if (drawFreqArr[i] <= 0.5) {_maxlevels = 2;}
   else {_maxlevels = 3;}
   
   
   // 8 ***** 11025 Hz - 22050 Hz ***** // 
   i = 8;
   _r = round(drawFreqArr[i] * 255) - 25;
   if (_r < 25) {_r = 0;}
  }
  
  // +++ DRAWING INITIALISATION +++
  
  cx = width/2;
  cy = height/2;
  
  for (int i = 0; i < _numForbidden.length; i++) {
  if (_numSides == _numForbidden[i]) {_numSides -= 1; println("numSides - 1:"+_numSides); break;}
  }
  
  
  // First fractal initialisation based on values from above
  shape1 = new FractalRoot(90+frameCount, _degCount, _rad, cx, cy, _r, _g, _b, _alph, _recursion); //use frameCount to spin
  shape1.drawShape();
  
  // Changing random values for random mode
  _strutNoise += 0.02;
  _xNoise += 0.02;
  _yNoise += 0.002;

  // Second fractal, inverted 180 degrees, _rad adjusted by _numSides, lower alpha, fixed _recursion
  shape3 = new FractalRoot(270+frameCount, _degCount+180, _rad/_numSides, cx, cy, _r, _g, _b, _alph-50, 2);
  shape3.drawShape();
  
}

  // +++ FRACTAL DRAWING +++

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
      
      int recLocal = rec; // Local recursion value
      recLocal -= 1; // Decrease to prevent infinite recursion!
      
      for (float i = 0; i< _degCount; i += angleStep) {
        float x = centX + (radius * cos(radians(startAngle + i)));
        float y = centY + (radius * sin(radians(startAngle + i)));
        pointArr = (PointObj[])append(pointArr, new PointObj(x, y));
        
        if (recLocal > 0) {
          shape2 = new FractalRoot(270-frameCount, _degCount+180, _rad/_numSides, x, y, r, g, b, alph, recLocal);
          stroke(r, g, b, alph);
          shape2.drawShape();
        }
      }

      rootBranch = new Branch(0, 0, pointArr);
    }

    void drawShape() {
      
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

    void drawMe() {
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

    PointObj[] calcMidPoints() {
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

    PointObj calcMidPoint(PointObj end1, PointObj end2) {
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

    PointObj[] calcStrutPoints() {
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

    PointObj calcProjPoint(PointObj mp, PointObj op) {
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

void stop() {
  in.close();
  track.close();
  minim.stop();
}

//====================================================================

