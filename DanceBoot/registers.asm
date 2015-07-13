/*
 * registers.asm
 *
 *  Created: 2015-07-11 1:22:30 PM
 *   Author: Cameron
 */ 

.def regZero = r2


/**
 * Little Endian
 */
.def regCRCHigh = r16
.def regCRCLow  = r17

.def regTemp = r18

/**
 * Value meanings
 * 0x01 == NextIsProximal
 * 0x02 == NextIsDistal
 */
.def regDirectionDetect = r20


.def regArgument = r3

.def regAddress = r19