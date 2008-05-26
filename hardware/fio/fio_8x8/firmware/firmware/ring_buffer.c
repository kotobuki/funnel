/*
 * �����O�o�b�t�@(FIFO)��\������C�\�[�X
 * 
 * @author fenrir (M.Naruoka)
 * @since 04/05/30
 * @version 1.0
 */

#include "ring_buffer.h"

#ifndef NULL
	#define NULL 0
#endif

/**
 * �����O�o�b�t�@�����������܂��B
 * 
 * @param buffer ���������郊���O�o�b�t�@
 * @param c ���ۂɃo�b�t�@�Ƃ��ċ@�\����̈�
 * @param size ���ۂ̃o�b�t�@�T�C�Y�Ac�̑傫��
 * @return (rbuffer_t) ���������ꂽ�����O�o�b�t�@
 */
rbuffer_t *rbuffer_init(rbuffer_t *buffer, char *c, int size){
	
	if(size > 0){
		
		buffer->buffer = c;
		buffer->size = size;
		buffer->prius = buffer->buffer;	
		buffer->follower = buffer->buffer + size - 1;
		return buffer;
	}else{return NULL;}
}

/**
 * �����O�o�b�t�@�Ƀf�[�^���������݂܂��B
 * 
 * @param buffer �������ޑΏۃ����O�o�b�t�@
 * @param data �������ރf�[�^
 * @param size �������ރf�[�^�̃T�C�Y(byte)
 * @return int ����ɏ������܂ꂽ�f�[�^�̃T�C�Y(byte)
 */
int rbuffer_write(rbuffer_t *buffer, char *data, int size){
	
	int _size = 0;
	
	if(data != NULL){
	
		/* �o�b�t�@�ɏ������� */
		while(_size < size){
			
			if(buffer->prius == buffer->buffer + buffer->size){buffer->prius = buffer->buffer;}
			if(buffer->prius == buffer->follower){break;}
			*((buffer->prius)++) = *(data + (_size++));
		}
	}
	
	return _size;
}

/**
 * �����O�o�b�t�@����f�[�^��ǂݎ��܂��B
 * 
 * @param buffer �ǂݍ��݌��ƂȂ郊���O�o�b�t�@
 * @param c �ǂݎ�����f�[�^���i�[����o�b�t�@
 * @param size �ő�ǂݍ��݃T�C�Y(byte)
 * @return int �ǂݎ�����f�[�^�̑傫��(byte)
 */
int rbuffer_read(rbuffer_t *buffer, char *c, int size){
	
	int _size = 0;
	
	if(c != NULL){
	
		/* �Ǎ���ɏ������� */
		while(_size < size){
		
			if((buffer->follower + 1 - buffer->prius) % buffer->size == 0){break;}
			if(++buffer->follower == buffer->buffer + buffer->size){buffer->follower = buffer->buffer;}
			*(c + (_size++)) = *(buffer->follower);
		}
	}
	
	return _size;
}

/**
 * �����O�o�b�t�@��ɂ���f�[�^�T�C�Y�����߂܂��B
 * 
 * @param buffer �����O�o�b�t�@
 * @return int �o�b�t�@��̃f�[�^�̑傫��(byte)
 */
int rbuffer_size(rbuffer_t *buffer){
	
	return (buffer->prius > buffer->follower ?
		       buffer->prius - buffer->follower - 1:
		       buffer->prius + buffer->size - buffer->follower - 1);
}
