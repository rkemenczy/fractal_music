/*
	RESPONSIVE MUSIC VISUALIZATION USING 2D FRACTAL STRUCTURES
 */

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;

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
int[] _numForbidden = {
  7, 11, 19, 21, 23, 25
}; // make array with prohibited _numSide numbers because they don't create a symmetric(?) fractal
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
int play_mode = -1;


FractalRoot shape1;
FractalRoot shape2;
FractalRoot shape3;

// Remove to disable automatic fullscreen
boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(1280, 1024, OPENGL);
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


  freq = new Frequency(minim, in, track, fft, sampleRate, 
  bufferSize, fft_base_freq, fft_band_per_oct, numZones );
  freq.initialize();

  /* Starting with track playing in analysis mode because this seems to fix an initial faulty analysis of line-in data */
  mode = 1;
  play_mode = 0;
  //in.removeListener(freq);
    track.loop();
    play_track = true;
    fill(0);
    rect(0,0,width,height);
}



void draw() {
  //background(255);
  fill(0, 20);
  //rect(0, 0, width, height);

  _strutNoise += 0.01;
  _xNoise += 0.01;
  _yNoise += 0.001;

  float[] drawFreqArr = freq.analyze(1, play_track);


  // MUTED MODE

  if (mode == 0) { 
    mutedMode();
  }

  // MUSIC ANALYSIS MODE

  if (mode == 1) { 
    musicAnalysisMode(drawFreqArr);
  }

  // GENERAL DRAWINGS AND VALUES

  cx = width/2;
  cy = height/2;

  for (int i = 0; i < _numForbidden.length; i++) {
    if (_numSides == _numForbidden[i]) {
      _numSides -= 1; 
      println("numSides - 1:"+_numSides); 
      break;
    }
  }


  shape1 = new FractalRoot(90+frameCount, _degCount, _rad, cx, cy, _r, _g, _b, _alph, _recursion); //use frameCount to spin
  shape1.drawShape();

  _strutNoise += 0.02;
  _xNoise += 0.02;
  _yNoise += 0.002;

  shape3 = new FractalRoot(270+frameCount, _degCount+180, _rad/_numSides, cx, cy, _r, _g, _b, _alph-50, 2);
  shape3.drawShape();
}

void stop() {
  in.close();
  track.close();
  minim.stop();
}

//====================================================================

