/*
 * defines.asm
 *
 *  Created: 2015-07-11 1:13:24 PM
 *   Author: Cameron
 */ 


/**
 * Set this value for the device we're using
 */
.device ATmega168pa

/**
 * Value is device and fuse setting specific
 */
.equ BootWords=256

.equ BootPages=(BootWords / PAGESIZE)

/**
 * Calculate value that IMHO should have already been defined for us.
 */
.equ FLASHSIZE = FLASHEND + 1
.equ FLASHPAGES= FLASHSIZE / PAGESIZE

/**
 * Location that the AVR will reset to
 */
.equ BootOriginWord = FLASHSIZE - BootWords

.equ	BaudRateRegister = 1

.equ	NextDDR = DDRC
.equ	NextPRT = PORTC
.equ	NextPIN = PINC
.equ	NextNum = 4
.equ	PrevDDR = DDRC
.equ	PrevPRT = PORTC
.equ	PrevPIN = PINC
.equ	PrevNum = 3

.equ	ReadEnableDDR = DDRC
.equ	ReadEnablePRT = PORTC
.equ	ReadEnablePin = 5

.equ	SendEnableDDR = DDRD
.equ	SendEnablePRT = PORTD
.equ	SendEnablePin = 2

.equ	SerialRxPRT = PORTD
.equ	SerialRxPin = 0

.equ	PinChangeMaskValue = 0b00011000
.equ	PinChangeMaskRegister = PCMSK1
.equ	PinChangeMaskNumber = 1