/*
 * DirectionDetect.asm
 *
 *  Created: 2015-07-14 11:50:13 PM
 *   Author: Cameron
 */ 
 
DirectionDetect:

// Mark invalid and get into a know state
ser		regDirectionAndLast

// Last byte
clr		regTemp1

// flag for match
clr		regAddressMatch


///////// Read Bytes from bus continuously until Proximal goes High

DetectProximalLoop:

// Read USART Register A
lds		regTemp, UCSR0A
// If there is new data, skip checking if latest byte was received twice
sbrs	regTemp, RXC0

rjmp	CheckHasReceivedDoubleByte

// Assume match temporarily
inc		regAddressMatch

// Grab latest byte
lds		regAddress, UDR0

// If current and last match, great. Skip next
cpse	regAddress, regTemp1

// Mark no match
clr		regAddressMatch

// Copy new byte to last
mov		regTemp1, regAddress

CheckHasReceivedDoubleByte:
// If repeated byte has been received
tst		regAddressMatch
breq	DetectProximalLoop

// Skip the jump if Next is still High
sbis	NextPIN, NextNum
// If Next is Low, jump to marking it Proximal
rjmp	NextIsProximal

// Skip the loop if Prev is now Low
sbic	PrevPIN, PrevNum

// loop
rjmp DetectProximalLoop

// Mark NextIsDistal
cbr		regDirectionAndLast, 0

NextIsProximal:
// Mark Direction Valid
cbr		regDirectionAndLast, 7

// Increment address
inc		regAddress

// If the increment rolled over to zero, the chain is too long
breq	HandleCommandsJMP

///////// Save new address and propagate /////////

SaveAddress:


// Save Address too EEPROM
ldi		regTemp, EEPROM_AddressLocation
mov		regArgument, regAddress
rcall	EEPROM_Update

// Enable RS-485 sending
sbi		SendEnablePRT, SendEnablePin

// Clear USART Tx Complete Flag
ldi		regTemp, 1 << TXC0
sts		UCSR0A, regTemp

// Send address once
sts		UDR0, regAddress

USART_SendWait:
lds		regTemp, UCSR0A
sbrs	regTemp, UDRE0
rjmp	USART_SendWait

// Send address again
sts		UDR0, regAddress

// Wait for send to complete
WaitForSendToComplete:
lds		regTemp, UCSR0A
sbrs	regTemp, TXC0
rjmp	WaitForSendToComplete

// Disable RS-485 sending
cbi		SendEnablePRT, SendEnablePin

// Distal Low
rcall	DistalLow

// And clear RX Complete Flag
lds		regAddress, UDR0

rcall	WaitForNeighborChange

// Distal Release
rcall	NextPrevRelease

// Check if we've received more bytes
lds		regTemp, UCSR0A
sbrs	regTemp, RXC0

// Mark Last
cbr		regDirectionAndLast, 1

// Save Dir/Last to EEPROM
ldi		regTemp, EEPROM_DirAndLastLocation
mov		regArgument, regDirectionAndLast
rcall	EEPROM_Update

CheckForLastOrWaitForNeighborLow:

sbrc	regDirectionAndLast, 1
rjmp	LastDelay

///////// Wait for Neighbor to go Low /////////

rcall	WaitForNeighborChange

HandleCommandsJMP:
rjmp	HandleCommands

LastDelay:
ldi		regTempWordA,low(LastDelayNumberOfLoops)
ldi		regTempWordB,high(LastDelayNumberOfLoops)
LastDelayLoop:
sbiw	regTempWordA,1
brne	LastDelayLoop

rjmp	HandleCommands


WaitForNeighborChange:
// Clear Pin Change Flag
ser		regTemp
sts		PCIFR, regTemp

// Wait for Pin Change Flag (Proximal High)
WaitForProximalHighForAddressingDone:
sbis	PCIFR, PinChangeMaskNumber
rjmp	WaitForProximalHighForAddressingDone
ret
