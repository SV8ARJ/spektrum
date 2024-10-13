import org.bridj.*;
import org.bridj.ann.*;
import org.bridj.cpp.*;
import org.bridj.cpp.com.*;
import org.bridj.cpp.com.shell.*;
import org.bridj.cpp.mfc.*;
import org.bridj.cpp.std.*;
import org.bridj.demangling.*;
import org.bridj.dyncall.*;
import org.bridj.func.*;
import org.bridj.jawt.*;
import org.bridj.util.*;
import org.bridj.relocated.org.objectweb.asm.*;
import org.bridj.relocated.org.objectweb.asm.signature.*;

import controlP5.*;
import rtlspektrum.Rtlspektrum;
import java.io.FileWriter;
import java.util.*;
import processing.serial.*;
import java.io.*;

String glb_WindowTitle = "Spektrum ";
String glb_ProgramVersion = "v0.20b - SV8ARJ";

SpektrumInterface spektrumReader;	// TODO ... I will regret this, why not just use ifs on every call ? It's only 30 or so...

ControlP5 cp5;
DataPoint[] scaledBuffer;

boolean startingupBypassSaveConfiguration = true;

int reloadConfigurationAfterStartUp = 0;// This will be set at the end of the startup
int CONFIG_RELOAD_DELAY = 30;  // 0 is disabled

interface  CURSORS {
  int
    CUR_NONE      = 0,
    CUR_X_LEFT    = 1,
    CUR_X_RIGHT   = 2,
    CUR_Y_TOP     = 3,
    CUR_Y_BOTTOM  = 4;
}

int movingCursor = CURSORS.CUR_NONE;

String tmpMessage;
String tmpMessage1;
int genericFrameCounter = 0;  // Used for various tests. Gets incremented with every frame TAG_ARJ

// HackRF stuff TAG_ARJ
//
String glb_currentPath;
String glb_sweepCommandLine;
String glb_cmdFrequencyRange;
String glb_cmdBinSize = " -W 25000";
String glb_cmdLnaGain;              // [-l gain_db] # RX LNA (IF) gain, 0-40dB, 8dB steps
String glb_cmdVgaGain = " -g 10";    // [-g gain_db] # RX VGA (baseband) gain, 0-62dB, 2dB steps
String glb_cmdPreAmp = " -a 0";      // [-a amp_enable] # RX RF amplifier 1=Enable, 0=Disable


final int NONE = 0;
// TABS
//
int tabActiveID = 1;
String tabActiveName = "default";
final int TAB_HEIGHT = 25;
final int TAB_HEIGHT_ACTIVE = 30;

final int TAB_GENERAL = 1;
final int TAB_MEASURE = 2;
final int TAB_SETTINGS = 3;
final int TAB_SARK100 = 4;

String tabLabels[] = {"global", "SETUP", "MEASURE", "SETTINGS", "NOT YET", "WHO ARE YOU"};

final int ITEM_GAIN = 1;
final int ITEM_FREQUENCY = 2;
final int ITEM_ZOOM = 3;
final int ITEM_RF_GAIN = 4;

// interface  IF_TYPES {
//  int
final int  IF_TYPE_NONE      = 0;
final int  IF_TYPE_ABOVE     = 1;
final int  IF_TYPE_BELOW     = 2;

final int TOOLTIP_TIME        = 300;    // 5 seconds at 60 fps
// }

// Configuration
//
final int nrOfConfigurations = 10;			// First element is used for the Autosave functionality.

final int PRESET_SAVE = 1;
final int PRESET_LOAD = 2;
int configurationOperation = 0 ;

int CONFIG_SAVE_DELAY = 80;  // 0 is disabled
configurationClass[] configSet = new  configurationClass[10];
int configurationActive=0;
String configurationName;
DropdownList configurationDropdown;
int configurationSaveDelay = 0;

// Maybe not needed -- TBD
//
public class configurationClass {
  public int startFreq;
  public int stopFreq;
  public int binStep;
  public int scaleMin;
  public int scaleMax;
  public int rfGain;
  public int fullRangeMin;
  public int fullRangeMax;
  public int ifOffset;
  public int ifType;
  public int activeConfig;
  public String configName;

  public configurationClass(int i)
  {
    configName = "Config" + i;
  }
}


int timeToSet = 0;  // GRGNICK add
int itemToSet = 0;  // GRGNICK add -- 1 is Gain, 2 is Frequency
int infoText1X = 0;
int infoText1Y = 0;
int infoColor = #00FF3F;
int infoLineX = 0;
int infoLineY = 0;
int infoRectangle[] = {0, 0, 0, 0};
String infoText = "";

int lastWidth =0;
int lastHeight =0;

long glb_zoomBackFreqMin = 0;
long glb_zoomBackFreqMax = 0;
int zoomBackScalMin = 0;
int zoomBackScalMax = 0;

long glb_fullRangeMin = 24000000;
long glb_fullRangeMax = 1800000000;
int glb_fullScaleMin = -110;
int glb_fullScaleMax = 40;

long glb_startFreq = 88000000;
long glb_stopFreq = 108000000;
int glb_binStep = 1000;
int binStepProtection = 200;
long vertCursorFreq = 88000000;
int tmpFreq = 0;
int rfGain = 0;
int ifOffset = 0;
int ifType = 0;
int cropPercent = 0;	// RTL data chunks percentage to keep. Values 0 to 70 percent


int scaleMin = -110;
int scaleMax = 40;

int uiNextLineIndex = 0;
int[][] uiLines = new int[10][10];

final int GRAPH_DRAG_NONE = 0;
final int GRAPH_DRAG_STARTED = 1;
final int GRAPH_DRAG_ENDED = 0;
int mouseDragGraph = GRAPH_DRAG_NONE;

int dragGraphStartX;
int dragGraphStartY;

int cursorVerticalLeftX = -1;
int cursorVerticalRightX = -1;
int cursorHorizontalTopY = -1;
int cursorHorizontalBottomY = -1;

int cursorVerticalLeftX_Color = #3399ff;  // Cyan
int cursorHorizontalBottomY_Color = #3399ff;

int cursorVerticalRightX_Color = #ff80d5; // Magenta
int cursorHorizontalTopY_Color = #ff80d5;

int cursorDeltaColor = #00E010;
int glb_tooltipCounter = 0;
int glb_lastCursor=0;

ListBox deviceDropdown;
DropdownList gainDropdown;
DropdownList serialDropdown;


String[] glb_devices;

int[] gains;

int relMode = 0;

double minFrequency;
double minValue;
double minScaledValue;

double maxFrequency;
double maxValue;
double maxScaledValue;

boolean minmaxDisplay = false;
boolean sweepDisplay = false;

int showInfoScreen = 0;
class DataPoint {
  public int x;
  public double yMin = 0;
  public double yMax = 0;
  public double yAvg = 0;
}

class infoScreen {
  public int topY = 0;
  public int leftX = 0;
  public int width = 0;
  public int height = 0;
  public String text = "";
  color colorBack;
}

infoScreen infoHelp;


//========= added by Dave N
Table table;
String glb_configFileName = "config.csv";  // config file used to save and load program setting like frequency etc.
boolean setupDone = false;
boolean frozen = true;
boolean vertCursor = false;
float minMaxTextX = 10;
float minMaxTextY = 660;

int deltaLabelsX;
int deltaLabelsY;
int deltaLabelsXWaiting;
int deltaLabelsYWaiting;

boolean overGraph = false;
boolean mouseDragLock = false;
int startDraggingThr = 5;
int lastMouseX;
color buttonColor = color(70, 70, 70);
color buttonColorText = color(255, 255, 230);
color setButtonColor = color(127, 0, 0);
color clickMeButtonColor = color(20, 200, 20);
color willSaveButtonColor = color(200, 20, 20);
boolean drawSampleToggle=false;
boolean vertCursorToggle=true;
boolean drawFill=false;

// Reference
//
boolean refShow = false;	// If the reference graph is shown on screen
boolean refStoreFlag = false; // Used to flag a save in draw()
DataPoint[] refArray ; // Storage of reference graph
boolean refArrayHasData = false;
int refYoffset=0;


// Average
//
DataPoint[] avgArray ; // Storage of reference graph
boolean avgShow = false;
boolean avgArrayHasData = false;
int avgDepth = 10;
int avgNewSampleWeight = 1;
boolean avgSamples = false;

// Persistent
//
DataPoint[] perArray ; // Storage of Minimum and Maximum persiastant data graph
boolean perShowMax = false;
boolean perShowMin = false;
boolean perShowMed = false;
boolean perArrayHasData = false;


int lastScanPosition = 0;
int scanPosition = 0;
int completeCycles = 0;	// How many times the scanner has finished the defined range

color tabColorBachground = color(0, 70, 80);


//=========================

void MsgBox( String Msg, String Title ) {
  // Messages
  javax.swing.JOptionPane.showMessageDialog ( null, Msg, Title, javax.swing.JOptionPane.ERROR_MESSAGE  );
}

void setupStartControls() {
  int x, y;
  int width = 170;

  x = 15;
  y = 40;

  // frameRate(30);

  deviceDropdown = cp5.addListBox("deviceDropdown")
    .setBarHeight(20)
    .setItemHeight(20)
    .setPosition(x, y)
    .setSize(width, 20 + ((glb_devices.length) * 30));  // TAG_HACKRF

  deviceDropdown.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setText("Select device");
  int i;
  for (i=0; i<glb_devices.length; i++) {
     deviceDropdown.addItem(glb_devices[i], i);
  }
  
  
  
  // deviceDropdown.addItem("Hack RF", i); // TAG_HACKRF

  scaledBuffer =  new DataPoint[0];
}

