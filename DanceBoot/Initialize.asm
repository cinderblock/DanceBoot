/*
 * Initialize.asm
 *
 *  Created: 2015-07-12 2:23:31 PM
 *   Author: Cameron
 */ 


// We'll use this register regularily
clr regZero

///////// Set Next / Prev as inputs with pull-ups /////////
cbi		NextDDR, NextNum
cbi		PrevDDR, PrevNum
sbi		NextPRT, NextNum
sbi		PrevPRT, PrevNum

///////// Setup RS-485 control lines /////////

// Set Low values on output enables
cbi		ReadEnablePRT, ReadEnablePin
cbi		SendEnablePRT, SendEnablePin

// Enable AVR outputs
sbi		ReadEnableDDR, ReadEnablePin
sbi		SendEnableDDR, SendEnablePin



///////// Setup USART /////////

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


///////// Setup EEPROM /////////

// We never use the high byte of the address
out		EEARH, regZero

// Make sure control regster is as we expect it
out		EECR, regZero



///////// Setup Next/Prev Pin Change detection /////////

// Enable Pin Change detection
ldi		regTemp,   PinChangeMaskValue
sts		PinChangeMaskRegister, regTemp