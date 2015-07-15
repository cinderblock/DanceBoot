/*
 * PageWrite.asm
 *
 *  Created: 2015-07-15 12:54:22 AM
 *   Author: Cameron
 */ 
 
PageInit:
// Clear ZL used in page loading
clr		ZL

// Load page number
rcall	USART_ReadByte

// Page # does not align with Z byte
lsr		regTemp

// Move LSB of page # to MSB of ZL (using carry)
ror		ZL

// Save this value for use later
mov		regPageEnd, ZL
ori		ZL, 0x7F

// And the rest of the page # to ZH
mov		ZH, regTemp

ret

HandlePageWrite:

// TODO: Ensure length is not regIncomingDataLength

rcall	PageInit

// This helps later
dec		ZL


ReadPageDataByte:
rcall	ReadNextByte

// Increment our pointer
inc		ZL

// Check if we're writting to r0 or r1
sbrc	ZL, 0

// If we're writting to r1, we'll want to do a word write after and possibly more
rjmp	HandleHighByte

// Move incoming byte to r0
mov		progWordLow, regTemp

// And loop for now
rjmp	ReadPageDataByte


HandleHighByte:
mov		progWordHigh, regTemp

// Write word to temp page
ldi		regTemp, 0b00001
sts		SPMCSR, regTemp
spm

// Check if we're at the end
cpse	ZL, regPageEnd

// If not, loop
rjmp	ReadPageDataByte

// OK. We've gotten a whole page. Check the CRC.

rcall	ReadAndCheckCRC

// Setup a Page Write
ldi		regTemp, 0b00101

DoSpmAndReturnToCommandHandler:
sts		SPMCSR, regTemp
spm

SpmWaitLoop:

lds		regTemp, SPMCSR

// If pin change has happened, bit will be set, so no skipping
sbic	PCIFR, PinChangeMaskNumber

// Set neighboars low to propagate the error
rcall	NextPrevLow

sbrc	regTemp, 0
rjmp	SpmWaitLoop

rjmp	HandleCommands