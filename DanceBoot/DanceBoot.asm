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
call    EEPROM_Update

// Distal Low
call	DistalLow

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
WaitForRepeatedAddress:
lds		regTemp, UCSR0A
sbrs	regTemp, RXC0
rjmp	WaitForRepeatedAddress
// Grab latest byte
lds		regTemp, UDR0

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
call    EEPROM_Update

// Wait for send to complete
WaitForSendToComplete:
lds		regTemp, UCSR0A
sbrs	regTemp, TXC0
rjmp	WaitForSendToComplete

// And clear TX Complete Flag
sts		UCSR0A, regTemp

// Distal Release
call	DistalRelease

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


///////// Load Page /////////


///////// Check User Program /////////

.include "CheckUserProgram.asm"

///////// Functions /////////


.include "SignalPropagate.asm"
.include "EEPROM.asm"
.include "Errors.asm"
