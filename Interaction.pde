
void mouseDragged() {
  _strutFactor = map(mouseX, 0, width, _strutMin, _strutMax);
}

void keyPressed() {
  if (key == 'm' || key == 'M') {
    if (mode < 2) { 
      mode += 1;
    }
    else {
      mode = 0;
    }
    println("mode is: "+mode);
  }
  if (key == 'p' || key == 'P') {
    if ( play_mode != 0 ) {
      play_mode = 0;
      //in.removeListener(freq);
      track.loop();
      play_track = true;
    } 
    else {
      play_mode = -1;
      track.pause();
      play_track = false;
    }
    print("play_mode is: "+play_mode);
  }
  if (key == 'l' || key == 'L') {
    track.pause();
    in.addListener(freq);
    play_track = false;
    println("Line-in");
  }

  if (key == 'g' || key == 'G') { 
    for (int i = 0; i < numZones; i++) {
      freq.maxArr[i] = 0;
    }
    println("cleared freq array");
  }

  if (key == 'k' || key == 'K') {
    fill(255, 255);
    rect(0, 0, width, height);
  }
  if (key == 'i' || key == 'I') {
    filter(INVERT);
  }
  if (key == 'o' || key == 'O') { 
    filter(DILATE);
  }

  if (key == 'w' || key == 'W') { 
    _rad += 10;
  }
  if (key == 'e' || key == 'E') { 
    _rad -= 10;
  }
  if (key == 'r' || key == 'R') { 
    if (_numSides <= _numMax) { 
      _numSides += 1; 
      println("Sides: "+_numSides);
    }
  }
  if (key == 't' || key == 'T') { 
    if (_numSides > _numMin) { 
      _numSides -= 1; 
      println("Sides: "+_numSides);
    }
  }
}

