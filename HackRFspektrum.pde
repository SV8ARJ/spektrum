class HackRFspektrum implements SpektrumInterface {

    int deviceId;
    double[] dbmBuffer;
    int scanPos;
	
	String local_commandLine = "";
	int local_SweepRunningState = 0;	// 0 = stopped, 1 = running, 2 : data available

	private Thread autoScanThread = null;
	private ArrayList<String> outputLines2 = new ArrayList<String>(); // ArrayList to hold copied data


    HackRFspektrum(int deviceId) {
        this.deviceId = deviceId;
        this.dbmBuffer = new double[0];  // Initialize empty buffer
        this.scanPos = 0;
    }

	// Initialization ==========================================
	//
	//
	
	public String[] getDevices() {
		try {
			
			// Check if utilities exist
			//
			String tmpFileName = glb_currentPath + "\\hackrf_info.exe";  
			File file = new File(tmpFileName);		
			if (!file.exists()) {
				// MsgBox("File " + tmpFileName + " is not found in " + glb_currentPath, "Spektrum");
                // addStartupMessage("File " + tmpFileName + " is not found in " + glb_currentPath);
				
				return new String[0];
			}

			// Create the process to run hackrf_info.exe
			//
			ProcessBuilder builder = new ProcessBuilder( glb_currentPath + "\\hackrf_info.exe" );
			builder.redirectErrorStream(true);  // Redirect errors to standard output
			Process process = builder.start();
			
			// Capture the output
			//
			BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
			String line;
			ArrayList<String> devices = new ArrayList<>();
			
			// Read each line of the output and search for serial numbers
			//  println("================ HACK RF DEVICES =============");
			while ((line = reader.readLine()) != null) {
				if (line.contains("Serial number:")) {
					// Extract the serial number from the line
					String serialNumber = line.split(":")[1].trim();
					devices.add(serialNumber.substring(Math.max(0, serialNumber.length() - 5)));
				}
			}
			
			process.waitFor();		// Wait for the process to complete
			
			return devices.toArray(new String[0]);	// Convert ArrayList to a String array and return
			
		} catch (Exception e) {
			e.printStackTrace();
			return new String[0];  	// Return an empty array if an error occurs
		}
	}
	
	int openDevice(){
        println("Open Device called.");
		
		String tmpFileName = glb_currentPath + "\\hackrf_sweep.exe";
		File tmpFile = new File(tmpFileName);   
		if (!tmpFile.exists()) {
            addStartupMessage( "File " + tmpFileName + " is not found in " + glb_currentPath );
			MsgBox("File " + tmpFileName + " is not found in " + glb_currentPath, "Spektrum");
			return -1;
		}
		else
			return 1;
    }



	// Setup ==========================================
	//
	//
  long[] getFrequencyRangeSupported() {
      return new long[] {1000000L, 7000000000L};  // Use long literals
  }
    
  @Override
  void setFrequencyRange(long startFreq, long stopFreq, int binStep, double tmpCrop) {
		int tmpBinStep = binStep;
		
		if (stopFreq - startFreq < 20000000) {	// HackRF_sweep only goes down to 20MHz // TODO Keep the table internally only report back the range requested
			stopFreq = startFreq + 20000000;
		}
		// TEST AUTO binSize TODO Give as an option in UI
		//
		// tmpBinStep = (stopFreq - startFreq) / width;
		
		// -w bin_width] # FFT bin width (frequency resolution) in Hz, 2445-5000000
		//
		tmpBinStep = Math.min( tmpBinStep, 5000000 );
		tmpBinStep = Math.max( tmpBinStep, 2445);
		
		try {
			cp5.get(Textfield.class, "binStepText").setText( String.valueOf(tmpBinStep)  );
			cp5.get(Textfield.class, "startFreqText").setText( strArj((startFreq/1000000)*1000000) );
			cp5.get(Textfield.class, "stopFreqText").setText( strArj((stopFreq/1000000)*1000000) );
			glb_startFreq = (startFreq/1000000)*1000000;
			glb_stopFreq = (stopFreq/1000000)*1000000;
		}
		catch(Exception e) {
			println("setRange exception.");
		}
		
		glb_cmdFrequencyRange = "-f " + startFreq/1000000 + ":" + stopFreq/1000000 ;
    glb_cmdBinSize = " -w " + tmpBinStep;
		
    windowTitle( glb_WindowTitle + glb_ProgramVersion + " -  (" + strArj(startFreq/1000000) + " MHz ->" + strArj(stopFreq/1000000) + " Mhz, B:" + strArj(tmpBinStep) + " Hz )");  // TODO does not belong here. move it to UI logic
    println("Setting frequency range : Command: " +  glb_cmdFrequencyRange);
  }
	
	@Override
    int[] getGains() {
        return new int[]{1, 2, 3, 4, 5};  // [-l gain_db] # RX LNA (IF) gain, 0-40dB, 8dB steps
		
    }
	
	@Override
    void setGain(int gainValue) {
		int[] tmpLnaGainLookup = new int[]{ 8, 16, 24, 32,40 };
		glb_cmdLnaGain = "-l " + String.valueOf(tmpLnaGainLookup[ gainValue -1  ]);
        println("Setting gain CMD to : " + glb_cmdLnaGain );
    }


	// Use ==========================================
	//
	//

    @Override
    void startAutoScan() {
        // Empty implementation for HackRFspektrum
        println("Starting auto scan in HackRFspektrum.");
    }

    @Override
    void stopAutoScan() {
        // Empty implementation for HackRFspektrum
        println("Stopping auto scan in HackRFspektrum.");
    }




    @Override
    int getScanPos() {
        // Returning dummy scan position for HackRFspektrum
        return this.scanPos;
    }

    // Additional methods matching those in RtlspektrumWrapper

    void setOffsetTunning(boolean enable) {
        // Empty implementation for HackRFspektrum
        println("Setting offset tuning to " + enable + " in HackRFspektrum.");
    }

	public void setRelativeMode(Rtlspektrum.RelativeModeType mode) {
		// println("Setting relative mode to " + mode + " in HackRFspektrum.");
		if (local_SweepRunningState == 0 ) {	
			local_SweepRunningState = 1;
			
			// Create a new thread to run the sweep in the background
			autoScanThread = new Thread(new Runnable() {
				@Override
				public void run() {
					// Call the method to run HackRF sweep in the background
					runHackRFSweepInBackground();
				}
			});
			
			// Start the thread
			autoScanThread.start();
			
			// println("setRelativeMode: RUNNING THE SWEEP");
		}
	}

	// Seperate thread function 
	//
	public void runHackRFSweepInBackground() {
		// Initialize an ArrayList to store the output lines
		  ArrayList<String> outputLines = new ArrayList<String>();
		  
		  try {
			// Define the command to run hackrf_sweep.exe 
			String tmpCommand =  glb_currentPath + "\\hackrf_sweep.exe " + 
				glb_cmdFrequencyRange + " " +
				glb_cmdBinSize + " " +
				glb_cmdLnaGain + " " +
				glb_cmdVgaGain + " " +
				glb_cmdPreAmp + " " +
				"-1 -n -P measure";
			// println("runHackRFSweepInBackground: " + tmpCommand);
			
			// Use ProcessBuilder to run the command
			ProcessBuilder pb = new ProcessBuilder(tmpCommand.split(" "));
			pb.redirectErrorStream(true);  // Redirect stderr to stdout so we can capture both
			
			// Start the process
			Process process = pb.start();
			
			// Read the output from the process
			BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
			String line;
			
			// Capture each line of output and add it to the ArrayList
			while ((line = reader.readLine()) != null) {
			  outputLines.add(line);
			  // println(line);
			}
			
			// Wait for the process to complete
			process.waitFor();
			
			// Move to buffer 
			//
			outputLines2.clear();
			outputLines2.addAll(outputLines);
			
		  } catch (Exception e) {
			e.printStackTrace();
		  }
		
		  local_SweepRunningState = 2;	// Finished. TODO enumerator
		
        
    }
	
	
	@Override
	double[] getDbmBuffer() {

		if (local_SweepRunningState == 2) {
			// println("getDbmBuffer Called with sweep finished");
			local_SweepRunningState = 0; // Free thread execution for next scan and hurry up to parse the data from outputLines2

			// Prepare a list to store all the parsed dBm values
			ArrayList<Double> allDbmValues = new ArrayList<Double>();

			// Loop through each line in outputLines2 and parse it
			for (String line : outputLines2) {
				// Split the line into parts using a comma as the delimiter
				String[] fields = line.split(",");

				// Ensure we have at least the expected number of fields
				if (fields.length >= 7) {
					// Parse the first six fields into the corresponding variables
					///////// String line_timestamp1 = fields[0].trim();  // First part of the timestamp (date)
					///////// String line_timestamp2 = fields[1].trim();  // Second part of the timestamp (time)
					///////// double line_startFreq = Double.parseDouble(fields[2].trim()); // Start frequency
					///////// double line_endFreq = Double.parseDouble(fields[3].trim());   // End frequency
					///////// double line_binWidth = Double.parseDouble(fields[4].trim());  // Bin width (frequency resolution)
					///////// int line_samples = Integer.parseInt(fields[5].trim());        // Number of samples

					// Now parse the rest of the fields (dBm values) into the line_dbm array
					double[] line_dbm = new double[fields.length - 6];
					for (int i = 6; i < fields.length; i++) {
						line_dbm[i - 6] = Double.parseDouble(fields[i].trim());
						allDbmValues.add(line_dbm[i - 6]);  // Add each dBm value to the overall list
					}

					// // Print out the parsed values
					// println("Timestamp: " + line_timestamp1 + " " + line_timestamp2);
					// println("Start Frequency: " + line_startFreq);
					// println("End Frequency: " + line_endFreq);
					// println("Samples: " + line_samples);
					// 
					// // Convert the double[] to float[] for using nf()
					// float[] line_dbm_float = new float[line_dbm.length];
					// for (int i = 0; i < line_dbm.length; i++) {
					// 	line_dbm_float[i] = (float) line_dbm[i];
					// }
					// 
					// // Use nf to format float values and join the result
					// println("dBm values: " + join(nf(line_dbm_float, 0, 2), ", "));

				}
			}	// all lines loop

			// Convert the ArrayList to a double[] array for returning
			dbmBuffer = new double[allDbmValues.size()];
			for (int i = 0; i < allDbmValues.size(); i++) {
				dbmBuffer[i] = allDbmValues.get(i);
			}
		}

		return this.dbmBuffer;  // Return the internal buffer
	}

    void clearFrequencyRange() {
        // Empty implementation for HackRFspektrum
        println("Clearing frequency range in HackRFspektrum.");
    }
	
	

}
