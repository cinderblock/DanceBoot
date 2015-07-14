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
.org BootOriginWord

// Certain reset conditions do not relaunch the bootloader
.include "CheckResetCause.asm"

.include "Initialize.asm"

////////// Wait for Next / Prev to go low to detect direction //////////

// Start at 0
clr		regDirectionDetect

DetectProximalLoop:

// Skip the jump if Next is still High
sbis	NextPIN, NextNum
// If Next is Low, jump to marking it Proximal
rjmp	NextIsProximal

// Skip the loop if Prev is now Low
sbic	PrevPIN, PrevNum

// loop
rjmp DetectProximalLoop

// First of two increments
inc		regDirectionDetect

// If the above jumps to here, regDirectionDetect is only incremented once
NextIsProximal:
inc		regDirectionDetect

// Save Proximal/Distal too EEPROM
ldi		regTemp, 0
mov		regArgument, regDirectionDetect
rcall    EEPROM_Update

// Distal Low
rcall	DistalLow

///////// Read Bytes from bus continuously until Proximal goes High

// Start the initial address as 1 just in case. This will be incremented and have the first addr be 2
ldi		regAddress, 1

// Clear Pin Change Flag
ser		regTemp
sts		PCIFR, regTemp

WaitForProximalHighForAddressing:
// Read USART Register A
lds		regTemp, UCSR0A
// If there is no new data, skip
sbrc	regTemp, RXC0
// Grab latest byte
lds		regAddress, UDR0

// Wait for Pin Change Flag
sbis	PCIFR, PinChangeMaskNumber
rjmp	WaitForProximalHighForAddressing

// Wait for one more byte
rcall	USART_ReadByte

// Make sure they're the same
cpse	regTemp, regAddress

rjmp	AddressInitializationErrorRead

inc		regAddress

// If the increment rolled over to zero, the chain is too long
brne	AnnounceAddress

rjmp	AddressInitializationErrorLimit

///////// Announce new address and propagate /////////

AnnounceAddress:

// Enable RS-485 sending
sbi		SendEnablePRT, SendEnablePin

// Clear USART Tx Complete Flag
ldi		regTemp, 1 << TXC0
sts		UCSR0A, regTemp

// Send address
sts		UDR0, regAddress

// Save address to EEPROM
ldi		regTemp, 1
mov		regArgument, regAddress
rcall    EEPROM_Update

// Wait for send to complete
WaitForSendToComplete:
lds		regTemp, UCSR0A
sbrs	regTemp, TXC0
rjmp	WaitForSendToComplete

// And clear TX Complete Flag
sts		UCSR0A, regTemp

// Distal Release
rcall	DistalRelease

// Send Address again
sts		UDR0, regAddress

// Wait Send complete again
WaitForSendToCompleteAgain:
lds		regTemp, UCSR0A
sbrs	regTemp, TXC0
rjmp	WaitForSendToCompleteAgain

// Disable RS-485 sending
cbi		SendEnablePRT, SendEnablePin


///////// Wait for Distal or Proximal to go Low /////////

// If Distal Low, propagate, then loop
// If Proximal Low, propagate, then wait for commands

WaitForDistalOrProximalToAsert:

// Skip the jump if Next is still High
sbis	NextPIN, NextNum
// If Next is Low, jump to propagating to Prev
rjmp	SetPrevLow

// Don't loop yet if Prev is Low
sbic	PrevPIN, PrevNum

rjmp	WaitForDistalOrProximalToAsert

// Set Next Low
cbi		NextPRT, NextNum
sbi		NextDDR, NextNum

WaitForPrevHigh:
// If Prev becomes High, skip the loop
sbis	PrevPIN, PrevNum
rjmp	WaitForPrevHigh

// Next Release
cbi		NextDDR, NextNum
sbi		NextPRT, NextNum

cpi		regDirectionDetect, 1
// If regDirectionDetect == 0x01 (NextIsProximal), we're just propagating an error
breq	WaitForDistalOrProximalToAsert

