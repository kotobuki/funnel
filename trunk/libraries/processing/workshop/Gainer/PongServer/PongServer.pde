/*
  pong server
  Language:  Processing

  version 0002

  This program listens for TCP socket connections and uses the
  data from the incoming connections in a networked multiplayer
  version of pong.

  Version 2 fixes a bug with the delayCounter.  NEw lines are shown in bold below.

  Modified 12 Dec. 2008

  Modified by Shigeru Kobayashi
  for the workshop at Tokyo University of the Arts
*/

// include the net library:
import processing.net.*;

// variables for keeping track of clients:
int port = 5432;                        // the port the server listens on
Server myServer;                        // the server object
ArrayList playerList = new ArrayList(); // list of clients

// Variables for keeping track of the game play and graphics:

int ballSize = 10;             // the size of the ball
int ballDirectionV = 2;        // the ball's horizontal direction.
                               // left is negative, right is positive
int ballDirectionH = 2;        // the ball’s vertical direction.
                               // up is negative, down is positive
int ballPosV, ballPosH;        // the ball’s vertical/horizontal and vertical positions
boolean ballInMotion = false;  // whether or not the ball should be moving

int topScore, bottomScore;     // scores for the top team and the bottom teams
int paddleHeight = 10;         // vertical dimension of the paddles
int paddleWidth = 80;          // horizontal dimension of the paddles
int nextTopPaddleV;            // paddle positions for the next player
                               // to be created
int nextBottomPaddleV;

boolean gameOver = false;           // whether or not a game is in progress
long delayCounter;                  // a counter for the delay after
                                    // a game is over
long gameOverDelay = 4000;          // pause after each game
long pointDelay = 2000;             // pause after each point

boolean hasReported = false;

void setup()  {

  // initialize the delayCounter:
  delayCounter = millis();

  // set up all the pong details:
  pongSetup();
  // Start the server:
  myServer = new Server(this, port);
}

void pongSetup() {
  // set the window size:
  size(480, 640);
  // set the frame rate:
  frameRate(90);

  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 18);
  textFont(myFont);

  // set the default font settings:
  textFont(myFont, 18);
  textAlign(CENTER);

  // initalize paddle positions for the first player.
  // these will be incremented with each new player:
  nextTopPaddleV = 50;
  nextBottomPaddleV = height - 50;

  // initialize the ball in the center of the screen:
  ballPosV = height / 2;
  ballPosH = width / 2;

  // set no borders on drawn shapes:
  noStroke();
  // set the rectMode so that all rectangle dimensions
  // are from the center of the rectangle (see Processing reference):
  rectMode(CENTER);
}

void draw() {
  pongDraw();
  listenToClients();
}

// The ServerEvent message is generated when a new client
// connects to the server.
void serverEvent(Server someServer, Client someClient) {
  boolean isPlayer = false;

  if (someClient != null) {
    // iterate over the playerList:
    for (int p = 0; p < playerList.size(); p++) {
      // get the next object in the ArrayList and convert it
      // to a Player:
      Player thisPlayer = (Player)playerList.get(p);

      // if thisPlayer's client matches the one that generated
      // the serverEvent, then this client is already a player:
      if (thisPlayer.client == someClient) {
        // we already have this client
        isPlayer = true;
      }
    }

    // if the client isn't already a Player, then make a new Player
    // and add it to the playerList:
    if (!isPlayer) {
      makeNewPlayer(someClient);
    }
  }
}

