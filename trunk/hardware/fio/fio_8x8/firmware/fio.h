#ifndef FIO_C_HEADER
#define FIO_C_HEADER

/**
 * common I/O Pin Definitions
 */
#define GET_BUTTON() (PRT1DR&0x20)				// P1[5]

// NOTE: P1[5] is pull-downed, so should be always ZERO!!!
#define SET_LED_H() (PRT1DR=(PRT1DR&0xDF)|0x80)	// P1[7]
#define SET_LED_L() (PRT1DR&=0x5F)				// P1[7]

#endif
