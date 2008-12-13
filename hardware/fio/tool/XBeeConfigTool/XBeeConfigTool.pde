import processing.serial.*;
import interfascia.*;

final int COORDINATOR = 0;
final int END_DEVICES = 1;

GUIController gui;
IFRadioController portRadioButtons;
IFLabel l;

IFRadioButton[] b;

IFLabel idLabel;
IFLabel myLabel;
IFTextField idTextField;
IFTextField myTextField;

IFRadioController modeRadioButtons;
IFLabel modeButtonsLabel;
IFRadioButton[] modeButton;

IFButton configureButton;
IFButton exitButton;

IFLabel statusTextLabel;

Serial serialPort;

void setup() {
  size(400, 400);
  background(150);

  int y = 20;

  gui = new GUIController(this);
  portRadioButtons = new IFRadioController("Mode Selector");
  l = new IFLabel("Serial Port", 20, y, 12);
  gui.add(l);

  String[] portList = Serial.list();

  y += 14;
  b = new IFRadioButton[portList.length];
  for (int i = 0; i < portList.length; i++) {
    b[i] = new IFRadioButton(portList[i], 20, y, portRadioButtons);
    gui.add(b[i]);
    y += 20;
  }

  y += 8;
  idLabel = new IFLabel ("PAN ID", 20, y);
  gui.add(idLabel);
  y += 14;
  idTextField = new IFTextField("ID", 20, y, 60, "1234");
  gui.add(idTextField);
  y += 38;
  myLabel = new IFLabel ("MY ID", 20, y);
  gui.add(myLabel);
  y += 14;
  myTextField = new IFTextField("MY", 20, y, 60, "0000");
  gui.add(myTextField);
  y += 38;

  modeRadioButtons = new IFRadioController("Mode Selector");
  modeRadioButtons.addActionListener(this);
  modeButtonsLabel = new IFLabel("Mode", 20, y, 12);
  gui.add(modeButtonsLabel);
  y += 14;
  modeButton = new IFRadioButton[2];
  modeButton[0] = new IFRadioButton("Coordinator", 20, y, modeRadioButtons);
  //  modeButton[0].addActionListener(this);
  gui.add(modeButton[0]);
  y += 20;
  modeButton[1] = new IFRadioButton("End Devices", 20, y, modeRadioButtons);
  //  modeButton[1].addActionListener(this);
  gui.add(modeButton[1]);
  y += 20;

  y += 16;
  configureButton = new IFButton("Configure", 20, y, 80, 20);
  configureButton.addActionListener(this);
  gui.add(configureButton);
  exitButton = new IFButton("Exit", 108, y, 80, 20);
  exitButton.addActionListener(this);
  gui.add(exitButton);

  y += 38;
  statusTextLabel = new IFLabel("", 20, y, 12);
  gui.add(statusTextLabel);
}

void draw() {
  background(200);
}

void actionPerformed(GUIEvent e) {
  if (e.getSource() == configureButton) {
    configureXBeeModem();
  } 
  else if (e.getSource() == exitButton) {
    exit();
  }
  else if (e.getSource() == modeButton[0]) {
    myTextField.setValue("0000");
  }
  else if (e.getSource() == modeButton[1]) {
    if (Integer.parseInt(myTextField.getValue(), 16) == 0) {
      myTextField.setValue("0001");
    }
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

  int id = Integer.parseInt(idTextField.getValue(), 16);
  int my = Integer.parseInt(myTextField.getValue(), 16);

  if (id < 0 || id > 0xFFFE) {
    statusTextLabel.setLabel("ID should be between 0 to FFFE.");
    return;
  }

  if (my < 0 || my > 0xFFFE) {
    statusTextLabel.setLabel("MY should be between 0 to FFFE.");
    return;
  }

  statusTextLabel.setLabel("Entering command mode...");
  draw();

  if (serialPort != null) {
    serialPort.stop();
    serialPort = null;
  }
  String portName = portRadioButtons.getSelected().getLabel();
  serialPort = new Serial(this, portName, 9600);
  serialPort.write("+++");

  if (!gotOkayFromXBeeModem()) {
    serialPort.stop();
    serialPort = null;
    serialPort = new Serial(this, portName, 19200);
    serialPort.write("+++");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't enter command mode.");
      return;
    }
  }
  statusTextLabel.setLabel("Entered command mode.");

  int mode = modeRadioButtons.getSelectedIndex();

  switch (mode) {
  case COORDINATOR:
    serialPort.write("ATRE,BD4,");
    serialPort.write("ID" + Integer.toString(id, 16) + ",");
    serialPort.write("MY" + Integer.toString(my, 16) + ",");
    serialPort.write("DLFFFF,D33,IC8,WR\r");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't configure.");
      return;
    }
    break;
  case END_DEVICES:
    serialPort.write("ATRE,BD4,");
    serialPort.write("ID" + Integer.toString(id, 16) + ",");
    serialPort.write("MY" + Integer.toString(my, 16) + ",");
    serialPort.write("DL0,D35,IU0,IAFFFF,WR\r");
    if (!gotOkayFromXBeeModem()) {
      statusTextLabel.setLabel("Can't configure.");
      return;
    }
    break;
  }

  serialPort.write("ATCN\r");
  if (!gotOkayFromXBeeModem()) {
    statusTextLabel.setLabel("Can't exit command mode.");
    return;
  }

  statusTextLabel.setLabel("Configured successfully.");
}

boolean gotOkayFromXBeeModem() {
  for (int i = 0; i < 10; i++) {
    if (serialPort.available() >= 3) {
      break;
    }
    delay(200);
  }

  String reply = serialPort.readStringUntil(13);
  if (reply == null || !reply.equals("OK\r")) {
    return false;
  }

  return true;
}