// Generic event handler for controls
//
void controlEvent(ControlEvent theEvent) {
  // println("controlEvent: EVENT DETECTED");
  if (theEvent.isTab()) {
    // println("got an event from tab : "+theEvent.getTab().getName()+" with id "+theEvent.getTab().getId());
    cp5.getTab(tabActiveName).setHeight(TAB_HEIGHT);
    tabActiveID = theEvent.getTab().getId();
    theEvent.getTab().setHeight(TAB_HEIGHT_ACTIVE);
    tabActiveName = theEvent.getTab().getName();
  }

  if (theEvent.isController()) {
    println(theEvent.getController().getName());
    if (theEvent.getController().getName()=="rfGain") {
      println("RF GAIN CLICKED");
    }
  }
}

public void cropPrcntTxt(String tmpText) {
  cropPercent = parseInt(tmpText);
  cropPercent = max( min(70, cropPercent ), 0 );
  cp5.get(Textfield.class, "cropPrcntTxt").setText(strArj(cropPercent));
  setRangeButton();
}

// Change the active configuration from the drop down list
//
public void configurationList(int confValue) {
  if ( configurationOperation == PRESET_SAVE ) {
    configurationName = cp5.get(Textfield.class, "presetName").getText();
    table.setString( confValue, "configName", configurationName);
    saveConfigToIndx( confValue );
    configurationDropdown.clear();
    for (int i=0; i<nrOfConfigurations; i++) {
      configurationDropdown.addItem( table.getString(i, "configName"), i);
    }
    configurationActive = confValue;
  } else {	// Load
    configurationActive = confValue;
    println("configurationList: Setting active configuration to " + confValue );
    presetRestore();
  }

  configurationOperation = NONE;
  cp5.get(Textfield.class, "presetName").setText( configurationName );
  configurationDropdown.hide();
  cp5.get(Button.class, "savePreset").setColorBackground( buttonColor );
}

public void selectPreset() {
  if ( configurationDropdown.isVisible() ) {
    configurationDropdown.hide();
    configurationOperation = NONE;
    cp5.get(Button.class, "savePreset").setColorBackground( buttonColor );
  } else {
    configurationDropdown.show();
  }

  configurationDropdown.bringToFront();
  configurationDropdown.open();
}

public void savePreset() {
  if ( configurationOperation != NONE ) { // If already opened for saving, cancel it.
    configurationOperation = NONE;
    configurationDropdown.hide();
    configurationDropdown.close();
    cp5.get(Button.class, "savePreset").setColorBackground( buttonColor );
  } else {
    configurationOperation = PRESET_SAVE;
    configurationDropdown.show();
    configurationDropdown.open();
    cp5.get(Button.class, "savePreset").setColorBackground( willSaveButtonColor );
  }
}

public void presetRestore() {
  loadConfig();
  loadConfigPostCreation();
}

public void openSerial() {
  println( cp5.getController("serialPort").getValue());
  println( cp5.get(DropdownList.class, "serialPort").getValue());
}

public void rfGain(int gainValue) {
  // println( gainValue);
  spektrumReader.setGain(gainValue);
}

public void rfGain00(int gainValue) {
  rfGain( gains[0] );
  cp5.get(Knob.class, "rfGain").setValue(gains[0]);
}

public void rfGain01(int gainValue) {
  //println( (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) / 3 )  ) );
  int tpmInt = (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) * 1 / 3 )  ) ;
  rfGain( tpmInt );
  cp5.get(Knob.class, "rfGain").setValue(tpmInt);
}

public void rfGain02(int gainValue) {
  int tpmInt = (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) / 2 )  ) ;
  rfGain( tpmInt );
  cp5.get(Knob.class, "rfGain").setValue(tpmInt);
}

public void rfGain03(int gainValue) {
  int tpmInt = (int) (( gains[0] + ( gains[gains.length-1] - gains[0]) *2.5 / 3 )  ) ;
  rfGain( tpmInt );
  cp5.get(Knob.class, "rfGain").setValue(tpmInt);
}

public void rfGain04(int gainValue) {
  rfGain( gains[gains.length-1] );
  cp5.get(Knob.class, "rfGain").setValue(gains[gains.length-1]);
}

// IF settings UI
//
public void ifPlusToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      cp5.get(Toggle.class, "ifMinusToggle").setValue(0);
      ifType = IF_TYPE_ABOVE;
      ifOffset  = parseInt(cp5.get(Textfield.class, "ifOffset").getText());
    } else {
      ifType = IF_TYPE_NONE;
    }

    configurationSaveDelay = CONFIG_SAVE_DELAY;
  }
}
public void ifMinusToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      cp5.get(Toggle.class, "ifPlusToggle").setValue(0);
      ifType = IF_TYPE_BELOW;
      ifOffset  = parseInt(cp5.get(Textfield.class, "ifOffset").getText());
    } else {
      ifType = IF_TYPE_NONE;
    }
  }

  configurationSaveDelay = CONFIG_SAVE_DELAY;
}

// Min/Max UI
//
public void offsetToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      spektrumReader.setOffsetTunning(true);
    } else {
      spektrumReader.setOffsetTunning(false);
    }
  }
}

public void minmaxToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      minmaxDisplay = true;
    } else {
      minmaxDisplay = false;
    }
  }
}

public void sweepToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      sweepDisplay = true;
    } else {
      sweepDisplay = false;
    }
  }
}

public void perShowMaxToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      perShowMax = true;
    } else {
      perShowMax = false;
    }
  }
}

public void perShowMinToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      perShowMin = true;
    } else {
      perShowMin = false;
    }
  }
}

public void perShowMedToggle(int theValue) {
  if (setupDone) {
    if (theValue > 0) {
      perShowMed = true;
    } else {
      perShowMed = false;
    }
  }
}

public double ifCorrectedFreq( long inFreq ) {
  double tmpFreq=inFreq;

  if (ifType == IF_TYPE_ABOVE) tmpFreq -= ifOffset;
  else if (ifType == IF_TYPE_BELOW) tmpFreq = ifOffset - tmpFreq;

  return tmpFreq;
}

public void setRangeButton() {
  setRange();
}

public void setRange() {
  // Button color indicating change
  cp5.get(Button.class, "setRangeButton").setColorBackground( buttonColor );

  cursorVerticalLeftX = -1;
  cursorVerticalRightX = -1;

  try {
    glb_startFreq = Long.parseLong(cp5.get(Textfield.class, "startFreqText").getText());
    glb_stopFreq = Long.parseLong(cp5.get(Textfield.class, "stopFreqText").getText());
    glb_binStep = parseInt(cp5.get(Textfield.class, "binStepText").getText());
    cropPercent = parseInt(cp5.get(Textfield.class, "cropPrcntTxt").getText());
  }
  catch(Exception e) {
    println("setRange exception.");
  }

  if (glb_startFreq == 0 || glb_stopFreq <= glb_startFreq || glb_binStep < 1) return;

  configurationSaveDelay = CONFIG_SAVE_DELAY;

  double tmpCrop = (double) ( max( min(70, cropPercent ), 0 ) / 100.0);
  relMode = 0;
  spektrumReader.clearFrequencyRange();
  spektrumReader.setFrequencyRange(glb_startFreq, glb_stopFreq, glb_binStep, tmpCrop);
  spektrumReader.startAutoScan();
  println("setRange: CROP set to " + tmpCrop);
}

public void setScale() {
  // Button color indicating change
  cp5.get(Button.class, "setScale").setColorBackground( buttonColor );

  cursorHorizontalTopY = -1;
  cursorHorizontalBottomY = -1;

  try {
    scaleMin = parseInt(cp5.get(Textfield.class, "scaleMinText").getText());
    scaleMax = parseInt(cp5.get(Textfield.class, "scaleMaxText").getText());
  }
  catch(Exception e) {
    return;
  }

  configurationSaveDelay = CONFIG_SAVE_DELAY;
}


public void resetScale() {
  scaleMin = glb_fullScaleMin;
  scaleMax = glb_fullScaleMax;
  cp5.get(Textfield.class, "scaleMinText").setText(strArj(scaleMin));
  cp5.get(Textfield.class, "scaleMaxText").setText(strArj(scaleMax));
}

public void autoScale() {
  if (setupDone) {
    if (minmaxDisplay) {
      scaleMin = (int)(minValue - abs((float)minValue*0.1));
      scaleMax = (int)(maxValue + abs((float)maxValue*0.1));
    } else {
      scaleMin = (int)(minScaledValue - abs((float)minScaledValue*0.1));
      scaleMax = (int)(maxScaledValue + abs((float)maxScaledValue*0.1));
    }
    cp5.get(Textfield.class, "scaleMinText").setText(strArj(scaleMin));
    cp5.get(Textfield.class, "scaleMaxText").setText(strArj(scaleMax));
  }
}

void refSave(  ) {
  println("Flaging for graph storage");
  refStoreFlag = true;
}

void perReset(  ) {
  perArrayHasData = false;
}

