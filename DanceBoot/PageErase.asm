/*
 * PageErase.asm
 *
 *  Created: 2015-07-15 2:21:27 AM
 *   Author: Cameron
 */ 
 
HandlePageErase:


rcall	PageInit

rcall	ReadAndCheckCRC

// Setup a Page Erase
ldi		regTemp, 0b00011

rjmp	DoSpmAndReturnToCommandHandler