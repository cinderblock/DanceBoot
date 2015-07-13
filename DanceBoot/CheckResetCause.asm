/*
 * CheckResetCause.asm
 *
 *  Created: 2015-07-11 1:25:49 PM
 *   Author: Cameron
 */ 

// Get the current reset cause(s)
in		regTemp, MCUSR

// If regTemp is empty
tst		regTemp

// Branch if result was zero (no reset flags are set. Weird)
breq	CheckResetCauseEnd

.equ	FlagsForResetCondition = 1 << EXTRF | 1 << PORF

// Compare regTemp (MCUSR) with reset flags that we bootload for
andi	regTemp, FlagsForResetCondition

// If reselt is not zero, it's a reset cause we care about, so skip to the end
brne	CheckResetCauseClear


rjmp	CheckUserProgram


CheckResetCauseClear:

// Invert regTemp (MCUSR & FlagsForResetCondition)
com		regTemp
// Now only bit that we detected as high are set low in regTemp
// Use that to clear the flags that we care about. 
out		MCUSR, regTemp

CheckResetCauseEnd: