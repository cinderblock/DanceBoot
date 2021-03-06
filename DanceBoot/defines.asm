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
.equ BootWords = 512

/**
 * Calculate values that IMHO should have already been defined for us.
 * We start from two important constants that AVR defines:
 *  - FLASHEND: the last possible WORD address
 *  - PAGESIZE: the number of WORDS in each page
 */

// A useful constant
.equ FlashSizeWords = (FLASHEND + 1)

// Number of pages on this AVR type
.equ FlashPages = (FlashSizeWords / PAGESIZE)

// Number of pages used by the bootloader
.equ BootPages = (BootWords / PAGESIZE)

// Number of pages left for the user program
.equ UserPages = FlashPages - BootPages

.equ UserWords = (FlashSizeWords - BootWords)
.equ UserBytes = (UserWords * 2)

/**
 * Location that the AVR will reset to is the same as the length
 * of the user section
 */
.equ BootloaderOrigin = UserWords

.equ	BaudRateRegister = 1

.equ	NextPRT = PORTC
.equ	NextDDR = DDRC
.equ	NextPIN = PINC
.equ	NextNum = 4

.equ	PrevPRT = PORTC
.equ	PrevDDR = DDRC
.equ	PrevPIN = PINC
.equ	PrevNum = 3

.equ	ReadEnablePRT = PORTC
.equ	ReadEnableDDR = DDRC
.equ	ReadEnablePin = 5

.equ	SendEnablePRT = PORTD
.equ	SendEnableDDR = DDRD
.equ	SendEnablePin = 2

.equ	SerialRxPRT = PORTD
.equ	SerialRxDDR = DDRD
.equ	SerialRxPin = 0

.equ	PinChangeMaskValue = 0b00011000
.equ	PinChangeMaskRegister = PCMSK1
.equ	PinChangeMaskNumber = 1

.equ	EEPROM_AddressLocation = 0
.equ	EEPROM_DirAndLastLocation = 1


// If this is the last device, wait a minimum of 2ms before
// starting the chain that propagates down.
// LastDelayNumberOfLoops = (Fclk * (delay length) - (extra cycles)) / (cycles per loop)
// Fclk = 20Mhz
// delay length = 2ms
// extra cycles = 4 (extra clock cycles to get in and out of loop)
// cycles per loop = 4 (number of clock cycles per loop)
// LastDelayNumberOfLoops = (20Mhz * 2 milliseconds - 4) / 4 == 9999
.equ	LastDelayNumberOfLoops = 9999