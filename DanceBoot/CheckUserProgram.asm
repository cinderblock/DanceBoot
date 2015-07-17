/*
 * CheckUserProgram.asm
 *
 *  Created: 2015-07-11 1:57:36 PM
 *   Author: Cameron
 */ 

CheckUserProgram:

// Make sure Z starts at 0 for LPM
ldi		ZL, 0x00
ldi		ZH, 0x00

// Clear CRC
ldi		regTemp, 0xff
mov		regCRCLow, regTemp
mov		regCRCHigh, regTemp

// Used for exit condition
ldi		regTemp, high(UserBytes)
mov		regTemp1, regTemp

ProgramLPMLoop:
// Load the next program byte
lpm		regTemp, Z+

// Do the CRC
rcall	CRC_FromTemp

cpi		ZL, low (UserBytes)
cpc		ZH, regTemp1 // high(UserBytes)
brne	ProgramLPMLoop

// Check if CRC passes
or		regCRCLow, regCRCHigh

// Go back to handling commands if not
brne	HandleCommands

// Time to launch the user program

clr		ZH
clr		ZL

// Just in case wdr is on in fuses
wdr
ijmp