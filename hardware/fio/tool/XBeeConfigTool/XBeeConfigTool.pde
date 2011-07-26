/*
  XBee Configuration Tool
  
  This sketch allows for the limited confuguration of XBee series 1 radios.
  It configures the radios for use with the Arduino Fio, either as a programming
  radio, or as a radio to put on a remote Arduino Fio unit.
  
  The program configures the following parameters of an XBee series 1 radio:
  BD -  4 (Atmega168) or  6 (Atmega328)
  ID - 1234 or  user's preference
  MY - 0000 (programmer), 0001 (Fio) or  user's preference
  DL - FFFF(programmer), 0001 (Fio)  or  user's preference
  D3 - 3 (programmer) or  5 (Fio)
  IC - 8  (programmer) or  not set (Fio)
  RR - 3 (programmer) or not set (Fio)
  IU - not set (programmer) or  0 (Fio)
  IA - not set (programmer) or  FFFF (Fio)
  RO - 10 (both)

  created
  by Shigeru Kobayashi

  modified 27 Mar 2010
  by Tom Igoe

*/

import processing.serial.*;
import interfascia.*;

final int COORDINATOR = 0;
final int END_DEVICES = 1;

final int BAUDRATE_19200 = 4;
final int BAUDRATE_57600 = 6;

GUIController gui;
IFRadioController portRadioButtons;
IFLookAndFeel arduinoLook;
IFLabel l;

IFRadioButton[] b;

IFLabel idLabel;
IFLabel myLabel;
IFLabel dlLabel;
IFTextField idTextField;
IFTextField myTextField;
IFTextField dlTextField;

IFRadioController modeRadioButtons;
IFLabel modeButtonsLabel;
IFRadioButton[] modeButton;

IFRadioController baudRateRadioButtons;
IFLabel baudRateButtonsLabel;
IFRadioButton[] baudRateButton;

IFButton configureButton;
IFButton exitButton;
IFButton readButton;

IFLabel statusTextLabel;

IFLabel statusBaudRate;
IFLabel statusSerialNumberHigh;
IFLabel statusSerialNumberLow;
IFLabel statusFirmwareVersion;
int baudRate;

Serial serialPort;

final String[] AT_COMMANDS = {
  "BD", "ID", "MY", "DL", "D3", "IC", "IU", "IA"};

final String[] AT_READ = {   // commands sent to read xbee data
  "BD", "ID", "MY", "DL", "SH", "SL", "VR"};

final String[] BAUD_RATES = {
  "1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"};

final String[] BAUD_RATES_FOR_CONFIG = {
  "9600", "19200", "38400", "57600", "115200", "1200", "2400", "4800"};

final int SUPPORTED_FIRMWARE_VERSION = 0x10A5;

void setup() {
  size(500, 500);
  background(255);

  int y = 20;

  gui = new GUIController(this);
  arduinoLook = new IFLookAndFeel(this, IFLookAndFeel.DEFAULT);
  arduinoLook.baseColor = color(104,165,178);
 //  arduinoLook.lightGrayColor = color(33,104,134);
  arduinoLook.highlightColor = color(84,145,158);
  arduinoLook.activeColor = color(33,104,134);
  arduinoLook.selectionColor = color(33,104,134);
  gui.setLookAndFeel(arduinoLook);
  portRadioButtons = new IFRadioController("Mode Selector");
  l = new IFLabel("Serial Port", 20, y, 12);
  gui.add(l);

  String[] portList = Serial.list();

  y += 14;
  b = new IFRadioButton[portList.length];
  for (int i = 0; i < portList.length; i++) {
    if (portList[i].startsWith("/dev") && portList[i].startsWith("/dev/tty")) {
      // Don't display tty devices to save space and simplify
      // NOTE: OS X only
      continue;
    }
    b[i] = new IFRadioButton(portList[i], 20, y, portRadioButtons);
    gui.add(b[i]);
    y += 20;
  }

  y += 20;
  modeRadioButtons = new IFRadioController("Mode Selector");
  modeRadioButtons.addActionListener(this);
  modeButtonsLabel = new IFLabel("Mode", 20, y, 12);
  gui.add(modeButtonsLabel);
  y += 14;
  modeButton = new IFRadioButton[2];
  modeButton[0] = new IFRadioButton("Programming radio", 20, y, modeRadioButtons);
  gui.add(modeButton[0]);
  y += 20;
  modeButton[1] = new IFRadioButton("Arduino Fio radio", 20, y, modeRadioButtons);
  gui.add(modeButton[1]);

  y += 38;
  baudRateRadioButtons = new IFRadioController("Baud Rate Selector");
  baudRateRadioButtons.addActionListener(this);
  baudRateButtonsLabel = new IFLabel("Baud rate", 20, y, 12);
  gui.add(baudRateButtonsLabel);
  y += 14;
  baudRateButton = new IFRadioButton[2];
  baudRateButton[0] = new IFRadioButton("19200 (for ATmega168)", 20, y, baudRateRadioButtons);
  gui.add(baudRateButton[0]);
  y += 20;
  baudRateButton[1] = new IFRadioButton("57600 (for ATmega328)", 20, y, baudRateRadioButtons);
  gui.add(baudRateButton[1]);

  y += 38;
  idLabel = new IFLabel ("PAN ID", 20, y);
  gui.add(idLabel);
  y += 14;
  idTextField = new IFTextField("ID", 20, y, 60, "1234");
  gui.add(idTextField);
  y += 32;
  myLabel = new IFLabel ("MY ID", 20, y);
  gui.add(myLabel);
  y += 14;
  myTextField = new IFTextField("MY", 20, y, 60, "0000");
  gui.add(myTextField);

  y -= 14;
  dlLabel = new IFLabel ("DL ID", 100, y);
  gui.add(dlLabel);
  y += 14;
  dlTextField = new IFTextField("DL", 100, y, 60, "FFFF");
  gui.add(dlTextField);
  
  y += 38;
  configureButton = new IFButton("Configure", 20, y, 80, 20);
  configureButton.addActionListener(this);
  gui.add(configureButton);
  readButton = new IFButton("Read", 108, y, 80, 20);
  readButton.addActionListener(this);
  gui.add(readButton);
  exitButton = new IFButton("Exit", 196, y, 80, 20);
  exitButton.addActionListener(this);
  gui.add(exitButton);

  y += 38;
  statusTextLabel = new IFLabel("", 20, y, 12);
  gui.add(statusTextLabel);

  y = 20;
  statusBaudRate = new IFLabel("", 250, y, 12);
  gui.add(statusBaudRate);

  y += 32;
  statusSerialNumberHigh = new IFLabel("", 250, y, 12);
  gui.add(statusSerialNumberHigh);

  y += 16;
  statusSerialNumberLow = new IFLabel("", 250, y, 12);
  gui.add(statusSerialNumberLow);

  y += 32;
  statusFirmwareVersion = new IFLabel("", 250, y, 12);
  gui.add(statusFirmwareVersion);
}

