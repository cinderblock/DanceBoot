/*
 * DanceBoot.asm
 *
 *  Created: 2015-07-11 1:12:42 PM
 *   Author: Cameron
 */ 


.include "defines.asm"
.include "registers.asm"

// Start a new section
.cseg
// And give it a location
.org BootloaderOrigin

.include "Initialize.asm"

// Certain reset conditions do not relaunch the bootloader
.include "CheckResetCause.asm"
	
///////// Check User Program /////////

.include "CheckUserProgram.asm"

.include "LoadEEPROMAddress.asm"

///////// Handle Commands /////////
HandleCommands:
rcall	NextPrevLow

HandleCommandsLoop:

// Wait for and read a Start byte
rcall	USART_ReadByte

// First byte is 0xff
cpi		regTemp, 0xff

// If first byte is incorrect, loop
brne	HandleCommandsLoop

// Wait for and read a second Start byte
rcall	USART_ReadByte

// Second byte is 0xff
cpi		regTemp, 0xff

// If first byte is incorrect, loop
brne	HandleCommandsLoop

rcall	NextPrevRelease

// Register for handing address matching
clr		regAddressMatch
// Bit 0: 0 == addressMatch (broadcast or not)
// Bit 1: 0 == broadcastMatch

// Clear CRC (regTemp happens to have 0xff in it right now)
mov		regCRCLow, regTemp
mov		regCRCHigh, regTemp

// Wait for To byte
rcall	USART_ReadByte

// Check if To is a boradcast. boradcasts are better.
cpse	regTemp, regZero

// Set NOT broadcast match
sbr		regAddressMatch, 1

// Compare address with read value
cpse	regAddress, regTemp

// Set NOT Address match
sbr		regAddressMatch, 0

// Skip if we didn't get a broadcast
sbrs	regAddressMatch, 1

// Mark that the address also matches
cbr		regAddressMatch, 0

// Right now regAddressMatch is in one of 3 states:
// No Match  : regAddressMatch == 0b11
// Addr Match: regAddressMatch == 0b10
// Broacast  : regAddressMatch == 0b00

// Read length from bus. Length does not include 2 byte CRC length
HandleLength:
rcall	USART_ReadByte

mov		regIncomingDataLength, regTemp

// This helps later
inc		regIncomingDataLength

sbrs	regAddressMatch, 0
rjmp	NotAddressed

// Clear pin change flag to detect and propagate errors later
sbi		PCIFR, PinChangeMaskNumber

// Read command
rcall	USART_ReadByte

// Check for Page Erase Command
cpi		regTemp, 0xF1
breq	HandlePageErase

// Check for Page Write Command
cpi		regTemp, 0xF2
breq	HandlePageWrite

// Check for Readdress Command
cpi		regTemp, 0xF3
breq	DirectionDetect

cpi		regTemp, 0xF4
breq	CheckUserProgram


// Otherwise we did not match any commands. So just continue on as if
// we were ignoring the message because it wasn't for us.

NotAddressed:
// Read 1 more byte to account for the CRC not being in the length and command was read
rcall	USART_ReadByte

NotAddressedLoop:
rcall	ReadNextByte
rjmp	NotAddressedLoop

// ONLY USE WITH [r]call. Will return to HandleCommands and clean up the stack
ReadAndCheckCRC:
rcall	USART_ReadByte
rcall	USART_ReadByte

// Check if CRC passes
or		regCRCLow, regCRCHigh

// If not, jump back to command handling after clearing stack
brne	PopParentCallAndReturnToHandleComands

ret

// ONLY USE WITH [r]call. Will return to HandleCommands and clean up the stack
ReadNextByte:
dec		regIncomingDataLength

breq	PopParentCallAndReturnToHandleComands

// If pin change has happened, bit will be set, so no skipping
sbic	PCIFR, PinChangeMaskNumber

// Set neighboars low to propagate the error
rcall	NextPrevLow

// Jump to the ReadByte function, it'll return for us.
rjmp	USART_ReadByte

PopParentCallAndReturnToHandleComands:
// Someone called the ReadNextByte function and there wasn't any data left.
// They loose their priviledges to handle the data so we don't return and
// instead just jump back to handling commands. To prevent a memory leak,
// we need to pop the return address off of the stack.
pop		regTemp
pop		regTemp

rjmp	HandleCommands



///////// Functions /////////

.include "PageErase.asm"
.include "PageWrite.asm"
.include "DirectionDetect.asm"
.include "SignalPropagate.asm"
.include "EEPROM.asm"
.include "USART.asm"
.include "CRC16.asm"
