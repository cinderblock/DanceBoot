/*
 * CheckResetCause.asm
 *
 *  Created: 2015-07-11 1:25:49 PM
 *   Author: Cameron
 */ 

// Get the current reset cause(s)
in		regTemp, MCUSR

tst		regTemp

// If MCUSR is 0 we want to run the bootloader
breq	HandleCommands

.equ	FlagsForResetCondition = 1 << EXTRF | 1 << PORF

// Compare regTemp (MCUSR) with reset flags that we bootload for
andi	regTemp, FlagsForResetCondition

// If reselt is zero, it is a reset cause we don't bootload after, so
// check and run the user program since it probably crashed.
breq	CheckUserProgram


// Invert regTemp (MCUSR & FlagsForResetCondition)
com		regTemp
// Now only bit that we detected as high are set low in regTemp
// Use that to clear the flags that we care about. 
out		MCUSR, regTemp

rjmp	HandleCommands
