/*
 * Ring BufferというFIFOを表現するヘッダファイル
 * ring_buffer.cがメインソース
 * 
 * @author fenrir (M.Naruoka)
 * @since 04/05/30
 * @version 1.0
 */

#ifndef __RING_BUFFER_H__
#define __RING_BUFFER_H__

typedef struct rbuffer_t{
	char *buffer;
	int size;
	char *prius;
	char *follower;
} rbuffer_t;
/* リングバッファルール
 * follower(追っかけ)はprius(先行者)に追いつくことはできないし、追い抜くこともできない
 * prius(先行者)はfollower(追っかけ)に追いつくことはできるが、追い抜くことはできない
 */

rbuffer_t *rbuffer_init(rbuffer_t *buffer, char *c, int size);
int rbuffer_write(rbuffer_t *buffer, char *data, int size);
int rbuffer_read(rbuffer_t *buffer, char *c, int size);
int rbuffer_size(rbuffer_t *buffer);

#endif /* __RING_BUFFER_H__ */
