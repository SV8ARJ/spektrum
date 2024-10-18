// Auxilliary Functions - Move them when finished development
//

// Generic functions
//
String strArj(int num) {
  return String.valueOf(num); // Convert int to string
}
String strArj(long num) {
  return String.format("%d", num); // Format long without scientific notation
}
String strArj(float num) {
  return nf(num, 0, 0); // Format float without decimal places
}
String strArj(double num) {
  return String.format("%.0f", num); // Format double with no decimal places
}

// After a Hackrf scan the frequency range achieved may be different from requesed. Adjust it according to obtained results
//
void setCorrectFrequencyRange ( ) {
    
    if (glb_startFreq != glb_startFreqCorrected || glb_stopFreq != glb_stopFreqCorrected  || glb_binStep != glb_binStepCorrected) {
        try {
          cp5.get(Textfield.class, "binStepText").setText(String.valueOf(glb_binStepCorrected));
          cp5.get(Textfield.class, "startFreqText").setText(strArj(glb_startFreqCorrected ));
          cp5.get(Textfield.class, "stopFreqText").setText(strArj(glb_stopFreqCorrected  ));
          glb_startFreq =  glb_startFreqCorrected ;
          glb_stopFreq =  glb_stopFreqCorrected;
          glb_binStepCorrected = glb_binStep;
          // setRangeFromTextFields();
          println("setCorrectFrequencyRange : Coorecting text fields to "  + glb_startFreq + " -> " + glb_stopFreq );
        }
        catch(Exception e) {
          println("setRange exception.");
        }
    
    }

    windowTitle(glb_WindowTitle + glb_ProgramVersion + // TODO Move it to a proper place. 
      (glb_renderedMode == "" ? "": " - P3D ") + 
      " --  " + strArj(glb_startFreqCorrected / 1000000) + " MHz ->" + 
      strArj(glb_stopFreqCorrected / 1000000) + " Mhz " +
      " (" + ( glb_stopFreqCorrected - glb_startFreqCorrected ) / 1000000 +" MHz) " + 
      "B:" + strArj(glb_binStepCorrected) + " Hz ");                     // TODO does not belong here. move it to UI logic
    println("Setting frequency range : Command: " + glb_cmdFrequencyRange);
    
}

// Function to display tooltip-like items
//
void showTooltip(int x, int y, String text) {
  // Split the text by new lines to count the number of lines
  String[] lines = text.split("\n");
  int lineCount = lines.length; // Number of lines
  float lineHeight = 20; // Height of each line
  float tooltipWidth = 0;
  
  // Find the maximum text width (longest line)
  for (String line: lines) {
    tooltipWidth = max(tooltipWidth, textWidth(line));
  }

  // Calculate the tooltip height based on the number of lines
  float tooltipHeight = lineHeight * lineCount;

  // Draw the background rectangle for the tooltip
  fill(0);
  rect(x + 10, y + 10, tooltipWidth + 20, tooltipHeight + 10);

  // Draw the text inside the tooltip
  fill(255);
  for (int i = 0; i < lines.length; i++) {
    text(lines[i], x + 15, y + 25 + i * lineHeight); // Adjust y position for each line
  }
}

