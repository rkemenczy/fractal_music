/*
	RESPONSIVE MUSIC VISUALIZATION USING 2D FRACTAL STRUCTURES
 */

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;

// parameters
boolean fullScreen = false;


// variables
Minim minim;
AudioInput in;
AudioPlayer track;
int bufferSize = 512; // change if you know what you are doing

Frequency freq;
FFT fft;
int sampleRate = 44100; // change if you know what you are doing
int fft_base_freq = 86; // used in freq analysis
int fft_band_per_oct = 1; // TODO how come these values?
int numZones = 0;

float _strutNoise, _xNoise, _yNoise; // random(10);

int mode = 1; // starting mode 1 fixes faulty analysis from line in
boolean play_track = true;

int cx = width/2;
int cy = height/2;
int _degCount = 360;
int _r, _g;
int _b = 50;
int _alph = 100;
int _recursion = 0;

// ,,,,,,,,,,,,,,,,,,,,


float avgAvgNorm = 0;
float sumAvgNorm = 0;
float sumAvgNormLast = 0;

float _strutFactor = 1;

float _strutMin = -1;
float _strutMax = 2;
int _maxlevels = 3; //values 1-3 (performance)
int _minlevels = 1;
int _numSides = 3;
int _numMin = 3; // lower value breaks the code
int _numMax = 6; //reduced to 6 (performance)
int[] _numForbidden = {
  7, 11, 19, 21, 23, 25
}; // make array with prohibited _numSide numbers because they don't create a symmetric(?) fractal




float _rad = 150;
float _radMin = 100;
float _radMax = 500;

FractalRoot shape1;
FractalRoot shape2;
FractalRoot shape3;

boolean sketchFullScreen() {
  return fullScreen;
}

void setup() {
  size(displayWidth/2, displayHeight/2, OPENGL);
  smooth();
  frameRate(30);
  if (frame != null) {
    frame.setResizable(true);
  }

  _strutNoise = random(10);
  _xNoise = random(10);
  _yNoise = random(10);

  // init minim 
  minim = new Minim(this);
  track = minim.loadFile("track.mp3", bufferSize);
  track.loop();
  in = minim.getLineIn(Minim.STEREO, bufferSize);

  // init freq analyzer
  freq = new Frequency(minim, in, track, fft, sampleRate, 
  bufferSize, fft_base_freq, fft_band_per_oct, numZones );
  freq.initialize();

  // make background black;
  background(0);
}



void draw() {
  // draw slightly translucent black background
  background(0, 20);

  // increase noise


  // pick mode
  if (mode == 0) { 
    demoMode();
  }
  else if (mode == 1) { 
    musicAnalysisMode();
  }

  // react to resize
  cx = width/2;
  cy = height/2;

  shape1 = new FractalRoot(90+frameCount, _degCount, _rad, cx, cy, _r, _g, _b, _alph, _recursion); //use frameCount to spin
  shape1.drawShape();

  shape3 = new FractalRoot(270+frameCount, _degCount+180, _rad/_numSides, cx, cy, _r, _g, _b, _alph-50, 2);
  shape3.drawShape();
}

void stop() {
  in.close();
  track.close();
  minim.stop();
}

