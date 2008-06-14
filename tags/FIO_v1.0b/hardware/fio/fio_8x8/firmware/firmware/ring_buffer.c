/*
 * リングバッファ(FIFO)を表現するCソース
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
 * リングバッファを初期化します。
 * 
 * @param buffer 初期化するリングバッファ
 * @param c 実際にバッファとして機能する領域
 * @param size 実際のバッファサイズ、cの大きさ
 * @return (rbuffer_t) 初期化されたリングバッファ
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
 * リングバッファにデータを書き込みます。
 * 
 * @param buffer 書き込む対象リングバッファ
 * @param data 書き込むデータ
 * @param size 書き込むデータのサイズ(byte)
 * @return int 正常に書き込まれたデータのサイズ(byte)
 */
int rbuffer_write(rbuffer_t *buffer, char *data, int size){
	
	int _size = 0;
	
	if(data != NULL){
	
		/* バッファに書き込み */
		while(_size < size){
			
			if(buffer->prius == buffer->buffer + buffer->size){buffer->prius = buffer->buffer;}
			if(buffer->prius == buffer->follower){break;}
			*((buffer->prius)++) = *(data + (_size++));
		}
	}
	
	return _size;
}

/**
 * リングバッファからデータを読み取ります。
 * 
 * @param buffer 読み込み元となるリングバッファ
 * @param c 読み取ったデータを格納するバッファ
 * @param size 最大読み込みサイズ(byte)
 * @return int 読み取ったデータの大きさ(byte)
 */
int rbuffer_read(rbuffer_t *buffer, char *c, int size){
	
	int _size = 0;
	
	if(c != NULL){
	
		/* 読込先に書き込み */
		while(_size < size){
		
			if((buffer->follower + 1 - buffer->prius) % buffer->size == 0){break;}
			if(++buffer->follower == buffer->buffer + buffer->size){buffer->follower = buffer->buffer;}
			*(c + (_size++)) = *(buffer->follower);
		}
	}
	
	return _size;
}

/**
 * リングバッファ上にあるデータサイズを求めます。
 * 
 * @param buffer リングバッファ
 * @return int バッファ上のデータの大きさ(byte)
 */
int rbuffer_size(rbuffer_t *buffer){
	
	return (buffer->prius > buffer->follower ?
		       buffer->prius - buffer->follower - 1:
		       buffer->prius + buffer->size - buffer->follower - 1);
}