void draw() {
  background(255);
}

void actionPerformed(GUIEvent e) {
  if (e.getSource() == configureButton) {
    statusTextLabel.setLabel("Configuring...");
    configureXBeeModem();
  }
  else if (e.getSource() == readButton) {
    statusTextLabel.setLabel("Reading  ...");
    readSettingsFromXBeeModem();
  }
  else if (e.getSource() == exitButton) {
    exit();
  }
  else if (e.getSource() == modeButton[0]) {
    myTextField.setValue("0000");
    // myLabel.setX(width);
    // myTextField.setX(width);
    
    dlTextField.setValue("FFFF");
    // dlLabel.setX(width);
    // dlTextField.setX(width);
  }
  else if (e.getSource() == modeButton[1]) {
    if (Integer.parseInt(myTextField.getValue(), 16) == 0) {
      myTextField.setValue("0001");
    }
    myLabel.setX(20);
    myTextField.setX(20);
    
    if (Integer.parseInt(dlTextField.getValue(), 16) == 0xFFFF) {
      dlTextField.setValue("0000");
    }
    dlLabel.setX(100);
    dlTextField.setX(100);
  }
  else if (e.getSource() == baudRateButton[0]) {
    baudRate = BAUDRATE_19200;
  }
  else if (e.getSource() == baudRateButton[1]) {
    baudRate = BAUDRATE_57600;    
  }
}

