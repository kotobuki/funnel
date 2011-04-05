/*
Mode7 
Matrix LED(BU5004) control
--------------------------------------------
              | pin  |                | pin |
ain0 -> (ROW1)| 16   | aout0 -> (COL1)| 7   |
ain1 -> (ROW2)| 1    | aout1 -> (COL2)| 4   |
ain2 -> (ROW3)| 16   | aout2 -> (COL3)| 3   |
ain3 -> (ROW4)| 13   | aout3 -> (COL4)| 2   |
din0 -> (ROW5)| 5    | dout0 -> (COL5)| 10  |
din1 -> (ROW6)| 6    | dout1 -> (COL6)| 11  |
din2 -> (ROW7)| 9    | dout2 -> (COL7)| 12  |
din3 -> (ROW8)| 8    | dout3 -> (COL8)| 15  |
-----------------------------------------------
*/

import processing.funnel.*;

Gainer gainer;
int countup;

void setup()
{
  size(200, 200);
  gainer= new Gainer(this, Gainer.MODE7);
  frameRate(15);
}

void draw()
{
  countup %= 64;
  if(countup==0){
    for(int i=0;i<64;i++)
    gainer.analogOutput(i).value = 0.0;
  }
  gainer.analogOutput(countup).value = 1.0;
  countup++;
}

//void mousePressed()
//{
//    for(int i=0;i<64;i++)
//    gainer.analogOutput(i).value = 1.0;
//}
//
//void mouseReleased()
//{
//    for(int i=0;i<64;i++)
//    gainer.analogOutput(i).value = 0.0;
//}

