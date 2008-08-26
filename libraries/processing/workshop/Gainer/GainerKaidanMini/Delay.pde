/**
 * Delay
 * A very simple delay
 * とてもシンプルなディレイ
 */ 

class Delay {
  private int inputIndex;
  private int outputIndex;
  private float[] buffer;
  private int bufferLength;
  
  Delay(int delayTime) {
    inputIndex = delayTime;
    outputIndex = 0;
    buffer = new float[delayTime + 1];
    bufferLength = delayTime + 1;
  }

  void setInput(float value) {
    buffer[inputIndex] = value;
  }

  float getOutput() {
    float out = buffer[outputIndex];
    inputIndex = (inputIndex + 1) % bufferLength;
    outputIndex = (outputIndex + 1) % bufferLength;
    return out;
  }
}

