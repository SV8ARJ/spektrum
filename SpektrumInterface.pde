interface SpektrumInterface {
    
	String[] getDevices();
    void setRelativeMode(Rtlspektrum.RelativeModeType mode);
	int openDevice();
	void setFrequencyRange(int startFreq, int stopFreq, int binStep, double tmpCrop);
	void clearFrequencyRange();
	void startAutoScan();
	void stopAutoScan();
	double[] getDbmBuffer();
	int getScanPos();
	void setGain(int gainValue);
	int[] getGains();
	void setOffsetTunning(boolean enable);
	
	public enum RelativeModeType {
        NONE,
        RECORD,
        RELATIVE
    }
	
}