void makeNewPlayer(Client thisClient) {
  // paddle position for the new Player:
  int h = width/2;
  int v = 0;
  boolean isTop = false;
/*
  Get the paddle position of the last player on the list.
   If it's on top, add the new player on the bottom, and vice versa.
   If there are  no other players, add the new player on the top.
*/
  // get the size of the list:
  int listSize = playerList.size() - 1;
  // if there are any other players:
  if  (listSize >= 0) {
    // get the last player on the list:
    Player lastPlayerAdded = (Player)playerList.get(listSize);
    // is the last player's on the top, add to the bottom:
    if (lastPlayerAdded.paddleV == nextTopPaddleV) {
      nextBottomPaddleV = nextBottomPaddleV - paddleHeight * 2;
      v = nextBottomPaddleV;
      isTop = false;
    }
    // is the last player's on the bottom, add to the top:
    else if (lastPlayerAdded.paddleV == nextBottomPaddleV) {
      nextTopPaddleV = nextTopPaddleV + paddleHeight * 2;
      v = nextTopPaddleV;
      isTop = true;
    }
  }
  // if there are no players, add to the top:
  else {
    v = nextTopPaddleV;
      isTop = true;
  }

  // make a new Player object with the position you just calculated
  // and using the Client that generated the serverEvent:
  Player newPlayer = new Player(h, v, thisClient, isTop);
  // add the new Player to the playerList:
  playerList.add(newPlayer);
  // Announce the new Player:
  print("We have a new player: ");
  println(newPlayer.client.ip());
  newPlayer.client.write("hi\r\n");
}

void listenToClients() {
  // get the next client that sends a message:
  Client speakingClient = myServer.available();
  Player speakingPlayer = null;

  // iterate over the playerList to figure out whose
  // client sent the message:
  for (int p = 0; p < playerList.size(); p++) {
    // get the next object in the ArrayList and convert it
    // to a Player:
    Player thisPlayer = (Player)playerList.get(p);
    // compare the client of thisPlayer to the client that sent a message.
    // If they're the same, then this is the Player we want:
    if (thisPlayer.client == speakingClient) {
      speakingPlayer = thisPlayer;
    }
  }

  // read what the client sent:
  if (speakingPlayer != null) {
    String readString = speakingPlayer.client.readString();
    String[] whatClientSaid = split(readString, "\r\n");
    for (int i = 0; i < whatClientSaid.length; i++) {
      if ((whatClientSaid[i] == null) || (whatClientSaid[i].length() < 1))  {
        continue;
      }

      /*
        There a number of things it might have said that we care about:
        x = exit
        l = move left
        r = move right
      */
      int command = whatClientSaid[i].charAt(0);
      switch (command) {
        // If the client says "exit", disconnect it
        case 'x':
          // say goodbye to the client:
          speakingPlayer.client.write("bye\r\n");
          // disconnect the client from the server:
          println(speakingPlayer.client.ip() + "\t left");
          myServer.disconnect(speakingPlayer.client);
          // remove the client's Player from the playerList:
          playerList.remove(speakingPlayer);
          break;
        case 'l':
          // if the client sends an "l", move the paddle left
          speakingPlayer.movePaddle(-10);
          break;
        case'r':
          // if the client sends a "r", move the paddle right
          speakingPlayer.movePaddle(10);
          break;
        default:
          {
            float position = float(whatClientSaid[i]);
            speakingPlayer.movePaddleTo(position);
          }
          break;
      }
    }
  }
}

void pongDraw() {
  background(0);
  // draw all the paddles
  for (int p = 0; p < playerList.size(); p++) {
    Player thisPlayer = (Player)playerList.get(p);
    // show the paddle for this player:
    thisPlayer.showPaddle();
  }

  // calculate ball's position:
  if (ballInMotion) {
    moveBall();
  }
  // Draw the ball:
  rect(ballPosH, ballPosV, ballSize, ballSize);

  // show the score:
  showScore();

  // if the game is over, show the winner:
  if (gameOver) {
    textSize(24);
    gameOver = true;
    text("Game Over", width/2, height/2 - 30);
    if (topScore > bottomScore) {
      text("Top Team Wins!", width/2, height/2);
      if (!hasReported) {
        for (int p = 0; p < playerList.size(); p++) {
          // get the player to check:
          Player thisPlayer = (Player)playerList.get(p);
          if (thisPlayer.isTop) {
            thisPlayer.client.write("win\r\n");
          } else {
            thisPlayer.client.write("lose\r\n");
          }
        }
        hasReported = true;
      }
    }
    else {
      text("Bottom Team Wins!", width/2, height/2);
      if (!hasReported) {
        for (int p = 0; p < playerList.size(); p++) {
          Player thisPlayer = (Player)playerList.get(p);
          if (!thisPlayer.isTop) {
            thisPlayer.client.write("win\r\n");
          } else {
            thisPlayer.client.write("lose\r\n");
          }
        }
      }
      hasReported = true;
    }
  }
  // pause after each game:
  if (gameOver && (millis() > delayCounter + gameOverDelay)) {
    gameOver = false;
    hasReported = false;
    newGame();
  }
  // pause after each point:
  if (!gameOver && !ballInMotion && (millis() > delayCounter + pointDelay)) {
    // make sure there are at least two players:
    if (playerList.size() >=2) {
      ballInMotion = true;
    }
    else {
      ballInMotion = false;
      textSize(24);
      text("Waiting for two players", width/2, height/2 - 30);
    }
  }
}