// Otherwise, it's time for commands
rjmp	HandleCommands

SetPrevLow:
cbi		PrevPRT, PrevNum
sbi		PrevDDR, PrevNum

WaitForNextHigh:
// If Next becomes High, skip the loop
sbis	NextPIN, NextNum
rjmp	WaitForNextHigh

// Prev Release
cbi		PrevDDR, PrevNum
sbi		PrevPRT, PrevNum

cpi		regDirectionDetect, 2
// If regDirectionDetect == 0x02 (NextIsDistal), we're just propagating an error
breq	WaitForDistalOrProximalToAsert

// Otherwise continue


///////// Handle Commands /////////
HandleCommands:

// Read UDR to clear read flag
lds		regTemp, UDR0

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

// Register for handing errors
clr		regError
mov		regCRCLow, regTemp
mov		regCRCHigh, regTemp

// Wait for To byte
rcall	USART_ReadByte

// Check if To is a boradcast. boradcasts are better.
cp		regTemp, regZero

// If previous was equal, broadcast. Cool.
breq	HandleLength

// Compare address with read value
cp		regAddress, regTemp

breq	HandleLength

// Wrong Address error
sbr		regError, 0

// Read length from bus. Length does not include 2 byte CRC length
HandleLength:
rcall	USART_ReadByte

mov		regIncomingDataLength, regTemp

// Read command
rcall	USART_ReadByte

// Check for bootloader command
cpse	regTemp, regZero

// Mark wrong command error
sbr	regError, 1

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

// This helps later
dec		ZL

// And the rest of the page # to ZH
mov		ZH, regTemp

// It was safe to not check length until here because we
// know the 2 byte CRC is not included in the length. Also,
// any data read until would have no side effects. Therefore
// we haven't checked for errors yet. Now we need to exit
// if we're out of length and keep reading bytes even if
// we don't know what to do with them.

// Reverse the first dec before it happens
inc		regIncomingDataLength

ReadCommandData:
// Decrement length for each data byte
dec		regIncomingDataLength

// If we're out of bytes, go back to command handling
breq	HandleCommandsLoop

rcall	USART_ReadByte

// Check for previous error and just keep reading bytes for now
tst		regError
brne	ReadCommandData

// Increment our pointer
inc		ZL

// Check if we're writting to r0 or r1
sbrc	ZL, 0

// If we're writting to r1, we'll want to do a word write after and possibly more
rjmp	HandleHighByte

// Move incoming byte to r0
mov		progWordLow, regTemp

// And loop for now
rjmp	ReadCommandData


HandleHighByte:
mov		progWordHigh, regTemp

// Write word to temp page
ldi		regTemp, 0b00001
sts		SPMCSR, regTemp
spm

// Check if we're at the end
cpse	ZL, regPageEnd

// If not, loop
rjmp	ReadCommandData

// OK. We've gotten a whole page. We expect two more bytes with the CRC.
// First, we make sure length says we have 2 more, then we just stay here
// and don't use the earlier loops and checks.

cpi		regIncomingDataLength, 2

brne	PageCRCError

rcall	USART_ReadByte
rcall	USART_ReadByte

// Check if CRC passes
or		regCRCLow, regCRCHigh
brne	HandleCommands

// Do a Page Erase
ldi		regTemp, 0b00011
sts		SPMCSR, regTemp
spm

WaitForPageErase:
lds		regTemp, SPMCSR
sbrc	regTemp, 0
rjmp	WaitForPageErase

// Do a Page Write
ldi		regTemp, 0b00101
sts		SPMCSR, regTemp
spm

rjmp	HandleCommands


PageCRCError:
sbr		regError, 2
rjmp	ReadCommandData

CommandError:
;rcall	ProximalLow
;rjmp	HandleCommands


///////// Load Page /////////


///////// Check User Program /////////

.include "CheckUserProgram.asm"

///////// Functions /////////


.include "SignalPropagate.asm"
.include "EEPROM.asm"
.include "Errors.asm"
.include "USART.asm"
.include "CRC16.asm"
