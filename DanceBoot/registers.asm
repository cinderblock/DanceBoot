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
 * Bit meanings:
 *  - Bit 0: Direction - 0 == NextIsDistal/PrevIsProximal, 1 == PrevIsDistal/NextIsProximal
 *  - Bit 1: Last      - 0 == Is Last,                     1 == Not Last
 *  - Bit 7: Valid     - 0 == Is Valid,                    1 == Not Valid
 */
.def regDirectionAndLast = r20


.def regArgument = r3
.def regIncomingDataLength = r22

.def regAddress = r19
.def regAddressMatch = r21

.def regTemp1 = r6

.def regCRCLow = r13
.def regCRCHigh = r12
.def regCRCTempA = r10
.def regCRCTempB = r23