// =================== Moved from main file
//
//
void setupControls() {
  int x,
  y;
  int width = 170;
  Textlabel tmpLabel;

  // Setup TABS
  //
  // if you want to receive a controlEvent when
  // a  tab is clicked, use activeEvent(true)
  //
  cp5.addTab("default").setColorLabel(color(255)).activateEvent(true).setId(TAB_GENERAL).setLabel(tabLabels[TAB_GENERAL]).setHeight(TAB_HEIGHT_ACTIVE);
  background(color(#222324));

  // General tab (1) =================================================
  //
  x = 15;
  y = 10;
  uiNextLineIndex = 0;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  y += 35;

  cp5.addTextlabel("receiverLabel").setText("RECEIVER RANGE:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));
  y += 35;

  cp5.addTextfield("startFreqText").setPosition(x, y).setSize(width - 50, 20).setText(strArj(glb_startFreq)).setAutoClear(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Start frequency [Hz]");

  cp5.addButton("resetMin")
  //.setValue(0)
  .setPosition(width - 30, y).setSize(40, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("|<< RST");

  // --------------------------------------------------------------------
  //
  y += 40;

  cp5.addTextfield("stopFreqText").setPosition(x, y).setSize(width - 50, 20).setText(strArj(glb_stopFreq)).setAutoClear(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("End frequency [Hz]");

  cp5.addButton("resetMax")
  //.setValue(0)
  .setPosition(width - 30, y).setSize(40, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("RST >>|");

  // --------------------------------------------------------------------
  //
  y += 40;

  cp5.addTextfield("binStepText").setPosition(x, y).setSize(60, 20).setText(strArj(glb_binStep)).setAutoClear(true).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Bin size [Hz]");

  cp5.addButton("setRangeButton").setValue(0).setPosition(95, y).setSize(width / 2, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set range");

  // y += 10;
  
  
  
  
  
  // -------------------------------------------------------------------- Preset ranges
  //
  y += 20;

  cp5.addButton("binSize00").setPosition(x, y ).setSize(9, 15).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");
  cp5.addButton("binSize01").setPosition(x + 10, y ).setSize(9, 15).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");
  cp5.addButton("binSize02").setPosition(x + 20, y ).setSize(9, 15).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");
  cp5.addButton("binSize03").setPosition(x + 30, y ).setSize(9, 15).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");
  cp5.addButton("binSize04").setPosition(x + 40, y ).setSize(9, 15).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");
  cp5.addButton("binSize05").setPosition(x + 50, y ).setSize(9, 15).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");


  y += 10;
  

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  // -------------------------------------------------------------------- IF offset
  //
  y += 35;

  cp5.addTextlabel("ifLabel").setText("UP/DOWN CONVERTER:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));

  y += 30;

  cp5.addTextfield("ifOffset").setPosition(x, y).setSize(90, 20).setText(strArj(glb_binStep)).setAutoClear(true).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("IF Frequency");

  cp5.get(Textfield.class, "ifOffset").setText(strArj(ifOffset)); // Spaggeti because mouse events and code modification events have the same result on event code...
  // toggle vertical sursor on or off
  cp5.addToggle("ifPlusToggle").setPosition(x + 100, y).setSize(20, 20).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Above");

  // toggle for how samples are shown - line / dots
  cp5.addToggle("ifMinusToggle").setPosition(x + 140, y).setSize(20, 20).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Below");

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  // --------------------------------------------------------------------
  //
  y += 35;

  cp5.addTextlabel("optionsLabel").setText("VARIOUS OPTIONS:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));

  y += 35;

  // toggle vertical sursor on or off
  cp5.addToggle("vertCursorToggle").setPosition(x, y).setSize(20, 20).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Cursors");

  // toggle for how samples are shown - line / dots
  cp5.addToggle("drawSampleToggle").setPosition(x + 70, y).setSize(20, 20).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Line/Dots");

  // toggle for how samples are shown - line / dots
  cp5.addToggle("drawFill").setPosition(x + 140, y).setSize(20, 20).getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setText("Filled Graph");

  // --------------------------------------------------------------------
  //
  y += 40;

  cp5.addToggle("offsetToggle").setPosition(x, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Offset tunning");

  cp5.addToggle("minmaxToggle").setPosition(x + 70, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Min/Max");

  cp5.addToggle("sweepToggle").setPosition(x + 140, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Sweep");

  y += 40;

  cp5.addTextfield("cropPrcntTxt").setPosition(x, y).setSize(60, 20).setText(strArj(cropPercent)).setAutoClear(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Crop percent (0-70%)");

  uiLines[uiNextLineIndex++][TAB_GENERAL] = y;

  // ---------------------------- Configurations
  //
  y += 35;

  cp5.addTextlabel("configLabel").setText("CONFIGURATION PRESETS:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));

  // Quick n dirty. Load from file and populate list.
  //
  Table tmpTable = loadTable(glb_configFileName, "header");

  y += 35;

  cp5.addTextfield("presetName").setPosition(x, y).setSize(100, 20).setText(tmpTable.getString(0, "configName")).setAutoClear(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Current preset");

  configurationDropdown = cp5.addDropdownList("configurationList").setBarHeight(20).setItemHeight(20).setPosition(x, y).setSize(100, 80).hide();
  configurationDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText(configurationName);

  cp5.addButton("selectPreset").setPosition(x + 105, y).setSize(20, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("...");

  cp5.addButton("savePreset").setPosition(x + 135, y).setSize(40, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Save to");

  // Populate presets dropdwon list
  //
  for (int i = 0; i < nrOfConfigurations; i++) {
    configurationDropdown.addItem(tmpTable.getString(i, "configName"), i);
  }

  y += 30;

  // Bottom of UI area
  //
  y = graphHeight() - 130;
  uiLines[uiNextLineIndex++][TAB_GENERAL] = y - 40;

  cp5.addButton("freezeDisplay").setPosition(x, y).setSize(width / 2 - 5, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pause");

  cp5.addButton("exitProgram").setPosition(x + width / 2 + 5, y).setSize(width / 2 - 5, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Exit");

  uiLines[uiNextLineIndex++][TAB_GENERAL] = 0;

  // TAB MEASURE =============================================================================
  //
  cp5.addTab(tabLabels[TAB_MEASURE]).setColorBackground(tabColorBachground).activateEvent(true).setId(TAB_MEASURE).setHeight(TAB_HEIGHT);

  // GAIN SCALE --------------------------------------------------------------------
  //
  y = 10;
  uiNextLineIndex = 0;

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  y += 35;
  tmpLabel = cp5.addTextlabel("verticalLabel").setText("VERTICAL SCALE & RF GAIN:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y += 35;

  cp5.addTextfield("scaleMinText").setPosition(70, y).setSize(25, 20).setText(strArj(scaleMin)).setAutoClear(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Lower");
  cp5.getController("scaleMinText").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addTextfield("scaleMaxText").setPosition(100, y).setSize(25, 20).setText(strArj(scaleMax)).setAutoClear(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Upper");
  cp5.getController("scaleMaxText").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("setScale").setPosition(130, y).setSize(60, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Set scale");
  cp5.getController("setScale").moveTo(tabLabels[TAB_MEASURE]);

  // Gain
  //
  cp5.addTextlabel("label").setText("GAIN").setPosition(x + 10, y - 12).setSize(20, 20);
  cp5.getController("label").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  cp5.addKnob("rfGain").setRange(gains[0], gains[gains.length - 1]).setValue(50).setPosition(x + 10, y).setRadius(15).setDragDirection(Knob.VERTICAL).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("");
  cp5.getController("rfGain").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("rfGain00").setPosition(x, y + 40).setSize(9, 20).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");

  cp5.addButton("rfGain01").setPosition(x + 10, y + 40).setSize(9, 20).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");
  cp5.addButton("rfGain02").setPosition(x + 20, y + 40).setSize(9, 20).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");

  cp5.addButton("rfGain03").setPosition(x + 30, y + 40).setSize(9, 20).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");

  cp5.addButton("rfGain04").setPosition(x + 40, y + 40).setSize(9, 20).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("");

  cp5.getController("rfGain00").moveTo(tabLabels[TAB_MEASURE]);
  cp5.getController("rfGain01").moveTo(tabLabels[TAB_MEASURE]);
  cp5.getController("rfGain02").moveTo(tabLabels[TAB_MEASURE]);
  cp5.getController("rfGain03").moveTo(tabLabels[TAB_MEASURE]);
  cp5.getController("rfGain04").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  y += 40;

  cp5.addButton("autoScale")
  //.setValue(0)
  .setPosition(70, y).setSize(55, 20).setColorLabel(buttonColorText).setColorBackground(buttonColor).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Auto scale");
  cp5.getController("autoScale").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("resetScale")
  //.setValue(0)
  .setPosition(130, y).setSize(60, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Reset scale");
  cp5.getController("resetScale").moveTo(tabLabels[TAB_MEASURE]);

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // REF, AVG, PERSISTENT --------------------------------------------------------------------
  //
  y += 35;
  tmpLabel = cp5.addTextlabel("avgLabel").setText("VIDEO AVERAGING :").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y += 35;

  // ---------------------------
  cp5.addToggle("avgShow").setPosition(x, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("ON/OFF");
  cp5.getController("avgShow").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addToggle("avgSamples").setPosition(x + 70, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Freeze");
  cp5.getController("avgSamples").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addTextfield("avgDepthTxt").setSize(30, 20).setPosition(x + 130, y).setText(strArj(avgDepth)).setAutoClear(true).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Depth");
  cp5.getController("avgDepthTxt").moveTo(tabLabels[TAB_MEASURE]);

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // ------- REFERENCE
  //
  y += 35;
  tmpLabel = cp5.addTextlabel("refLabel").setText("REFERENCE GRAPH:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y += 35;

  cp5.addToggle("refShow").setPosition(x, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Show");
  cp5.getController("refShow").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("refSave").setPosition(50, y).setSize(width / 2 - 5, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Save Reference");
  cp5.getController("refSave").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addKnob("refYoffset").setRange( - graphHeight(), graphHeight()).setValue(50).setPosition(150, y - 10).setRadius(15).setDragDirection(Knob.VERTICAL).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("");
  cp5.getController("refYoffset").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  y += 35;
  tmpLabel = cp5.addTextlabel("persistenceLabel").setText("MIN, MAX, MEDIAN HOLD :").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y += 35;

  cp5.addToggle("perShowMaxToggle").setPosition(x, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("MAX");
  cp5.getController("perShowMaxToggle").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addToggle("perShowMedToggle").setPosition(x + 35, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("med");
  cp5.getController("perShowMedToggle").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addToggle("perShowMinToggle").setPosition(x + 70, y).setSize(20, 20).setValue(false).getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("MIN");
  cp5.getController("perShowMinToggle").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("perReset").setPosition(x + 130, y).setSize(40, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("RESET");
  cp5.getController("perReset").moveTo(tabLabels[TAB_MEASURE]);

  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // --------------------------------------------------------------------
  //
  y += 35;
  tmpLabel = cp5.addTextlabel("zoomLabel").setText("PRESET / RETURN TO PREVIOUS:").setPosition(x - 13, y).setColorValue(0xffffff00).setFont(createFont("ARIAL", 10));
  tmpLabel.moveTo(tabLabels[TAB_MEASURE]);

  y += 25;

  cp5.addButton("presetRestore").setPosition(x, y).setSize(width / 2 - 5, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Pre-set");
  cp5.getController("presetRestore").moveTo(tabLabels[TAB_MEASURE]);

  cp5.addButton("zoomBack").setPosition(x + width / 2 + 5, y).setSize(width / 2 - 5, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Back");
  cp5.getController("zoomBack").moveTo(tabLabels[TAB_MEASURE]);

  y += 10;
  uiLines[uiNextLineIndex++][TAB_MEASURE] = y;

  // --------------------------------------------------------------------
  //
  y += 50;

  cp5.addButton("toggleRelMode")
  //.setValue(0)
  .setPosition(x, y).setSize(width, 20).setColorBackground(#700000).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Relative mode");
  cp5.getController("toggleRelMode").moveTo(tabLabels[TAB_MEASURE]);

  // --------------------------------------------------------------------
  //
  y = graphHeight() - 120;

  uiLines[uiNextLineIndex++][TAB_GENERAL] = 0;

  cp5.addButton("helpShow").setPosition(60, y + 110).setSize(80, 20).setColorBackground(buttonColor).setColorLabel(buttonColorText).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("HELP");
  cp5.getController("helpShow").moveTo("global");

  cp5.addTextarea("textArea01").setPosition(0, 0).setSize(1, 1).setText("");

  // Keep the down left position for the Delta label
  deltaLabelsYWaiting = y + 60;
  deltaLabelsXWaiting = x + 10;
  // Use it now
  deltaLabelsY = deltaLabelsYWaiting;
  deltaLabelsX = deltaLabelsXWaiting;

  // Min/Max labels position (Down left)
  minMaxTextY = height - 50;

  loadConfigPostCreation();

  // TAB MR100 ===========================================================
  //
  /* NOT FINISHED */

  /*
  cp5.addTab(tabLabels[TAB_SARK100])
    .setColorBackground( tabColorBachground )
    .setColorLabel(color(255))
    .activateEvent(true)
    .setId(TAB_SARK100)
    .setHeight(TAB_HEIGHT)
    ;



  x = 15;
  y = 10;
  uiNextLineIndex=0;
  uiLines[uiNextLineIndex++][TAB_SARK100] = y;

  y += 40;

  serialDropdown = cp5.addDropdownList("serialPort")
    .setBarHeight(20)
    .setItemHeight(20)
    .setPosition(x, y)
    .setSize(80, 80);

  serialDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Select port");
  cp5.getController("serialPort").moveTo(tabLabels[TAB_SARK100]);

  printArray(Serial.list());

  for (int i=0; i<Serial.list().length; i++) {
    serialDropdown.addItem(Serial.list()[i], i);
  }

  cp5.addButton("openSerial")
    .setPosition(width-30, y)
    .setSize(40, 20)
    .setColorBackground(buttonColor)
    .setColorLabel(buttonColorText)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("Open")
    ;
  cp5.getController("openSerial").moveTo(tabLabels[TAB_SARK100]);

  uiLines[uiNextLineIndex++][TAB_SARK100] = 0;
  */

  println("Reached end of setupControls.");
  startingupBypassSaveConfiguration = false; //Ready loading... now you are able to save..
  // arrange controller in separate tabs
  // Tab 'global' is a tab that lies on top of any
  // other tab and is always visible
}

void setupStartControls() {
  int x,
  y;
  int width = 170;

  x = 15;
  y = 40;

  deviceDropdown = cp5.addListBox("deviceDropdown").setBarHeight(20).setItemHeight(20).setPosition(x, y).setSize(width, 20 + ((glb_devices.length) * 30)); // TAG_HACKRF
  deviceDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Select device");

  y += 200;
  // Create a Textarea for multi-line text display
  infoTextbox = cp5.addTextarea("infoTextBox").setPosition(x, y).setSize(1000, 200).setText("").setFont(createFont("Arial", 12)) // Set font size if needed
  .setLineHeight(15) // Adjust the spacing between lines
  .setColor(color(255, 140, 140)) // Text color
  .setColorBackground(color(0, 100)) // Background color
  .setColorForeground(color(0, 150)); // Foreground color

  scaledBuffer = new DataPoint[0];
}

void addStartupMessage(String message) {
  String currentText = infoTextbox.getText();
  infoTextbox.setText(currentText + "\n" + message);
}

boolean checkHackRFfile(String fileNameToCheck) {
  String tmpFileName = glb_currentPath + "\\" + fileNameToCheck;
  File file = new File(tmpFileName);
  if (!file.exists()) {
    addStartupMessage("File " + fileNameToCheck + " NOT FOUND in : " + glb_currentPath);
    return false;
  }
  else return true;
}
