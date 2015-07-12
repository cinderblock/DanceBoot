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

.def regTemp = r0

/**
 * Value meanings
 * 0x01 == NextIsProximal
 * 0x02 == NextIsDistal
 */
.def regDirectionDetect = r3


.def regArgument = r3

.def regAddress = r4