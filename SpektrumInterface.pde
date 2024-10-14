// TAG_ARJ - Implement an interface so we can choose the spektrum data feeder at runtime
//
interface SpektrumInterface {
  public enum RelativeModeType {
    NONE,
    RECORD,
    RELATIVE
  }

  String[] getDevices();
  void setRelativeMode(Rtlspektrum.RelativeModeType mode);
  int openDevice();
  void setFrequencyRange(long startFreq, long stopFreq, int binStep, double tmpCrop);
  void clearFrequencyRange();
  void startAutoScan();
  void stopAutoScan();
  double[] getDbmBuffer();
  int getScanPos();
  void setGain(int gainValue);
  int[] getGains();
  void setOffsetTunning(boolean enable);
  long[] getFrequencyRangeSupported();

}
