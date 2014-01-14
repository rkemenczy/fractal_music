class PointObj {
  float x, y;
  PointObj(float ex, float why) {
    x = ex; 
    y = why;
  }
}

class FractalRoot {
  PointObj[] pointArr = {
  };
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

void checkSides() {
  for (int i = 0; i < _numForbidden.length; i++) {
    if (_numSides == _numForbidden[i]) {
      _numSides -= 1; 
      break;
    }
  }
}

