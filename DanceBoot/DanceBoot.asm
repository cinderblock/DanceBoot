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

// We'll use this register regularily
clr regZero

// Set Next / Prev as inputs with pull-ups
cbi		NextDDR, NextNum
cbi		PrevDDR, PrevNum
sbi		NextPRT, NextNum
sbi		PrevPRT, PrevNum

// Setup RS-485 control lines
cbi		ReadEnablePRT, ReadEnablePin
cbi		SendEnablePRT, SendEnablePin
sbi		ReadEnableDDR, ReadEnablePin
sbi		SendEnableDDR, SendEnablePin



// Setup USART

// Setup Y ptr to first USART register UCSR0A (0xC0)
ldi		YL, low (UCSR0A)
ldi		YH, high(UCSR0A)

// Store BaudRateRegisterH to UBRR0H (0xC5)
ldi		regTemp, high (BaudRateRegister)
std		Y+5, regTemp
// Store BaudRateRegisterL to UBRR0L (0xC4)
ldi		regTemp, low  (BaudRateRegister)
std		Y+4, regTemp

// UCSR0C (0xC2) = 0b00000110 (default)
ldi		regTemp,   0b00000110
std		Y+2, regTemp

// UCSR0A (0xC0) = 0b00000000 (default)
std		Y+0, regZero

// UCSR0B (0xC1) = 0b00011000 (enable Rx / Tx)
ldi		regTemp,   0b00011000
std		Y+2, regTemp

// Enable pull-up on Rx pin
sbi		SerialRxPRT, SerialRxPin


////// Wait for Next / Prev to go low


// Enable Pin Change detection
ldi		regTemp,   PinChangeMaskValue
sts		PinChangeMaskRegister, regTemp

// Clear Pin Change Flag
ser		regTemp
sts		PCIFR, regTemp

// Wait for Pin Change Flag
PinChangeWait:
sbis	PCIFR, PinChangeMaskNumber
rjmp	PinChangeWait

// Detect which IO Low

// Save Proximal/Distal

// Distal Low

// Wait for Proximal High


// Record last byte seen on bus

//
