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
.org BootOrigin

// Certain reset conditions do not relaunch the bootloader
.include "CheckResetCause.asm"

.include "Initialize.asm"

////// Wait for Next / Prev to go low

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

// Save Proximal/Distal
ldi		regTemp, 0
call    EEPROM_Update

// Distal Low
call	DistalLow

///////// Read Bytes from bus continuously until Proximal goes High

// Start the initial address as zero just in case
clr		regAddress

// Clear Pin Change Flag
ser		regTemp
sts		PCIFR, regTemp

WaitForProximalHighForAddressing:
// Read USART Register A
in		regTemp, UCSR0A
// If there is no new data, skip
sbrc	regTemp, UDRE0
// Grab latest byte
in		regAddress, UDR0

// Wait for Pin Change Flag
sbis	PCIFR, PinChangeMaskNumber
rjmp	WaitForProximalHighForAddressing

// Wait for one more byte
WaitForRepeatedAddress:
in		regTemp, UCSR0A
sbrs	regTemp, UDRE0
rjmp	WaitForRepeatedAddress
// Grab latest byte
in		regTemp, UDR0

// Make sure they're the same
cpse	regTemp, regAddress

rjmp	AddressInitializationErrorRead

inc		regAddress

// Make sure we're not at the end
cpi		regAddress, 255

breq	AddressInitializationErrorLimit

///////// Announce new address and propagate /////////

// Enable RS-485 sending
sbi		SendEnablePRT, SendEnablePin

// Send address
out		UDR0, regAddress


// Save address to EEPROM


// Wait for send to complete


// Distal Release


// Send Address again


// Wait Send complete


// Disable RS-485 sending
cbi		SendEnablePRT, SendEnablePin


///////// Wait for Distal or Proximal to go Low /////////

// If Distal Low, propagate, then loop
// If Proximal Low, propagate, then wait for commands


///////// Handle Commands /////////


///////// Load Page /////////


///////// Check User Program /////////

.include "CheckUserProgram.asm"

///////// Functions /////////


.include "SignalPropagate.asm"
.include "EEPROM.asm"