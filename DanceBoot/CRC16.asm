/*
 * CRC16.asm
 *
 *  Created: 2015-07-14 1:50:46 AM
 *   Author: Cameron
 */ 

/**
 * CRC16. Copied from <util/crc16.h>
 *
 * The program SRP16 verifies these CRC values
 *  Poly   = 0x8005
 *  init   = 0xffff
 *  xorout = 0x0000
 *  refin  = true
 *  refout = true
 *
 * Usage 1: rcall CRC_FromTemp
 * 
 * Input: regTemp
 * Result: regCRCLow/regCRCHigh
 * Mangles: regCRCTempA, regCRCTempB
 *
 * Usage 2:
 *   eor	regCRCLow, InputRegister
 *   rcall	CRC_WithEOR
 */
CRC_FromTemp:
eor		regCRCLow,		regTemp
CRC_WithEOR:
mov		regCRCTempB,	regCRCLow
swap	regCRCTempB
eor		regCRCTempB,	regCRCLow
mov		regCRCTempA,	regCRCTempB
lsr		regCRCTempB
lsr		regCRCTempB
eor		regCRCTempB,	regCRCTempA
mov		regCRCTempA,	regCRCTempB
lsr		regCRCTempB
eor		regCRCTempB,	regCRCTempA
andi	regCRCTempB,	0x07
mov		regCRCTempA,	regCRCLow
mov		regCRCLow,		regCRCHigh
lsr		regCRCTempB
ror		regCRCTempA
ror		regCRCTempB
mov		regCRCHigh,		regCRCTempA
eor		regCRCLow,		regCRCTempB
lsr		regCRCTempA
ror		regCRCTempB
eor		regCRCHigh,		regCRCTempA
eor		regCRCLow,		regCRCTempB
ret
