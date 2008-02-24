#include <m8c.h>        // part specific constants and macros

BOOL HasPacketToHandle(void);
void ClearHasPacketFlag(void);
void ParsePacket(void);

void ReportIOStatus(WORD ioEnable, WORD dioStatus, WORD *adcStatus, BYTE adcChannels);
void SendTransmitRequest(WORD destAddress, BYTE rfDataLength);
void SendCommand(BYTE frameDataLength);
