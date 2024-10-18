class RtlspektrumWrapper implements SpektrumInterface {
  // Internal reference to the original Rtlspektrum object
  private Rtlspektrum rtlSpektrum;

  // Constructor
  RtlspektrumWrapper(int deviceId) {
    rtlSpektrum = new Rtlspektrum(deviceId);
  }

  // Forwarding methods
  @Override
  int openDevice() {
    return rtlSpektrum.openDevice();
  }

  @Override
  void setGain(int gainValue) {
    rtlSpektrum.setGain(gainValue); // Forward the call to Rtlspektrum
  }

  @Override
  void setFrequencyRange(long startFreq, long stopFreq, int binStep, double tmpCrop) {
    rtlSpektrum.setFrequencyRange((int) startFreq, (int) stopFreq, binStep, tmpCrop); // Forward call
    glb_startFreqCorrected = startFreq ;     // Only applies to hackRF so for RTL is just dump
    glb_stopFreqCorrected = stopFreq ;
    glb_binStepCorrected = binStep ;
  }

  @Override
  void startAutoScan() {
    rtlSpektrum.startAutoScan(); // Forward call
  }

  @Override
  void stopAutoScan() {
    rtlSpektrum.stopAutoScan(); // Forward call
  }

  @Override
  int[] getGains() {
    return rtlSpektrum.getGains(); // Forward call
  }

  @Override
  double[] getDbmBuffer() {
    return rtlSpektrum.getDbmBuffer(); // Forward call
  }

  @Override
  int getScanPos() {
    return rtlSpektrum.getScanPos(); // Forward call
  }

  // Additional methods that exist in Rtlspektrum but were missed
  // Forward the setOffsetTunning call
  void setOffsetTunning(boolean enable) {
    rtlSpektrum.setOffsetTunning(enable); // Forward call
  }

  // Forward the setRelativeMode call
  void setRelativeMode(Rtlspektrum.RelativeModeType mode) {
    rtlSpektrum.setRelativeMode(mode); // Forward call
  }

  // Forward the clearFrequencyRange call
  void clearFrequencyRange() {
    rtlSpektrum.clearFrequencyRange(); // Forward call
  }

  String[] getDevices() {
    return rtlSpektrum.getDevices();
  }

  long[] getFrequencyRangeSupported() {
    return new long[] {
      24000000L,
      1700000000L
    }; // Use long literals
  }

}
