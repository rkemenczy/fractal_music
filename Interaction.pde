/* 
 in a nutshell:
 * dragging the mouse in X changes the strutFactor
 * dragging the mouse in Y changes rad
 * m changes mode
 * l sets input to line-in
 * g clears the FreqArray
 * k clears screen with white background
 * i applies inversion filter
 * o applies dilation
 * w increase rad
 * e decrease rad 
 * r increase number of sides
 * t decrease number of sides
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
    _rad += 10;
    println("rad is: "+_rad);
    break;
  case 'e':
  case 'E': 
    _rad -= 10;
    println("rad is: "+_rad);
    break;
  case 'r':
  case 'R': 
    if (_numSides <= _numMax) { 
      _numSides += 1;
      checkSides();
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
  }
}

