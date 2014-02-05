/* 
 in a nutshell:
 * dragging the mouse in X changes the strutFactor for mode 2
 * dragging the mouse in Y changes rad for mode 2
 * m changes mode
 * l sets input to line-in
 * g clears the FreqArray
 * k clears screen with white background BAD!
 * i applies inversion filter SLOW!
 * o applies dilation SLOW!
 * w increase rad
 * e decrease rad 
 * r increase number of sides
 * t decrease number of sides
 * z increases max sides
 * u decreases max sides
 */

void mouseDragged() {
  if (mode == 2) {
    _strutFactor = map(mouseX, 0, width, _strutMin, _strutMax);
    _rad = map(mouseY, 0, height, _radMin, _radMax);
  }
}

void keyPressed() {
  switch(key) {
  case 'm':
  case 'M':
    if (mode < 2) { 
      mode += 1;
    }
    else {
      mode = 0;
    }
    printCurrentMode();
    break;
  case 'l':
  case 'L':
    track.pause();
    in.addListener(freq);
    play_track = false;
    println("Line-in");
    break;
  case 'g':
  case 'G': 
    for (int i = 0; i < numZones; i++) {
      freq.maxArr[i] = 0;
      freq.freqArr[i] = 0;
      freq.freqArrLast[i] = 0;
    }
    println("cleared freq array");
    break;
  case 'k':
  case 'K':
    fill(255);
    rect(0, 0, width, height);
    break;
  case 'i':
  case 'I':
    filter(INVERT);
    break;
  case 'o':
  case 'O': 
    filter(DILATE);
    break;
  case 'w':
  case 'W':
    _radMin += 10;
    _radMax += 10;
    println("rad is between "+_radMin+" and "+_radMax);
    break;
  case 'e':
  case 'E': 
    _radMin -= 10;
    _radMax -= 10;
    println("rad is between "+_radMin+" and "+_radMax);
    break;
  case 'r':
  case 'R': 
    if (_numSides <= _numMax) { 
      _numSides += 1;
      //checkSides();
    }
    println("Sides: "+_numSides);
    break;
  case 't':
  case 'T': 
    if (_numSides > _numMin) { 
      _numSides -= 1;
      checkSides();
    }
    println("Sides: "+_numSides);
    break;

  case 'y':
  case 'Y':  
    _numMax += 1;
    println("max Sides: "+_numMax);
    break;
  case 'u':
  case 'U': 
    if (_numMax > 4) { 
      _numMax -= 1;
    }
    println("max Sides: "+_numMax);
    break;
  }
}