void configureXBeeModem() {
  if (portRadioButtons.getSelectedIndex() < 0) {
    statusTextLabel.setLabel("Please select a proper serial port.");
    return;
  }

  if (modeRadioButtons.getSelectedIndex() < 0) {
    statusTextLabel.setLabel("Please select a proper mode.");
    return;
  }

  if (baudRateRadioButtons.getSelectedIndex() < 0) {
    statusTextLabel.setLabel("Please select a proper baud rate.");
    return;
  }

  int id = Integer.parseInt(idTextField.getValue(), 16);
  int my = Integer.parseInt(myTextField.getValue(), 16);
  int dl = Integer.parseInt(dlTextField.getValue(), 16);

  if (id < 0 || id > 0xFFFE) {
    statusTextLabel.setLabel("ID should be between 0 to FFFE.");
    return;
  }

  if (my < 0 || my > 0xFFFE) {
    statusTextLabel.setLabel("MY should be between 0 to FFFE.");
    return;
  }

  if (dl < 0 || dl > 0xFFFF) {
    statusTextLabel.setLabel("DL should be between 0 to FFFF.");
    return;
  }
  statusTextLabel.setLabel("Entering command mode...");

  String portName = portRadioButtons.getSelected().getLabel();
  if (!enterCommandMode(portName)) {
    statusTextLabel.setLabel("Can't enter command mode.");
    return;
  }
  statusTextLabel.setLabel("Entered command mode.");

  String reply = getReplyFromXBeeModemFor("VR");
  int firmwareVersion = Integer.parseInt(reply, 16);

  if (firmwareVersion < SUPPORTED_FIRMWARE_VERSION) {
    String errorMessage = "Please update the modem firmware with X-CTU to 10A5 or later\n";
    statusTextLabel.setLabel(errorMessage);
    exitCommandMode();
    return;
  }

  int mode = modeRadioButtons.getSelectedIndex();
       
  switch (mode) {
  case COORDINATOR:
    serialPort.write("ATRE\r");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't reset.");
      return;
    }

    serialPort.write("ATBD" + baudRate + ",");
    serialPort.write("ID" + Integer.toString(id, 16) + ",");
    serialPort.write("MY" + Integer.toString(my, 16) + ",");
    serialPort.write("DL" + Integer.toString(dl, 16) + ",");
    serialPort.write("D33,IC8,RR3,RO10,WR\r");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't configure.");
      return;
    }
    break;
  case END_DEVICES:
    serialPort.write("ATRE\r");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't reset.");
      return;
    }

    serialPort.write("ATBD" + baudRate + ",");
    serialPort.write("ID" + Integer.toString(id, 16) + ",");
    serialPort.write("MY" + Integer.toString(my, 16) + ",");
    serialPort.write("DL" + Integer.toString(dl, 16) + ",");
    serialPort.write("D35,IU0,IAFFFF,RO10,WR\r");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't configure.");
      return;
    }
    break;
  }

  if (!exitCommandMode()) {
    statusTextLabel.setLabel("Can't exit command mode.");
    return;
  }

  statusTextLabel.setLabel("Configured successfully.");
}

void readSettingsFromXBeeModem() {
  if (portRadioButtons.getSelectedIndex() < 0) {
    statusTextLabel.setLabel("Please select a proper serial port.");
    return;
  }

  String portName = portRadioButtons.getSelected().getLabel();
  if (!enterCommandMode(portName)) {
    statusTextLabel.setLabel("Can't enter command mode.");
    return;
  }
  statusTextLabel.setLabel("Entered command mode.");

  for (int i = 0; i < AT_READ.length; i++) {
    String reply = getReplyFromXBeeModemFor(AT_READ[i]);
    showSetting(i, reply);
  }

  if (!exitCommandMode()) {
    statusTextLabel.setLabel("Can't exit command mode.");
    return;
  }

  statusTextLabel.setLabel("Read settings successfully.");
}

void showSetting(int command, String reply) {
  switch(command){
  case 0: // Baud Rate
    statusBaudRate.setLabel("Baud rate: " + BAUD_RATES[Integer.parseInt(reply)]);
    if (Integer.parseInt(reply) == BAUDRATE_19200) {
      baudRateRadioButtons.selectButton(baudRateButton[0]);
    } else if (Integer.parseInt(reply) == BAUDRATE_57600) {
      baudRateRadioButtons.selectButton(baudRateButton[1]);
    } else {
      baudRateRadioButtons.deselectAll();
    }
    break;
  case 1: // ID
    idTextField.setValue(reply);
    break;
  case 2: // MY ID
    myTextField.setValue(reply);
    break;
  case 3: // DL
    break;
  case 4: // SH
    statusSerialNumberHigh.setLabel("S/N high: " + reply);
    break;
  case 5: // SL
    statusSerialNumberLow.setLabel("S/N low: " + reply);
    break;
  case 6: // VR
    statusFirmwareVersion.setLabel("Firmware: " + reply);
  }
}

boolean gotOkayFromXBeeModem() {
  delay(100);

  for (int i = 0; i < 20; i++) {
    if (serialPort.available() >= 3) {
      break;
    }
    delay(50);
  }

  String reply = serialPort.readStringUntil(13);
  if (reply == null || !reply.equals("OK\r")) {
    return false;
  }

  return true;
}

String getReplyFromXBeeModemFor(String atCommand) {
  serialPort.write("AT" + atCommand + "\r");
  delay(50);
  String reply = serialPort.readStringUntil(13);
  return reply.substring(0, reply.length() - 1);
}

boolean enterCommandMode(String portName) {
  boolean enteredSuccessfully = false;

  for (int i = 0; i < BAUD_RATES_FOR_CONFIG.length; i++) {
    if (serialPort != null) {
      serialPort.stop();
      serialPort = null;
    }

    serialPort = new Serial(this, portName, Integer.parseInt(BAUD_RATES_FOR_CONFIG[i]));
    serialPort.clear();
    serialPort.write("+++");
    delay(500);

    if (gotOkayFromXBeeModem()) {
      enteredSuccessfully = true;
      println("opened " + portName + " at " + BAUD_RATES_FOR_CONFIG[i]);
      break;
    }
  }

  return enteredSuccessfully;
}

boolean exitCommandMode() {
  serialPort.write("ATCN\r");
  return gotOkayFromXBeeModem();
}