// On set scale (V or H) fix the cursors involved so the primaries are always on the lower side (swap them is needed).
void swapCursors() {
  int tmpInt;

  if (cursorVerticalLeftX > cursorVerticalRightX) {
    tmpInt = cursorVerticalLeftX;
    cursorVerticalLeftX = cursorVerticalRightX;
    cursorVerticalRightX = tmpInt;
  }

  if (cursorHorizontalTopY > cursorHorizontalBottomY) {
    tmpInt = cursorHorizontalTopY;
    cursorHorizontalTopY = cursorHorizontalBottomY;
    cursorHorizontalBottomY = tmpInt;
  }
}

void zoomBack() {

  swapCursors();//Fix order

  cp5.get(Textfield.class, "startFreqText").setText( strArj(glb_zoomBackFreqMin) );
  cp5.get(Textfield.class, "stopFreqText").setText( strArj(glb_zoomBackFreqMax) );
  cp5.get(Textfield.class, "scaleMinText").setText( strArj(zoomBackScalMin) );
  cp5.get(Textfield.class, "scaleMaxText").setText( strArj(zoomBackScalMax) );

  glb_zoomBackFreqMin = glb_startFreq;
  glb_zoomBackFreqMax = glb_stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;

  setScale();
  setRange();
}

void zoomIn() {

  swapCursors();//Fix order

  glb_zoomBackFreqMin = glb_startFreq;
  glb_zoomBackFreqMax = glb_stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;

  cp5.get(Textfield.class, "startFreqText").setText( strArj(glb_startFreq + hzPerPixel() * (cursorVerticalLeftX - graphX())) );
  cp5.get(Textfield.class, "stopFreqText").setText( strArj(glb_startFreq + hzPerPixel() * (cursorVerticalRightX - graphX())) );
  cp5.get(Textfield.class, "scaleMinText").setText( strArj(scaleMax - ( ( (cursorHorizontalBottomY - graphY()) * gainPerPixel() ) / 1000 )) );
  cp5.get(Textfield.class, "scaleMaxText").setText( strArj(scaleMax - ( ( (cursorHorizontalTopY - graphY()) * gainPerPixel() ) / 1000 )) );

  setScale();
  setRange();
}

public void toggleRelMode(int theValue) {
  if (setupDone) {
    relMode++;
    if (relMode > 2) {
      relMode = 0;
    }
  }
}

public void deviceDropdown(int theValue) {
    deviceDropdown.hide();
    
    String selectedText = deviceDropdown.getItem(theValue).get("name").toString();
    
    // TODO_REMOVE MsgBox("Device selected : " + theValue + " " + selectedText, "Spektrum");
    
    if ( selectedText.startsWith("Hack RF") ) {
    	spektrumReader = new HackRFspektrum(theValue);
    	// MsgBox("HackRF device selected.", "Spektrum");
    }
    else
    {
      spektrumReader = new RtlspektrumWrapper(theValue);
    	// MsgBox("RTL-SDR device selected.", "Spektrum");  
    }
  
    int status = spektrumReader.openDevice();
  
    // Initialiaze configuration class array
    //
    for (int i=0; i<nrOfConfigurations; i++) {
      configSet[i] = new  configurationClass(i+1);
    }
  
    //============ Function calls added by Dave N
    makeConfig();  // create config file if it is not found.
    loadConfig();
    //============================
  
    if (status < 0) {
      MsgBox("Error: Can't open SDR device.", "Spektrum");
      exit();
      return;
    }
  
    // Device dependent parameters
    //
    gains = spektrumReader.getGains();
    glb_fullRangeMin = spektrumReader.getFrequencyRangeSupported()[0];
    glb_fullRangeMax = spektrumReader.getFrequencyRangeSupported()[1];
    
    // println("XXXXXXXXXXXXXXXXXXXXXXXXXX  " + spektrumReader.getFrequencyRangeSupported()[0] + "     " + spektrumReader.getFrequencyRangeSupported()[1] ); 
    
    setupControls();
    relMode = 0;
  
    setupDone = true;
    genericFrameCounter = 0;
}

public void gainDropdown(int theValue) {
    spektrumReader.setGain(gains[theValue]);
}
void settings() {
    lastWidth = 1200;
    lastHeight = 750;
    size(lastWidth, lastHeight, P3D );  // P2D, P3D Size should be the first statement TODO add method to settings file
}

void setup() {
  windowTitle( glb_WindowTitle + glb_ProgramVersion );
  surface.setResizable(true);
  frameRate(60);  // TODO Add it to settings file
  
    
  // Get the current working directory
  //
  glb_currentPath = System.getProperty("user.dir");
  println("Current working directory: " + glb_currentPath);
  
  glb_currentPath = "D:\\bin\\SDR\\hackRF-Tools-bin";
  
  // Get RTL devices
  //
  glb_devices = Rtlspektrum.getDevices();
  for (String dev : glb_devices) {
    println(dev);
  }
  
  // Get HackRF devices
  //
  HackRFspektrum hackRF = new HackRFspektrum(0);  // Create an instance of HackRFspektrum
  String[] devicesHackRF = hackRF.getDevices();   // Call the non-static method on the instance
  for (String dev : devicesHackRF) {
    println(dev);
	glb_devices = addElement(glb_devices, "Hack RF (" + dev + ")");
  }

  cp5 = new ControlP5(this);

  setupStartControls();

  
  println("Reached end of setup.");

  reloadConfigurationAfterStartUp = CONFIG_RELOAD_DELAY;//Reload configuration after this time
}

void stop() {
  spektrumReader.stopAutoScan();
}
void windowResized() {
	println("windowResized: RESIZE DETECTED ");
	genericFrameCounter = 0;
	// surface.setSize(width, height);
  
}

