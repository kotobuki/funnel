/**
 * Gainer Kaidan Mini
 * 
 * by Shigeru Kobayashi for "Make: Tokyo Meeting"
 * inputs: photocells
 * outputs: solenoids via SSR modules
 */

import processing.funnel.*;

Gainer gio;
Delay[] delayLine;
boolean[] interrupted;

void setup()
{
  // Set the frame rate high to control in draw()
  // �o�͂̃R���g���[����draw()���ōs���֌W�Ńt���[�����[�g�����߂ɐݒ肷��
  frameRate(50);

  // Use mode 4: 8 analog inputs and 8 analog outputs
  // �A�i���O����8�A�A�i���O�o��8�𗘗p�ł��郂�[�h4���g�p����
  gio = new Gainer(this, Gainer.MODE4);

  // A worksround to enable delay() in setup()
  // Processing�̎d�l��setup()���ł�delay()���g���Ȃ��̂ɑ΂�������
  frameCount = 1;

  // Wait for a while to measure baseline levels
  // ��莞�ԑ҂��Ă��̊Ԃ̊e���̓|�[�g�̒l���x�[�X���C���Ƃ��ėp����
  println("waiting...");
  delay(1000);
  println("done!");

  // Instantiate 8 pairs of a flag and a Delay
  // �X�e�b�v�𓥂܂ꂽ���ǂ����̃t���O�ƃf�B���C�̃C���X�^���X�𐶐�
  interrupted = new boolean[8];
  delayLine = new Delay[8];

  for (int i = 0; i < 8; i++) {
    // Read an average value of the input port
    // �e�|�[�g�̕��ϒl��ǂݎ��
    println("avg[" + i + "]: " + gio.analogInput(i).average);

    // Set a threshold according to the average value,
    // then set a SetPoint filter to the input port
    // ��������ɂ������l��ݒ肵�ăt�B���^�Ƃ��Ċe�|�[�g�ɃZ�b�g����
    Filter[] f = {
      new SetPoint(gio.analogInput(i).average - 0.1, 0.05)
    };
    gio.analogInput(i).filters = f;

    // Initialize flags and Delay objects
    // �t���O�ƃf�B���C��������
    interrupted[i] = false;
    delayLine[i] = new Delay(25);
  }
}

void draw()
{
  for (int i = 0; i < 8; i++) {
    // Read from the delay line
    // �f�B���C����l�����o��
    gio.analogOutput(i).value = delayLine[i].getOutput();

    if (interrupted[i]) {
      // If the step is stepped, put 1 to the delay line
      // �����X�e�b�v�𓥂܂�Ă�����f�B���C��1����͂���
      delayLine[i].setInput(1);

      // Overwrite the output port with 1
      // �o�͂���l��1�ŏ㏑������
      gio.analogOutput(i).value = 1.0;
      
      // Clear the flag
      // �X�e�b�v�𓥂܂ꂽ���Ƃ������t���O���N���A����
      interrupted[i] = false;
    } else {
      // If the step is not stepped, put 0 to the delay line
      // �����X�e�b�v�𓥂܂�Ă��Ȃ���΃f�B���C��0����͂���
      delayLine[i].setInput(0);
    }
  }

  // Update all output ports at once
  // ���ׂẴ|�[�g�̏�Ԃ��܂Ƃ߂ďo�͂���
  gio.update();  
}

// The event handler to handle falling edge (from non zero to 0) events
// 1��0�ɕω������Ƃ��ɌĂ΂��C�x���g�n���h��
void fallingEdge(PortEvent e)
{
  switch (e.target.number) {
  case 0:
  case 1:
  case 2:
  case 3:
  case 4:
  case 5:
  case 6:
  case 7:
    // Set the according flag to true
    // �Ή�����t���O���Z�b�g����
    interrupted[e.target.number] = true;
    break;

  default:
    break;
  }
}
