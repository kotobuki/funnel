#ifndef FIO_C_HEADER
#define FIO_C_HEADER

/**
 * common I/O Pin Definitions
 */
#define GET_BUTTON() (PRT1DR&0x20)				// P1[5]

// NOTE: P1[5] is pull-downed, so should be always ZERO!!!
#define SET_LED_H() (PRT1DR=(PRT1DR&0xDF)|0x80)	// P1[7]
#define SET_LED_L() (PRT1DR&=0x5F)				// P1[7]

#define GET_DIN_0() (PRT0DR&0x40)	// P0[6]
#define GET_DIN_1() (PRT0DR&0x10)	// P0[4]
#define GET_DIN_2() (PRT0DR&0x04)	// P0[2]
#define GET_DIN_3() (PRT0DR&0x01)	// P0[0]
#define GET_DIN_4() (PRT0DR&0x80)	// P0[7]
#define GET_DIN_5() (PRT0DR&0x20)	// P0[5]
#define GET_DIN_6() (PRT0DR&0x08)	// P0[3]
#define GET_DIN_7() (PRT0DR&0x02)	// P0[1]

// NOTE: P1[5] is pull-downed, so should be always ZERO!!!
#define SET_DOUT_0_H() (PRT2DR|=0x01)				// P2[0]
#define SET_DOUT_1_H() (PRT1DR=(PRT1DR&0xDF)|0x40)	// P1[6]
#define SET_DOUT_2_H() (PRT1DR=(PRT1DR&0xDF)|0x10)	// P1[4]
#define SET_DOUT_3_H() (PRT1DR=(PRT1DR&0xDF)|0x04)	// P1[2]
#define SET_DOUT_4_H() (PRT2DR|=0x80)				// P2[7]
#define SET_DOUT_5_H() (PRT2DR|=0x20)				// P2[5]
#define SET_DOUT_6_H() (PRT2DR|=0x08)				// P2[3]
#define SET_DOUT_7_H() (PRT2DR|=0x02)				// P2[1]

// NOTE: P1[5]  is pull-downed, so should be always ZERO!!!
#define SET_DOUT_0_L() (PRT2DR&=0xFE)	// P2[0]
#define SET_DOUT_1_L() (PRT1DR&=0x9F)	// P1[6]
#define SET_DOUT_2_L() (PRT1DR&=0xCF)	// P1[4]
#define SET_DOUT_3_L() (PRT1DR&=0xDB)	// P1[2]
#define SET_DOUT_4_L() (PRT2DR&=0x7F)	// P2[7]
#define SET_DOUT_5_L() (PRT2DR&=0xDF)	// P2[5]
#define SET_DOUT_6_L() (PRT2DR&=0xF7)	// P2[3]
#define SET_DOUT_7_L() (PRT2DR&=0xFD)	// P2[1]

#endif