void draw() {
  genericFrameCounter++;	
  background(color(#222324));

  if ( !setupDone ) {
    return;
  }

  if ( width != lastWidth || height != lastHeight )
  {
    refShow = false;
    avgShow = false;
    println("RESIZE DETECTED :" + genericFrameCounter);
    lastWidth = width;
	  lastHeight = height;
	
    cp5.get(Toggle.class, "refShow").setValue(0);
    cp5.get(Toggle.class, "avgShow").setValue(0);
    return;
  }

  if (relMode == 1) {
    cp5.get(Button.class, "toggleRelMode").getCaptionLabel().setText("Set relative");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.RECORD);
  } else if (relMode == 2) {
    cp5.get(Button.class, "toggleRelMode").getCaptionLabel().setText("Cancel relative");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.RELATIVE);
  } else {
    cp5.get(Button.class, "toggleRelMode").getCaptionLabel().setText("Relative mode");
    spektrumReader.setRelativeMode(Rtlspektrum.RelativeModeType.NONE);
  }

  double[] buffer = spektrumReader.getDbmBuffer();

  minValue = Double.POSITIVE_INFINITY;
  minScaledValue = Double.POSITIVE_INFINITY;

  maxValue = Double.NEGATIVE_INFINITY;
  maxScaledValue = Double.NEGATIVE_INFINITY;
  for (int i = 0; i<buffer.length; i++) {
    if (minValue > buffer[i] && buffer[i] != Double.NEGATIVE_INFINITY) {
      minFrequency = glb_startFreq + i * glb_binStep;
      minValue = buffer[i];
    }

    if (maxValue < buffer[i] && buffer[i] != Double.POSITIVE_INFINITY) {
      maxFrequency = glb_startFreq + i * glb_binStep;
      maxValue = buffer[i];
    }
  }

  scaledBuffer = scaleBufferX(buffer);

  // Mouse Pointer
  //
  // Hand cursor ?
  //
  if (Math.abs( mouseX -  cursorVerticalLeftX ) < 20  ||
      Math.abs( mouseX -  cursorVerticalRightX ) < 20 ||
      Math.abs( mouseY -  cursorHorizontalTopY ) < 20 ||
      Math.abs( mouseY -  cursorHorizontalBottomY ) < 20
  ) 
  {
      if (glb_lastCursor != HAND ) { cursor(HAND); glb_lastCursor = HAND; }
  }
  else if ( mouseX < graphX() ) {
      if (glb_lastCursor != ARROW ) { cursor(ARROW); glb_lastCursor = ARROW; }
  }
  else
  {
      if (glb_lastCursor != NORMAL ) { cursor(NORMAL); glb_lastCursor = NORMAL; }
  }
  
  // Tooltips
  //
  if ( width - mouseX < 30 ) {
      if ( glb_tooltipCounter == 0 ) glb_tooltipCounter = TOOLTIP_TIME;
      if ( glb_tooltipCounter >1 ) showTooltip( mouseX - 150, mouseY,"Use mouse wheel\n to change upper frequency");
  }
  else if ( height - mouseY < 30 ) {
      if ( glb_tooltipCounter == 0 ) glb_tooltipCounter = TOOLTIP_TIME;
      if ( glb_tooltipCounter >1 ) showTooltip( mouseX - 150, mouseY - 60,"Use mouse wheel\n to change lower db limit");   
  }
  else if ( mouseY < 30 ) {
      if ( glb_tooltipCounter == 0 ) glb_tooltipCounter = TOOLTIP_TIME;
      if ( glb_tooltipCounter >1 ) showTooltip( mouseX - 150, mouseY + 20,"Use mouse wheel\n to change upper db limit");   
  }
  else if ( Math.abs(graphX() - mouseX) < 30 ) {
      if ( glb_tooltipCounter == 0 ) glb_tooltipCounter = TOOLTIP_TIME;
      if ( glb_tooltipCounter >1 ) showTooltip( mouseX , mouseY ,"Use mouse wheel\n to change lower frequency");
  }
  else
  {
      glb_tooltipCounter = 0;
  }
  if ( glb_tooltipCounter > 1 ) glb_tooltipCounter--;
  
  
  
  // Reference graph
  //
  if ( !refArrayHasData && refShow  ) {
    refArray = new DataPoint[scaledBuffer.length];
    refShow = false;
    cp5.get(Toggle.class, "refShow").setValue(0);
  }
  if ( refShow && refArray.length != scaledBuffer.length ) {
    refStoreFlag = true;
    refShow = false;
  }
  if ( refStoreFlag ) {

    // println("STORE size: " + refArray.length );

    if (avgShow && avgArrayHasData ) {
      refArray = new DataPoint[avgArray.length];
      arrayCopy( avgArray, refArray );
      cp5.get(Toggle.class, "avgShow").setValue(0);
    } else {
      refArray = new DataPoint[scaledBuffer.length];
      arrayCopy( scaledBuffer, refArray );
    }
    refArrayHasData = true;
    refStoreFlag = false;
    refShow = true;
    cp5.get(Toggle.class, "refShow").setValue(1);
    cp5.get(Knob.class, "refYoffset").setValue(0);
  }

  // Average graph
  //
  if ( !avgArrayHasData && avgShow  ) {
    avgArray = new DataPoint[scaledBuffer.length];
  }
  if ( avgShow && avgArray.length != scaledBuffer.length ) {
    avgArray = new DataPoint[scaledBuffer.length];
  }

  // Persistent data graph
  //
  if ( !perArrayHasData && (perShowMin || perShowMax || perShowMed)  ) {
    perArray = new DataPoint[scaledBuffer.length];
  }
  if ( (perShowMin || perShowMax || perShowMed) && perArray.length != scaledBuffer.length ) {
    perArray = new DataPoint[scaledBuffer.length];
  }

  // Data processing per screen point
  //
  for (int i = 0; i<scaledBuffer.length; i++) {
    if (scaledBuffer[i] == null) continue;

    if (minScaledValue > scaledBuffer[i].yAvg) {
      minScaledValue = scaledBuffer[i].yAvg;
    }

    if (maxScaledValue < scaledBuffer[i].yAvg) {
      maxScaledValue = scaledBuffer[i].yAvg;
    }
  }


  drawGraphMatt(scaleMin, scaleMax, glb_startFreq, glb_stopFreq);

  double scaleFactor = (double)graphHeight() / (scaleMax - scaleMin);
  DataPoint lastPoint = null;
  DataPoint refLastPoint = null;
  DataPoint avgLastPoint = null;
  DataPoint perLastPoint = null;

  DataPoint point = null;
  DataPoint refPoint = null;
  DataPoint avgPoint = null;
  DataPoint perPoint = null;

  color tmpColorGraph = color( 200, 200, 40 );
  color tmpColorAvg = color( 10, 200, 40 );
  color tmpColorRef = color( 51, 51, 255 );
  color tmpColorPerMax = color( 180, 180, 180 );
  color tmpColorPerMin = color( 160, 160, 160 );
  color tmpColorPerMed = color( 51, 204, 255 );
  color tmpColorFill = color ( 102, 102, 0 );


  int tmpAlpha = 255;
  if (avgShow || perShowMed)  tmpAlpha = 70;
  else tmpAlpha = 255;

  // Main point per point loop
  //
  for (int i = 0; i < scaledBuffer.length; i++) {
    point = scaledBuffer[i];
    refPoint = null;
    avgPoint = scaledBuffer[i];
    perPoint = scaledBuffer[i];

    if (refShow && refArrayHasData ) {
      refPoint = refArray[i];
    }
    if (avgShow && avgArrayHasData ) {
      avgPoint = avgArray[i];
    }
    if ((perShowMin || perShowMax || perShowMed ) && perArrayHasData ) {
      perPoint = perArray[i];
    }

    if (point == null ) continue;
    if (avgPoint == null) avgArrayHasData = false;
    if (perPoint == null) perArrayHasData = false;

    if (lastPoint != null) {

      // MAIN graph
      //
      if ( drawFill ) {
        graphDrawFill(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), tmpColorFill, 255);  // #fcf400
      }

      graphDrawLine(lastPoint.x, (int)((lastPoint.yAvg - scaleMin) * scaleFactor), point.x, (int)((point.yAvg - scaleMin) * scaleFactor), tmpColorGraph, tmpAlpha);

      if (minmaxDisplay) {
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMin - scaleMin) * scaleFactor), point.x, (int)((point.yMin - scaleMin) * scaleFactor), #C23B22, 255);
        graphDrawLine(lastPoint.x, (int)((lastPoint.yMax - scaleMin) * scaleFactor), point.x, (int)((point.yMax - scaleMin) * scaleFactor), #03C03C, 255);
      }

      // Reference graph
      //
      if (refShow) {
        graphDrawLine(refLastPoint.x, ((int)((refLastPoint.yAvg - scaleMin) * scaleFactor) )  - refYoffset,
          refPoint.x, ( (int)((refPoint.yAvg - scaleMin) * scaleFactor)) - refYoffset, tmpColorRef, 255);
      }

      // Average graph
      //
      if (avgShow) {
        if ( !avgArrayHasData ) {	// Initialize array
          println("STORING Average");
          avgArray = new DataPoint[scaledBuffer.length];
          arrayCopy( scaledBuffer, avgArray);
          avgArrayHasData = true;
        } else	// Update and show
        {
          if ( !avgSamples  )
          {
            // if (scaledBuffer[i].yAvg > 1000) println(scaledBuffer[i].yAvg);
            if (scaledBuffer[i].yAvg < 1000)
              avgArray[i].yAvg = avgArray[i].yAvg - (avgArray[i].yAvg / avgDepth ) +  (scaledBuffer[i].yAvg / (float)avgDepth);
          } else if ( completeCycles > 0) {
            avgArray[i].yAvg = avgArray[i].yAvg - (avgArray[i].yAvg / avgDepth ) +  (scaledBuffer[i].yAvg / (float)avgDepth);
            completeCycles = 0;
            // println("UPDATED");
          }

          if (avgLastPoint!= null) {
            graphDrawLine(avgLastPoint.x, (int)((avgLastPoint.yAvg - scaleMin) * scaleFactor), avgPoint.x, (int)((avgPoint.yAvg - scaleMin) * scaleFactor), tmpColorAvg, 255);
          }
        }
      }

      // Persistent graph
      //
      if (perShowMin || perShowMax || perShowMed) {
        if ( !perArrayHasData ) {	// Initialize array
          println("STORING Persistant");
          perArray = new DataPoint[scaledBuffer.length];
          arrayCopy( scaledBuffer, perArray);
          for ( int jj=0; jj< scaledBuffer.length-1; jj++) {
            perArray[jj].yMax = perArray[jj].yAvg ;
            perArray[jj].yMin = perArray[jj].yAvg ;
          }

          perArrayHasData = true;
        } else	// Update and show
        {
          if ( scaledBuffer[i].yAvg> perArray[i].yMax ) perArray[i].yMax = scaledBuffer[i].yAvg;
          if ( scaledBuffer[i].yAvg< perArray[i].yMin ) perArray[i].yMin = scaledBuffer[i].yAvg;
          perArray[i].yAvg = perArray[i].yMin + ( perArray[i].yMax - perArray[i].yMin ) /2;

          if (perLastPoint!= null) {
            if (perShowMax)
              graphDrawLine(perLastPoint.x, (int)((perLastPoint.yMax - scaleMin) * scaleFactor), perPoint.x, (int)((perPoint.yMax - scaleMin) * scaleFactor), tmpColorPerMax, 200);
            if (perShowMin)
              graphDrawLine(perLastPoint.x, (int)((perLastPoint.yMin - scaleMin) * scaleFactor), perPoint.x, (int)((perPoint.yMin - scaleMin) * scaleFactor), tmpColorPerMin, 200);
            if (perShowMed)
              graphDrawLine(perLastPoint.x, (int)((perLastPoint.yAvg - scaleMin) * scaleFactor), perPoint.x, (int)((perPoint.yAvg - scaleMin) * scaleFactor), tmpColorPerMed, 255);
          }
        }
      }
    }

    lastPoint = point;
    refLastPoint = refPoint;
    avgLastPoint = avgPoint;
    perLastPoint = perPoint;
  }

  fill(#222324);
  stroke(#D5921F);

  // Original Min/Max
  //
  textAlign(LEFT);
  fill(#C23B22);
  text("Min: " + String.format("%.2f", minFrequency / 1000) + "MHz " + String.format("%.2f", minValue) + "dB", minMaxTextX +5, minMaxTextY+20);    // TO_CHECK
  fill(#03C03C);
  text("Max: " + String.format("%.2f", maxFrequency / 1000) + "MHz " + String.format("%.2f", maxValue) + "dB", minMaxTextX +5, minMaxTextY+40);    // TO_CHECK

  // Cursors and measurements
  //
  if (vertCursorToggle) {
    drawVertCursor();
  }

  // UI seperator lines
  //
  for ( uiNextLineIndex = 0; uiLines[uiNextLineIndex][tabActiveID] != 0; uiNextLineIndex++ )
    line( 5, uiLines[uiNextLineIndex][tabActiveID] + 30, 195, uiLines[uiNextLineIndex][tabActiveID]  + 30);


  // Frequency scan detection (complete cycles through spectrum range)
  //
  scanPosition = spektrumReader.getScanPos();

  if ( lastScanPosition != scanPosition ) {
    if (scanPosition - lastScanPosition <= 0) completeCycles++;
    lastScanPosition = scanPosition ;
    // println("RECYCLE !!!" + lastScanPosition);
  }

  // Sweep indicator position (vertical line)
  //
  if (sweepDisplay) {
    int scanPos = (int)(((float)graphWidth() / (float)buffer.length) * (float)scanPosition);
    sweep(scanPos, #FFFFFF, 64);
  }

  if (cursorVerticalLeftX < 0) cursorVerticalLeftX = graphX();
  if (cursorVerticalRightX < 0) cursorVerticalRightX = graphX() + graphWidth();
  if (cursorHorizontalTopY < 0) cursorHorizontalTopY = graphY();
  if (cursorHorizontalBottomY < 0) cursorHorizontalBottomY = graphY() + graphHeight();

  if ( timeToSet > 1 ) {
    timeToSet--;

    if ( infoText1X != 0) {  // Do we need any infomative text ?
      fill( infoColor );
      textSize(40);
      text( infoText, infoText1X, infoText1Y );
      textSize(12);
      stroke(#FFFFFF);
      if (itemToSet == ITEM_FREQUENCY)  line(infoLineX, graphY(), infoLineX, graphY() + graphHeight());
      if (itemToSet == ITEM_GAIN)       line(graphX(), infoLineY, graphX() + graphWidth(), infoLineY);
      if (itemToSet == ITEM_ZOOM) {
        noFill();
        rect( infoRectangle[0], infoRectangle[1], infoRectangle[2], infoRectangle[3] );
      }
    }
  } else if ( timeToSet == 1 ) {
    timeToSet = 0;
    if (itemToSet == ITEM_FREQUENCY) setRange();
    if (itemToSet == ITEM_GAIN) setScale();
    if (itemToSet == ITEM_ZOOM) {
      setScale();
      setRange();
    }

    infoText1X = 0;
  }

  // Delayed saving
  //
  if (configurationSaveDelay > 1) {
    configurationSaveDelay--;
  } else if (configurationSaveDelay == 1) {
    configurationSaveDelay = 0;
    saveConfig();
    println("TMR: Config saved (after delay).");
  }
}
//
// end of draw routine =============================================


// Help Button
//
void helpShow ( ) {
  Textarea tmpTA=cp5.get(Textarea.class, "textArea01");
  PFont pfont = createFont("Arial", 15, true); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont, 15, 50);

  tmpTA.moveTo("global");

  tmpMessage = "SPEKTRUM - Quick reference.\n";
  tmpMessage+= "\n";
  tmpMessage+= "Mouse operation :-                                                                          \n" ;
  tmpMessage+= "\n";
  tmpMessage+= "Left Mouse Button :                                                                         \n" ;
  tmpMessage+= "- Click and Drag on Cursor : Move cursor                                                    \n" ;
  tmpMessage+= "- Double Click : Zoom in defined area (by cursors)                                          \n" ;
  tmpMessage+= "\n";
  tmpMessage+= "Right Mouse Button :                                                                        \n" ;
  tmpMessage+= "- Click : Move primary cursors to mouse pointer                                             \n" ;
  tmpMessage+= "- Double click : Move primary cursors to pointer, store away secondary cursors.             \n" ;
  tmpMessage+= "- Click and Drag : Define an area with primary and secondary cursors. Diff. measurements.   \n" ;
  tmpMessage+= "\n";
  tmpMessage+= "Mouse wheel :                                                                               \n" ;
  tmpMessage+= "- Double click : Reset full ranges (Amplitude and Frequency)                                \n" ;
  tmpMessage+= "- Click and Drag : Move graph in X/Y preserving X/Y delta ranges (Pan graph)                \n" ;
  tmpMessage+= "- Rotate on top/bottom of graph to change corresponding Amplitude limit                     \n" ;
  tmpMessage+= "- Rotate on left/right of graph to change corresponding frequency limit                     \n" ;
  tmpMessage+= "- Rotate in middle of graph to change zoom level (X and Y)                                  \n" ;
  tmpMessage+= "\n\n";
  tmpMessage+= "\n";

  tmpMessage1 = "Tips\n\n";
  tmpMessage1+= "- On rotary knobs (eg RF gain) left click and drag up/down for fast adjustment. \n";
  tmpMessage1+= "- An average graph may also be saved as reference if it is active when the 'SAVE REFERENCE'\n";
  tmpMessage1+= "  Button is clicked        \n";
  tmpMessage1+= "- Crop (percent) will make the graph smoother but slower. Enter a value between 0 and 70 and\n";
  tmpMessage1+= "  press [ENTER]\n";
  tmpMessage1+= "\n\n\n\n\n\n\n\n\n\n\n\n\n";
  tmpMessage1+= "\n";
  tmpMessage1+= glb_ProgramVersion + ": https://github.com/SV8ARJ/spektrum";

  if ( showInfoScreen == 0) {
    tmpTA.setPosition( graphX() + 10, graphY() + 10 );
    tmpTA.setSize(graphWidth() - 20, graphHeight() - 20);
    tmpTA.setColorBackground( #808080);
    tmpTA.setText(tmpMessage + tmpMessage1);
    tmpTA.setFont(font);

    // Close button
    //
    cp5.addButton("closeHelp")
      .setPosition(graphX() + graphWidth() - 60, graphY() + 15)
      .setSize(40, 20)
      .setColorBackground(buttonColor)
      .setColorLabel(buttonColorText)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER).setText("CLOSE")
      ;

    showInfoScreen = 1;
  } else {
    showInfoScreen = 0;
    tmpTA.clear();
    tmpTA.setPosition( 0, -20 );
    tmpTA.setSize(10, 10);
    cp5.get(Button.class, "closeHelp").remove();
  }
}

void closeHelp () {
  helpShow ( );
}

// Average waveform check box
//
void avgShow( int value)
{
  if (value == 1) {
    avgShow = true;
    avgArrayHasData = false;
    avgDepth = max( parseInt(cp5.get(Textfield.class, "avgDepthTxt").getText()), 2);
  } else {
    avgShow = false;
    avgArrayHasData = false;
  }
}

void freezeDisplay() {
  //================ added by DJN 26 Aug 2017
  if (frozen) {
    frozen = false;
    cp5.get(Button.class, "freezeDisplay").getCaptionLabel().setText("Pause");
    loop();
    println("Display unfrozen.");
  } else {
    frozen = true;
    cp5.get(Button.class, "freezeDisplay").getCaptionLabel().setText("Run");
    noLoop();
    println("Display frozen.");
  }
}

void exitProgram() {
  println("Exit program rtn.");
  if (setupDone)  exit();
}

public void resetMin() {
  //Set the start freq at full range

  cp5.get(Textfield.class, "startFreqText").setText( strArj(glb_fullRangeMin) );
  setRange();
}


void resetMax() {
  //Set the stop freq full range

  cp5.get(Textfield.class, "stopFreqText").setText( strArj(glb_fullRangeMax) );
  setRange();
}

void loadConfigPostCreation()
{
  cp5.get(Textfield.class, "startFreqText").setText( strArj(glb_startFreq) );
  cp5.get(Textfield.class, "stopFreqText").setText( strArj(glb_stopFreq) );
  cp5.get(Textfield.class, "scaleMinText").setText( strArj(scaleMin) );
  cp5.get(Textfield.class, "scaleMaxText").setText( strArj(scaleMax) );

  if (ifType == IF_TYPE_ABOVE) {
    cp5.get(Toggle.class, "ifMinusToggle").setValue(0);
    cp5.get(Toggle.class, "ifPlusToggle").setValue(1);
  } else if (ifType == IF_TYPE_BELOW ) {
    cp5.get(Toggle.class, "ifMinusToggle").setValue(1);
    cp5.get(Toggle.class, "ifPlusToggle").setValue(0);
  } else {
    cp5.get(Toggle.class, "ifMinusToggle").setValue(0);
    cp5.get(Toggle.class, "ifPlusToggle").setValue(0);
  }

  cp5.get(Textfield.class, "ifOffset").setText(strArj(ifOffset));
  cp5.get(Textfield.class, "cropPrcntTxt").setText(strArj(cropPercent));

  setScale();
  setRange();

  configurationSaveDelay = 0;
}

void loadConfig() {
  table = loadTable(glb_configFileName, "header");

  glb_startFreq = Math.max(table.getLong(configurationActive, "startFreq"), glb_fullRangeMin );
  glb_stopFreq =  Math.min(table.getLong(configurationActive, "stopFreq"),  glb_fullRangeMax );
  if (glb_startFreq >= glb_stopFreq)  glb_stopFreq = glb_startFreq +100000;
  glb_binStep = table.getInt(configurationActive, "binStep");
  scaleMin = table.getInt(configurationActive, "scaleMin");
  scaleMax = table.getInt(configurationActive, "scaleMax");
  // glb_fullRangeMin = table.getInt(configurationActive, "minFreq");
  // glb_fullRangeMax = table.getInt(configurationActive, "maxFreq");

  ifOffset = table.getInt(configurationActive, "ifOffset");
  ifType = table.getInt(configurationActive, "ifType");
  cropPercent = table.getInt(configurationActive, "cropPrcnt");

  configurationName = table.getString(configurationActive, "configName");

  //Protection
  if (glb_binStep < binStepProtection) glb_binStep = binStepProtection;
  cropPercent = max( min(70, cropPercent ), 0 );	// Just in case....

  // Init zoom back
  glb_zoomBackFreqMin = glb_startFreq;
  glb_zoomBackFreqMax = glb_stopFreq;
  zoomBackScalMin = scaleMin;
  zoomBackScalMax = scaleMax;

  println("loadConfig: Config table " + glb_configFileName + " loaded.");
  println("startFreq = " + glb_startFreq + " stopFreq = " + glb_stopFreq + " binStep = " + glb_binStep + " scaleMin = " +
    scaleMin + " scaleMax = ", scaleMax + " rfGain = " + rfGain + " fullRangeMin = " + glb_fullRangeMin + "  fullRangeMax = " + glb_fullRangeMax +
    " ifOffset = " + ifOffset + " ifType = " + ifType);

  try {
    cp5.get(Textfield.class, "ifOffset").setText(strArj(ifOffset));  // Spaghetti because mouse events and code modification events have the same result on event code...
  }
  catch (Exception e) {
  }
}

void saveConfig() {
  saveConfigToIndx( 0 );
}

void saveConfigToIndx( int configIndx ) {
  //================ Function added by DJN 24 Aug 2017
  // Note: saveTable fails if file is being backed up at time saveTable is run!
  int i;
  if (startingupBypassSaveConfiguration == false) {

    println("saveConfig: Active Configuration " + configurationActive + " with name " + configurationName);

    table.setInt(0, "activeConfig", configurationActive);

    table.setLong(configIndx, "startFreq", glb_startFreq);
    table.setLong(configIndx, "stopFreq", glb_stopFreq);
    table.setInt(configIndx, "binStep", glb_binStep);
    table.setInt(configIndx, "scaleMin", scaleMin);
    table.setInt(configIndx, "scaleMax", scaleMax);
    table.setInt(configIndx, "rfGain", rfGain);
    table.setLong(configIndx, "minFreq", glb_fullRangeMin);
    table.setLong(configIndx, "maxFreq", glb_fullRangeMax);
    table.setInt(configIndx, "ifOffset", ifOffset);
    table.setInt(configIndx, "ifType", ifType);
    table.setInt(configIndx, "cropPrcnt", cropPercent);

    saveTable(table, glb_configFileName, "csv");

    println("STORE TO " +  configIndx + " : startFreq = " + glb_startFreq + " stopFreq = " + glb_stopFreq + " binStep = " + glb_binStep + " scaleMin = " +
      scaleMin + " scaleMax = ", scaleMax + " rfGain = " + rfGain + " fullRangeMin = " + glb_fullRangeMin + "  fullRangeMax = " + glb_fullRangeMax +
      " ifOffset = " + ifOffset + " ifType = " + ifType);
    println("Config table " + glb_configFileName + " saved.");
  }
}

void makeConfig() {

  FileWriter fw= null;
  File file =null;
  println("File " + glb_configFileName);

  try {
    file=new File(glb_configFileName);
    println( file.getAbsolutePath());
    if (file.exists()) {
      println("File " + glb_configFileName + " exists.");
    } else {
      // Recreate missing config file
      file.createNewFile();
      fw = new FileWriter(file);

      fw.write("startFreq,stopFreq,binStep,scaleMin,scaleMax,rfGain,minFreq,maxFreq,ifOffset,ifType,cropPrcnt,activeConfig,configName\n");

      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,AutoSave\n");
      fw.write("88000000,108000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,FM Band\n");
      fw.write("118000000,178000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,VHF Band+\n");
      fw.write("380000000,450000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,UHF Band+\n");
      fw.write("120000000,170000000,2000,-110,40,0,24000000,1800000000,120000000,1,0,0,Spyverter\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config A\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config B\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config C\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config D\n");
      fw.write("24000000,1800000000,2000,-110,40,0,24000000,1800000000,0,0,0,0,Config E\n");

      fw.flush();
      fw.close();
      println(glb_configFileName +  " created succesfully");
    }
  }
  catch(IOException e) {
    e.printStackTrace();
  }


  println("Reached end of makeconfig");
}

//==============================================
void drawVertCursor() {
  float xBand;
  float xCur;
  float xPlot;
  xBand = (glb_stopFreq - glb_startFreq);

  int tmpInt;
  long glb_freqLeft;
  long glb_freqRight;
  glb_freqLeft = glb_startFreq + hzPerPixel() * (cursorVerticalLeftX - graphX());
  glb_freqRight = glb_startFreq + hzPerPixel() * (cursorVerticalRightX - graphX());
  float scaleBottom;
  float scaleTop;
  scaleBottom = scaleMax - ( ( (cursorHorizontalBottomY - graphY()) * gainPerPixel() ) / 1000.0 );
  scaleTop = scaleMax - ( ( (cursorHorizontalTopY - graphY()) * gainPerPixel() ) / 1000.0 );
  textSize(16);

  // LEFT
  stroke(cursorVerticalLeftX_Color);
  fill(cursorVerticalLeftX_Color);
  line(cursorVerticalLeftX, graphY(), cursorVerticalLeftX, graphY()+graphHeight());
  textAlign(CENTER);
  text(numToStr(ifCorrectedFreq(glb_freqLeft) /1000000)  + " MHz", cursorVerticalLeftX-10, graphY()  - 5);    // TO_CHECK

  // RIGHT
  stroke(cursorVerticalRightX_Color);
  fill(cursorVerticalRightX_Color);
  line(cursorVerticalRightX, graphY(), cursorVerticalRightX, graphY()+graphHeight());
  textAlign(CENTER);
  text(numToStr(ifCorrectedFreq(glb_freqRight)/1000000)  + " MHz", cursorVerticalRightX-10, graphY()  - 5);     // TO_CHECK

  // BOTTOM
  stroke(cursorHorizontalBottomY_Color);
  fill(cursorHorizontalBottomY_Color);
  line(graphX(), cursorHorizontalBottomY, graphX()+graphWidth(), cursorHorizontalBottomY);
  textAlign(CENTER);
  text(     String.format("%.1f", scaleBottom)  + " db", graphX()+graphWidth()+20, cursorHorizontalBottomY+4);

  // TOP
  stroke(cursorHorizontalTopY_Color);
  fill(cursorHorizontalTopY_Color);
  line(graphX(), cursorHorizontalTopY, graphX()+graphWidth(), cursorHorizontalTopY);
  textAlign(CENTER);
  text(String.format("%.1f", scaleTop)  + " db", graphX()+graphWidth()+20, cursorHorizontalTopY+4);

  // DELTA  - FREQ / SCALE
  //
  float tmpVSWR = 1;
  float tmpDdb = 0;

  tmpDdb = abs(scaleBottom - scaleTop);
  tmpVSWR = (pow(10, (tmpDdb / 20 )) +1 ) / ( pow( 10, (tmpDdb / 20))  - 1  ) ;

  int labelXOffset = 0;
  int labelYOffset = 0;
  if ( deltaLabelsX > graphX() -40 ) {
    if ( deltaLabelsX > graphWidth() / 2 ) labelXOffset = -140;
    else labelXOffset = 50;
    if ( deltaLabelsY > graphHeight() / 2 ) labelYOffset = -30;
    else labelYOffset = 60;
  }
  textAlign(LEFT);
  fill(cursorDeltaColor);
  text("Δx : " + numToStr((double)(glb_freqRight - glb_freqLeft)/1000000)  + " MHz", deltaLabelsX + labelXOffset, deltaLabelsY + labelYOffset );	// TO_CHECK
  text("Δy : " + String.format("%.1f", scaleBottom - scaleTop) + " db", deltaLabelsX + labelXOffset, deltaLabelsY + 20 + labelYOffset );
  textSize(12);
  text("VSWR: 1 : " + String.format("%.3f", tmpVSWR), deltaLabelsX + labelXOffset, deltaLabelsY + 38 + labelYOffset );

  textSize(12);
  noFill();
  stroke(#808080);
  rect( deltaLabelsX - 10 + labelXOffset, deltaLabelsY - 20 + labelYOffset, 170, 65);
}

// ====================================================================

String numToStr1(int inNum) {
  // Convert number to string with commas
  String outStr = nfc(inNum);
  return outStr;
}
String numToStr(double inNum) {
  // Convert number to string with commas using String.format
  String outStr = String.format(Locale.US, "%,.3f", inNum);
  return outStr;
}

int getGraphXfromFreq( long frequency ) {
  return (int) max(graphX() -10, min( graphX() + graphWidth() + 10, graphX() + graphWidth()  * (frequency/1000 - glb_startFreq/1000) / (glb_stopFreq/1000 - glb_startFreq/1000))); // TAG_TOCHECK
}

int getGraphYfromDb( int db ) {
  return min(graphY() + graphHeight() + 10, max( graphY() - 10, graphHeight() +graphY() - graphHeight() * (db - scaleMin) / (scaleMax - scaleMin) ));
}

//============== Move the red vertical cursor===============================================

void mousePressed(MouseEvent evnt) {
  int thisMouseX = mouseX;
  int thisMouseY = mouseY;

  boolean CLICK_ABOVE;
  boolean CLICK_LEFT;
  boolean DOUBLE_CLICK;

  CLICK_ABOVE = false;
  CLICK_LEFT = false;
  DOUBLE_CLICK = false;

  // Only alow clicks in the graph
  //
  if ( mouseX < graphX() ) return;

  // Help open ? Just close it
  //
  if (showInfoScreen >0) {
    closeHelp();
    return;
  }

  if (evnt.getCount() == 2) {
    DOUBLE_CLICK = true;
    if (mouseButton == RIGHT) {
      cursorVerticalRightX = graphWidth() + graphX();
      cursorHorizontalTopY = graphY();
    } // TAG01 RIGHT->LEFT was LEFT
    if (mouseButton == CENTER) {
      resetMin();
      resetMax();
      resetScale();
    };
    if (mouseButton == LEFT) zoomIn() ;        // TAG01 RIGHT->LEFT was RIGHT


    println("DOUBLE CLICK DETECTED");
    return;    // ATTENTION !!! RETURN !!!! BAD BAD HABIT. TODO properly. -GRG
  }


  //Protecion
  if (thisMouseX < graphX() || thisMouseX > graphWidth() + graphX() +1) return;
  if (thisMouseY < graphY() || thisMouseY > graphHeight() + graphY() +1) return;

  //Calculate center
  if ( (thisMouseX - graphX()) < (graphWidth()/2) ) {
    CLICK_LEFT = true;
  }

  if ( (thisMouseY - graphY() < graphHeight()/2) ) {
    CLICK_ABOVE = true;
  }


  long clickFreq = glb_startFreq + hzPerPixel() * (thisMouseX - graphX());
  int clickScale;
  clickScale = ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000;
  clickScale = scaleMax - clickScale;

  if (mouseButton == RIGHT ) // TAG01 RIGHT<->LEFT was LEFT
  {
    // Test if the mouse over graph
    if (thisMouseX >= graphX() && thisMouseX <= graphWidth() + graphX() +1) {
      mouseDragLock = true;

      vertCursorFreq = clickFreq;
      lastMouseX = mouseX;
      println("clickFreq = " + clickFreq);
    }


    cursorVerticalLeftX = mouseX;
    cursorHorizontalBottomY = mouseY;

    println("clickFreq: " + clickFreq + ",   clickScale: " + clickScale);
  } else if (mouseButton == CENTER) {

    mouseDragGraph = GRAPH_DRAG_STARTED;

    dragGraphStartX = mouseX;
    dragGraphStartY = mouseY;
  } else if (mouseButton == LEFT) {  // TAG01 RIGHT->LEFT was RIGHT
    int SELECT_THR = 20;
    // Drag cursors
    //
    //  TOP
    if ( abs(mouseY-cursorHorizontalTopY) <= SELECT_THR ) {
      println("TOP LINE");
      println("clickScale: " + clickScale);
      cp5.get(Textfield.class, "scaleMaxText").setText(strArj(clickScale));
      sweepVertical( mouseY - graphY(), #fcd420, 255);
      cursorHorizontalTopY = mouseY;
      movingCursor = CURSORS.CUR_Y_TOP;

      // Button color indicating change
      cp5.get(Button.class, "setScale").setColorBackground( clickMeButtonColor );
    }
    //  BOTTOM
    else if ( abs(mouseY-cursorHorizontalBottomY) <= SELECT_THR ) {
      println("BOTTOM LINE");
      println("clickScale: " + clickScale);
      cp5.get(Textfield.class, "scaleMinText").setText(strArj(clickScale));
      sweepVertical( mouseY - graphY(), #fcd420, 255);
      cursorHorizontalBottomY = mouseY;
      movingCursor = CURSORS.CUR_Y_BOTTOM;

      // Button color indicating change
      cp5.get(Button.class, "setScale").setColorBackground( clickMeButtonColor );
    }
    // LEFT
    else if ( abs(mouseX-cursorVerticalLeftX) <= SELECT_THR ) {
      println("LEFT LINE");
      println("clickFreq: " + clickFreq);
      cp5.get(Textfield.class, "startFreqText").setText(strArj(clickScale));
      sweep( mouseX - graphX(), #fcd420, 255);
      cursorVerticalLeftX = mouseX;
      movingCursor = CURSORS.CUR_X_LEFT;

      // Button color indicating change
      cp5.get(Button.class, "setRangeButton").setColorBackground( clickMeButtonColor );
    }
    // RIGHT
    else if ( abs(mouseX-cursorVerticalRightX) <= SELECT_THR ) {
      println("RIGHT LINE");
      println("clickFreq: " + clickFreq);
      cp5.get(Textfield.class, "stopFreqText").setText(strArj(clickScale));
      sweep( mouseX - graphX(), #fcd420, 255);
      cursorVerticalRightX = mouseX;
      movingCursor = CURSORS.CUR_X_RIGHT;

      // Button color indicating change
      cp5.get(Button.class, "setRangeButton").setColorBackground( clickMeButtonColor );
    }
  }
}

void mouseDragged() {
  int thisMouseX = mouseX;
  int thisMouseY = mouseY;

  //Protecion
  if (thisMouseX < graphX() || thisMouseX > graphWidth() + graphX() +1) return;
  if (thisMouseY < graphY() || thisMouseY > graphHeight() + graphY() +1) return;

  // Dragging Red cursor
  if (mouseDragLock) {
    if ( ( abs(cursorVerticalLeftX - mouseX) > startDraggingThr ) || ( abs(cursorHorizontalBottomY - mouseY) > startDraggingThr ) ) {
      cursorVerticalRightX = mouseX;
      cursorHorizontalTopY = mouseY;

      deltaLabelsX = mouseX-30;
      deltaLabelsY = mouseY-29;
    }
  }

  if (movingCursor == CURSORS.CUR_X_LEFT) {
    cursorVerticalLeftX = thisMouseX;
    long clickFreq = glb_startFreq + hzPerPixel() * (thisMouseX - graphX());
    cp5.get(Textfield.class, "startFreqText").setText( strArj(clickFreq) );
  } else if (movingCursor == CURSORS.CUR_X_RIGHT) {
    cursorVerticalRightX = thisMouseX;
    long clickFreq = glb_startFreq + hzPerPixel() * (thisMouseX - graphX());
    cp5.get(Textfield.class, "stopFreqText").setText( strArj(clickFreq) );
  } else if (movingCursor == CURSORS.CUR_Y_TOP) {
    cursorHorizontalTopY = thisMouseY;
    int clickScale = scaleMax - ( ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ) ;
    cp5.get(Textfield.class, "scaleMaxText").setText(strArj(clickScale));
  } else if (movingCursor == CURSORS.CUR_Y_BOTTOM) {
    cursorHorizontalBottomY = thisMouseY;
    int clickScale = scaleMax - ( ( (thisMouseY - graphY()) * gainPerPixel() ) / 1000 ) ;
    cp5.get(Textfield.class, "scaleMinText").setText(strArj(clickScale));
  }

  if (mouseButton == RIGHT) {    // TAG01 RIGHT->LEFT was LEFT
    stroke(#606060);
    line( cursorVerticalLeftX, cursorHorizontalBottomY, mouseX, mouseY) ;
  } else if (mouseButton == CENTER) {
    stroke(#606060);
    line( dragGraphStartX, dragGraphStartY, mouseX, mouseY) ;
  }
}

void mouseReleased() {
  mouseDragLock = false;
  lastMouseX = 0;

  movingCursor = CURSORS.CUR_NONE;

  deltaLabelsX = deltaLabelsXWaiting;
  deltaLabelsY = deltaLabelsYWaiting;

  // Move graph
  if (mouseDragGraph == GRAPH_DRAG_STARTED) {
    mouseDragGraph = GRAPH_DRAG_NONE;

    long deltaF;
    int deltaDB;
    long freqLeft;
    long freqRight;
    freqLeft = (long)(glb_startFreq + hzPerPixel() * (dragGraphStartX - graphX()));  // TO_CHECK
    freqRight = (long) (glb_startFreq + hzPerPixel() * (mouseX - graphX()));          // TO_CHECK
    int scaleBottom;
    int scaleTop;
    scaleBottom = scaleMax - ( ( (dragGraphStartY - graphY()) * gainPerPixel() ) / 1000 );
    scaleTop = scaleMax - ( ( (mouseY - graphY()) * gainPerPixel() ) / 1000 );

    deltaF = freqRight - freqLeft ;
    deltaDB = scaleBottom - scaleTop;

    // Move graph up/down
    if (deltaDB != 0) {
      scaleMin += deltaDB;
      scaleMax += deltaDB;

      // Protections
      if (scaleMin < glb_fullScaleMin) {
        scaleMin = glb_fullScaleMin;
      }
      if (scaleMin > glb_fullScaleMax) {
        scaleMin = glb_fullScaleMin;
      }
      if (scaleMax < glb_fullScaleMin) {
        scaleMax = glb_fullScaleMin;
      }
      if (scaleMax > glb_fullScaleMax) {
        scaleMax = glb_fullScaleMax;
      }

      // Set new scales
      cp5.get(Textfield.class, "scaleMinText").setText( strArj(scaleMin) );
      cp5.get(Textfield.class, "scaleMaxText").setText( strArj(scaleMax) );

      setScale();
      println("deltaDB: " + numToStr(deltaDB) + ", -New Scale: \n" + "  LOWER:" + numToStr(scaleMin) + ",  UPPER:" + numToStr(scaleMax) );
    }

    // Move graph right/left
    if (abs(deltaF) > 10) {
      glb_startFreq -= deltaF;
      glb_stopFreq -= deltaF;

      // Protections
      if (glb_startFreq < glb_fullRangeMin) {
        glb_startFreq = glb_fullRangeMin;
      }
      if (glb_startFreq > glb_fullRangeMax) {
        glb_startFreq = glb_fullRangeMax;
      }
      if (glb_stopFreq < glb_fullRangeMin) {
        glb_stopFreq = glb_fullRangeMin;
      }
      if (glb_stopFreq > glb_fullRangeMax) {
        glb_stopFreq = glb_fullRangeMax;
      }

      // Set new scales
      cp5.get(Textfield.class, "startFreqText").setText( strArj(glb_startFreq) );
      cp5.get(Textfield.class, "stopFreqText").setText( strArj(glb_stopFreq) );

      println("deltaF: " + numToStr(deltaF) + ", -New Freq: \n" + "  START:" + numToStr(glb_startFreq) + ",  STOP:" + numToStr(glb_stopFreq) );

      setRange();
    }
  }
}


void mouseWheel(MouseEvent event) {
  final int NOTHING = 0;
  final int GAIN_HIGH = 1;
  final int GAIN_LOW = 2;
  final int FREQ_LEFT = 4;
  final int FREQ_RIGHT = 8;
  final int GRAPH_ZOOM = 16;
  final int TIME_UNTIL_SET = 25;
  final int TIME_UNTIL_SET_FAST = 10;

  long tmpFreq;
  long tmpFreq2;
  int tmpGain;
  int tmpGain2;

  int toModify;
  int gMouseX;
  int gMouseY;
  int freqStep = 0;

  long scaleFreqOverDb = 0;

  gMouseX = mouseX - graphX();
  gMouseY = mouseY - graphY();

  toModify = NOTHING;

  // Centre of graph horizontal is for incr/decr GAIN top/bottom
  //
  if ( abs( gMouseX - graphWidth()/2 ) < graphWidth()/4 ) {
    // println ("Middle COLUMN");

    // Top or bottom ?
    //
    if ( gMouseY <  graphHeight()/4 ) {
      toModify = GAIN_HIGH;
    } else if (  graphHeight() - gMouseY <  graphHeight()/4 ) {
      toModify = GAIN_LOW;
    }
  }

  // Middle of graph's vertical is for incr/decr frequency max/min
  //
  if ( abs( gMouseY - graphHeight()/2 ) < graphHeight()/4 ) {
    // println ("Middle ROW");

    // Left or Right ?
    //
    if ( gMouseX <  graphWidth()/4 && gMouseX > 0 ) {
      toModify = FREQ_LEFT;
    } else if (  graphWidth() - gMouseX <  graphWidth()/4 ) {
      toModify = FREQ_RIGHT;
    }
  }

  // Middle of graph on X and Y is for zoom
  //
  if ( abs( gMouseX - graphWidth()/2 ) < graphWidth()/4  && abs( gMouseY - graphHeight()/2 ) < graphHeight()/4 )
    toModify = GRAPH_ZOOM ;


  tmpFreq = 0;
  if (toModify > 0   ) {
    infoText1X = min( max( graphX() +90, mouseX), graphWidth() + 140 ) ;
    infoText1Y = max( graphY() +40, mouseY );
  }
  if ( glb_stopFreq - glb_startFreq > 50000000 ) freqStep = 10000000;
  else freqStep = 1000000;

  switch ( toModify ) {

  // GAIN ====================
  //
  case  GAIN_LOW:
    tmpGain = (( parseInt(cp5.get(Textfield.class, "scaleMinText").getText()) ) - event.getCount()) ;
    if (tmpGain < glb_fullScaleMin ) tmpGain = glb_fullScaleMin;
    if (tmpGain > glb_fullScaleMax ) tmpGain = glb_fullScaleMax-1;
    if (tmpGain >= scaleMax ) tmpGain = scaleMax - 1;
    cp5.get(Textfield.class, "scaleMinText").setText(strArj(tmpGain));
    infoText = strArj(tmpGain)  + " db" ;
    itemToSet = ITEM_GAIN;
    infoLineY = getGraphYfromDb( tmpGain  );

    timeToSet = TIME_UNTIL_SET;
    break;

  case  GAIN_HIGH:
    tmpGain = (( parseInt(cp5.get(Textfield.class, "scaleMaxText").getText()) ) - event.getCount()) ;
    if (tmpGain < glb_fullScaleMin ) tmpGain = glb_fullScaleMin + 1;
    if (tmpGain > glb_fullScaleMax ) tmpGain = glb_fullScaleMax;
    if (tmpGain <= scaleMin ) tmpGain = scaleMin + 1;
    cp5.get(Textfield.class, "scaleMaxText").setText(strArj(tmpGain));
    itemToSet = ITEM_GAIN;
    infoText = strArj(tmpGain)   + " db" ;
    infoLineY = getGraphYfromDb( tmpGain  );

    timeToSet = TIME_UNTIL_SET;
    break;

  // FREQUENCY ===================
  //
  case  FREQ_LEFT:
    tmpFreq = (( parseInt(cp5.get(Textfield.class, "startFreqText").getText()) /freqStep ) - event.getCount() )  * freqStep ;
    if (tmpFreq < glb_fullRangeMin ) tmpFreq = glb_fullRangeMin;
    if (tmpFreq > glb_fullRangeMax ) tmpFreq = glb_fullRangeMax;
    if (tmpFreq >= glb_stopFreq ) tmpFreq = glb_stopFreq - 1000000;
    cp5.get(Textfield.class, "startFreqText").setText(strArj(tmpFreq));
    itemToSet = ITEM_FREQUENCY;
    infoText = strArj( ifCorrectedFreq(tmpFreq) / 1000000 )  + " MHz" ;
    infoLineX = getGraphXfromFreq( tmpFreq );
    timeToSet = TIME_UNTIL_SET;
    break;

  case  FREQ_RIGHT:
    tmpFreq = (( parseInt(cp5.get(Textfield.class, "stopFreqText").getText()) / freqStep) - event.getCount())  * freqStep;
    if (tmpFreq < glb_fullRangeMin ) tmpFreq = glb_fullRangeMin;
    if (tmpFreq > glb_fullRangeMax ) tmpFreq = glb_fullRangeMax;
    if (tmpFreq <= glb_startFreq ) tmpFreq = glb_startFreq + 1000000;
    cp5.get(Textfield.class, "stopFreqText").setText(strArj(tmpFreq));
    itemToSet = ITEM_FREQUENCY;
    infoText = strArj( ifCorrectedFreq( tmpFreq )/ 1000000 ) + " MHz";
    infoLineX = getGraphXfromFreq( tmpFreq );
    timeToSet = TIME_UNTIL_SET;
    break;

  case GRAPH_ZOOM:
    scaleFreqOverDb =  (glb_stopFreq - glb_startFreq) / (scaleMax - scaleMin) ;  // How many Hz for each db
    tmpGain  = min( max( (( parseInt(cp5.get(Textfield.class, "scaleMinText").getText()) ) - event.getCount()), glb_fullScaleMin), glb_fullScaleMax) ;
    tmpGain2 = max( min( (( parseInt(cp5.get(Textfield.class, "scaleMaxText").getText()) ) + event.getCount()), glb_fullScaleMax), glb_fullScaleMin) ;
    if ( tmpGain2 <= tmpGain ) tmpGain2 = tmpGain + 2;
    if ( tmpGain == glb_fullScaleMax ) {
      tmpGain = glb_fullScaleMax-1;
      tmpGain2=glb_fullScaleMax;
    }
    cp5.get(Textfield.class, "scaleMinText").setText(strArj(tmpGain));
    cp5.get(Textfield.class, "scaleMaxText").setText(strArj(tmpGain2));

    tmpFreq  = (long) min( max( Long.parseLong(cp5.get(Textfield.class, "startFreqText").getText()) - scaleFreqOverDb * event.getCount(), glb_fullRangeMin ), glb_fullRangeMax )  ; // TO_CHECK
    tmpFreq2 = (long) max( min( Long.parseLong(cp5.get(Textfield.class, "stopFreqText").getText())  + scaleFreqOverDb * event.getCount(), glb_fullRangeMax ), glb_fullRangeMin )  ; // TO_CHECK

    if (tmpFreq >= tmpFreq2) tmpFreq2 = tmpFreq + 10000000;

    cp5.get(Textfield.class, "startFreqText").setText(strArj(tmpFreq));
    cp5.get(Textfield.class, "stopFreqText").setText(strArj(tmpFreq2));

    if ( event.getCount() >0 ) infoText = "ZOOM OUT";
    else infoText="ZOOM IN";
    infoRectangle[0]= getGraphXfromFreq( tmpFreq );
    infoRectangle[1]= getGraphYfromDb( tmpGain);
    infoRectangle[2]= getGraphXfromFreq( tmpFreq2 ) - infoRectangle[0];
    infoRectangle[3]= ( getGraphYfromDb( tmpGain2) - infoRectangle[1]);

    itemToSet = ITEM_ZOOM;
    timeToSet = TIME_UNTIL_SET;
    break;
  }
  
}


String[] addElement(String[] original, String newElement) {
    // Create a new array with one more slot than the original array
    String[] newArray = new String[original.length + 1];
    
    // Copy all elements from the original array to the new array
    for (int i = 0; i < original.length; i++) {
        newArray[i] = original[i];
    }
    
    // Add the new element to the last position of the new array
    newArray[original.length] = newElement;
    
    return newArray;
}
