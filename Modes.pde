void printCurrentMode() {
  if (mode == 0) {
    println("Mode is 0 (demo mode)");
  }
  else if (mode == 1) {
    println("Mode is 1 (music analysis mode)");
  }
  else if (mode == 2) {
    println("Mode is 2 (mouse mode)");
  }
}

void demoMode() {
  // TODO somthing in demo mode is missing, it behaves different than live
  _strutNoise += 0.03;
  _xNoise += 0.03;
  _yNoise += 0.003;
  
  _strutFactor = (noise(_strutNoise) * _strutMax) + _strutMin; // play with this
  _rad = (noise(_xNoise) * _radMax) + _radMin; //map(mouseX, 0, width, _radMin, _radMax)

  _numSides = _numMin + round(noise(_yNoise) * (_numMax - _numMin));
  checkSides();

  for (int i = 0; i < _numForbidden.length; i++) {
    if (_numSides == _numForbidden[i]) {
      _numSides -= 1; 
      break;
    }
  }
  _r = round(255*(noise(_yNoise)));
  _g = round(255*(noise(_xNoise)));
  _b = round(255*(noise(_strutNoise)));
  _alph = 100;

  _rad = 150; // TODO overwrites 16 lines earlier?
  _radMin = 150;
  _radMax = 500;
  _recursion = 3;
}

void musicAnalysisMode() {
    float[] drawFreqArr = freq.analyze(1, play_track); // TODO what does the 1 do? why here?
  // FREQUENCY AVERAGE PRINTOUT
  sumAvgNormLast = sumAvgNorm;
  float avgNorm = 0;

  for (int i = 0; i < drawFreqArr.length; i++) {
    avgNorm += drawFreqArr[i];
  }
  avgNorm /= drawFreqArr.length;
  sumAvgNorm += avgNorm;
  avgAvgNorm = sumAvgNorm /frameCount;

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
  _b = round(drawFreqArr[i] * 255);
  if (_b < 50) {
    _b = 50;
  }

  // 1 ***** 86 Hz - 172 Hz ***** //
  // KICK DRUM BOTTOM 80-100 Hz
  i = 1;

  //_recursion = round(map(freqArr[i], 0, 1, 1, 3));
  if (drawFreqArr[i] <= 0.1) {
    _recursion = 1;
  }
  if (drawFreqArr[i] <= 0.6) {
    _recursion = 2;
  }
  else {
    _recursion = 3;
  }


  // 2 ***** 172 Hz - 344 Hz ***** //
  // SNARE THUMP 200-300hz
  i = 2;

  if (drawFreqArr[i] >= 0.66) {
    if (_numSides >= _numMax) {
      _numSides = _numMin;
    }
    else {
      _numSides += 1;
    }
    checkSides();
  }

  // 3 ***** 344 Hz - 689 Hz ***** //

  // 4 ***** 689 Hz - 1378 Hz ***** //
  i = 4;
  _g = round(drawFreqArr[i] * 255) - 50;
  if (_g < 30) {
    _g = 0;
  }

  // 5 ***** 1378 Hz - 2756 Hz ***** // XXX snare? 
  // SNARE THWACK 1.5K - 2.5K, ++++
  i = 5;
  _strutFactor = map(drawFreqArr[i], 0, 1, _strutMin, _strutMax);

  // 6 ***** 2756 Hz - 5512 Hz ***** //

  // 7 ***** 5512 Hz - 11025 Hz ***** //
  // SNARE SIZZLE 7K-10k
  i = 7;

  if (drawFreqArr[i] <= 0.1) {
    _maxlevels = 1;
  }
  if (drawFreqArr[i] <= 0.5) {
    _maxlevels = 2;
  }
  else {
    _maxlevels = 3;
  }
  //_maxlevels = round(map(freqArr[i], 0, 1, _minlevels, 3));

  // 8 ***** 11025 Hz - 22050 Hz ***** // XXX highest pitch +++++
  i = 8;
  _r = round(drawFreqArr[i] * 255) - 25;
  if (_r < 25) {
    _r = 0;
  }
}

