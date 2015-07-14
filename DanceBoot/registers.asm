/*
 * registers.asm
 *
 *  Created: 2015-07-11 1:22:30 PM
 *   Author: Cameron
 */ 
 
.def progWordLow  = r0
.def progWordHigh = r1
.def regZero = r2
.def regFF = r9

.def regTemp = r18

/**
 * Value meanings
 * 0x01 == NextIsProximal
 * 0x02 == NextIsDistal
 */
.def regDirectionDetect = r20


.def regArgument = r3
.def regIncomingDataLength = r22

.def regAddress = r19
.def regError = r21

.def regPageEnd = r6

.def regCRCLow = r13
.def regCRCHigh = r12
.def regCRCTempA = r10
.def regCRCTempB = r23