void moveBall() {
  // Check to see if the ball contacts any paddles:
  for (int p = 0; p < playerList.size(); p++) {
    // get the player to check:
    Player thisPlayer = (Player)playerList.get(p);

    // calculate the horizontal edges of the paddle:
    float paddleRight = thisPlayer.paddleH + paddleWidth/2;
    float paddleLeft = thisPlayer.paddleH - paddleWidth/2;
    // check to see if the ball is in the horizontal range of the paddle:
    if ((ballPosH >= paddleLeft) && (ballPosH <= paddleRight)) {

      // calculate the vertical edges of the paddle:
      float paddleTop = thisPlayer.paddleV - paddleHeight/2;
      float paddleBottom = thisPlayer.paddleV + paddleHeight/2;

      // check to see if the ball is in the
      // horizontal range of the paddle:
      if ((ballPosV >= paddleTop) && (ballPosV <= paddleBottom)) {
        // reverse the ball vertical direction:
        ballDirectionV = -ballDirectionV;
        thisPlayer.client.write("hit\r\n");
      }
    }
  }

  // if the ball goes off the screen top:
  if (ballPosV < 0) {
    bottomScore++;
    ballDirectionV = int(random(2) + 1) * -1;
    resetBall();
  }
  // if the ball goes off the screen bottom:
  if (ballPosV > height) {
    topScore++;
    ballDirectionV = int(random(2) + 1);
    resetBall();
  }

  // if any team goes over 5 points, the other team loses:
  if ((topScore > 5) || (bottomScore > 5)) {
    delayCounter = millis();
    gameOver = true;
  }

  // stop the ball going off the left or right of the screen:
  if ((ballPosH - ballSize/2 <= 0) || (ballPosH +ballSize/2 >=width)) {
    // reverse the y direction of the ball:
    ballDirectionH = -ballDirectionH;
  }
  // update the ball position:
  ballPosV = ballPosV + ballDirectionV;
  ballPosH = ballPosH + ballDirectionH;
}

void newGame() {
  gameOver = false;
  topScore = 0;
  bottomScore = 0;
}

public void showScore() {
  textSize(24);
  text(topScore, 20, 40);
  text(bottomScore, 20, height - 20);
}

void resetBall() {
  // put the ball back in the center
  ballPosV = height/2;
  ballPosH = width/2;
  ballInMotion = false;
  delayCounter = millis();
}

public class Player {
  // declare variables that belong to the object:
  float paddleH, paddleV;
  Client  client;
  boolean isTop;

  public Player (int hpos, int vpos, Client someClient, boolean top) {
    // initialize the localinstance variables:
    paddleH = hpos;
    paddleV = vpos;
    client = someClient;
    isTop = top;
    println("top: " + isTop);
  }

  public void movePaddle(float howMuch) {
    float newPosition = paddleH + howMuch;
    // constrain the paddle’s position to the width of the window:
    paddleH = constrain(newPosition, 0, width);
  }

  public void movePaddleTo(float to) {
    float newPosition = to * width;
    // constrain the paddle’s position to the width of the window:
    paddleH = constrain(newPosition, 0, width);
  }

  public void showPaddle() {
    rect(paddleH, paddleV, paddleWidth, paddleHeight);
    // display the address of this player near its paddle
    textSize(12);
    text(client.ip(), paddleH, paddleV - paddleWidth/8 );
  }
}
