class Frequency implements AudioListener 
{
  private float[] left;
  private float[] right;

  Minim minim;
  AudioInput in;
  AudioPlayer track;

  FFT fft;

  int sampleRate = 44100;
  int bufferSize = 512;

  int fft_base_freq = 86; 
  int fft_band_per_oct = 1;
  int numZones = 0;

  float[] freqArr;
  float[] freqArrLast;
  float[] maxArr;

  Frequency( Minim minim, AudioInput in, AudioPlayer track, FFT fft, 
  int sampleRate, int bufferSize, int fft_base_freq, int fft_band_per_oct, int numZones ) {

    left = new float[bufferSize];
    right = new float[bufferSize];
    for (int i=0, end=bufferSize; i < end; i++) {
      left[i]= 0.0; 
      right[i] = 0.0;
    }

    /* Import global variables during construction or use local defaults */
    if ( minim != null ) 
      this.minim = minim;
    if ( in != null ) 
      this.in = in;
    if ( track != null ) 
      this.track = track;
    if ( fft != null ) 
      this.fft = fft;
    if ( sampleRate > -1 ) 
      this.sampleRate = sampleRate;
    if ( bufferSize > -1 ) 
      this.bufferSize = bufferSize;
    if ( fft_base_freq > -1 ) 
      this.fft_base_freq = fft_base_freq;
    if ( fft_band_per_oct > -1 ) 
      this.fft_band_per_oct = fft_band_per_oct;
    if ( numZones > -1 ) 
      this.numZones = numZones;
  }

  synchronized void samples(float[] samp) {
    left = samp;
  }

  synchronized void samples(float[] sampL, float[] sampR) {
    left = sampL;
    right = sampR;
  }

  void initialize() {
    fft = new FFT(bufferSize, sampleRate);    
    fft.logAverages(fft_base_freq, fft_band_per_oct);

    fft.window(FFT.HAMMING);

    numZones = fft.avgSize(); 

    freqArr = new float[numZones];
    freqArrLast = new float[numZones];
    maxArr = new float[numZones]; // WAS "float[]" THE ISSUE??! TODO WHAT???

    for (int i = 0; i < numZones; i++) {
      freqArr[i] = 0;
      freqArrLast[i] = 0;
      maxArr[i] = 0;
    }
  }

  void store(float[] fArr) {
    freqArrLast = new float[fArr.length];
    arrayCopy(fArr, freqArrLast);
    //for (int i = 0; i < fArr.length; i++) { // TODO what was that used for?
    //freqArrLast[i] = fArr[i];
    //}
  }

  float[] analyze( int n, boolean play_track ) {
    float[] freqArr = new float[numZones];

    if (play_track == true) { // TODO what about mode here? 
      fft.forward(track.mix); 
      /* Change to "fft.forward(in.mix)" for live input [works at least with integrated microphones],
       * but doesn't work for mono/stereo line-in TODO what?
       */
    } 
    else {
      /* AudioInput requires an AudioListener (this) to retrieve its mix buffer */
      fft.forward(left);
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
        //println("f: ("+i+") "+avg); // TODO what?
      }
      if (n == 1) {  
        if (avg > maxArr[i]) {
          maxArr[i] = avg;
        }
        float norm = map(avg, 0, maxArr[i], 0, 1);
        freqArr[i] = norm;

        /* TODO was this a safeguard?
         if (avg != freqArrLast[i]) {
         freqArrLast[i] = avg;
         }
         */
      }
    }

    return freqArr;
  }
}

