import processing.serial.*;
import interfascia.*;

final int COORDINATOR = 0;
final int END_DEVICES = 1;

GUIController gui;
IFRadioController portRadioButtons;
IFLabel l;

IFRadioButton[] b;

IFLabel txLabel;
IFLabel rxLabel;
IFTextField txTextField;
IFTextField rxTextField;

IFButton sendButton;
IFButton exitButton;

IFLabel statusTextLabel;

Serial serialPort;

final String[] BAUD_RATES = {
  "9600", "19200", "38400", "57600", "115200", "1200", "2400", "4800"};

void setup() {
  size(500, 400);
  background(150);

  int y = 20;

  gui = new GUIController(this);
  portRadioButtons = new IFRadioController("Port Selector");
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
  portRadioButtons.addActionListener(this);

  y += 16;
  txLabel = new IFLabel("Tx:", 20, y + 5);
  gui.add(txLabel);
  txTextField = new IFTextField("Tx", 40, y, 380, "");
  txTextField.addActionListener(this);
  gui.add(txTextField);
  sendButton = new IFButton("Send", 430, y + 2, 40, 16);
  sendButton.addActionListener(this);
  gui.add(sendButton);

  y += 32;
  rxLabel = new IFLabel("Rx:", 20, y + 5);
  gui.add(rxLabel);
  rxTextField = new IFTextField("Rx", 40, y, 380, "");
  rxTextField.addActionListener(this);
  gui.add(rxTextField);

  y += 48;
  statusTextLabel = new IFLabel("Please choose a serial port to send commands.", 20, y, 12);
  gui.add(statusTextLabel);

  y += 38;
  exitButton = new IFButton("Exit", 20, y, 40, 20);
  exitButton.addActionListener(this);
  gui.add(exitButton);
}

void draw() {
  background(200);
}

void actionPerformed(GUIEvent e) {
  if (e.getSource() == sendButton) {
    sendCommands();
  }
  else if (e.getSource() == exitButton) {
    exit();
  }
  else if (e.getSource() == txTextField) {
    if (e.getMessage().equals("Completed"))
      sendCommands();
  }
  else {
    for (int i = 0; i < b.length; i++) {
      if (e.getSource() == b[i])
        statusTextLabel.setLabel("Type commands and press the send button to send commands.");
    }
  }
}

void sendCommands() {
  statusTextLabel.setLabel("Entering command mode...");

  if (portRadioButtons.getSelected() == null) {
    return;    
  }

  String portName = portRadioButtons.getSelected().getLabel();

  if (!enterCommandMode(portName)) {
    statusTextLabel.setLabel("Can't enter command mode.");
    return;
  }
  statusTextLabel.setLabel("Entered command mode.");

  serialPort.write(txTextField.getValue() + "\r");

  for (int i = 0; i < 30; i++) {
    if (serialPort.available() >= 3)
      break;
    delay(50);
  }
  delay(500);

  String reply = serialPort.readString();

  if (reply != null) {
    rxTextField.setValue(reply);
    statusTextLabel.setLabel("Got reply from the XBee modem.");
  } 
  else {
    statusTextLabel.setLabel("Got no reply from the XBee modem.");
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

boolean enterCommandMode(String portName) {
  boolean enteredSuccessfully = false;

  for (int i = 0; i < BAUD_RATES.length; i++) {
    if (serialPort != null) {
      serialPort.stop();
      serialPort = null;
    }

    serialPort = new Serial(this, portName, Integer.parseInt(BAUD_RATES[i]));
    serialPort.clear();
    serialPort.write("+++");
    delay(500);

    if (gotOkayFromXBeeModem()) {
      enteredSuccessfully = true;
      println("opened " + portName + " at " + BAUD_RATES[i]);
      break;
    }
  }

  return enteredSuccessfully;
}

boolean exitCommandMode() {
  serialPort.write("ATCN\r");
  return gotOkayFromXBeeModem();
}

