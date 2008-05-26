/*
 * Ring Buffer�Ƃ���FIFO��\������w�b�_�t�@�C��
 * ring_buffer.c�����C���\�[�X
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
/* �����O�o�b�t�@���[��
 * follower(�ǂ�����)��prius(��s��)�ɒǂ������Ƃ͂ł��Ȃ����A�ǂ��������Ƃ��ł��Ȃ�
 * prius(��s��)��follower(�ǂ�����)�ɒǂ������Ƃ͂ł��邪�A�ǂ��������Ƃ͂ł��Ȃ�
 */

rbuffer_t *rbuffer_init(rbuffer_t *buffer, char *c, int size);
int rbuffer_write(rbuffer_t *buffer, char *data, int size);
int rbuffer_read(rbuffer_t *buffer, char *c, int size);
int rbuffer_size(rbuffer_t *buffer);

#endif /* __RING_BUFFER_H__ */
