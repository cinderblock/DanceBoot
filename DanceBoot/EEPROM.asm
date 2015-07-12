/*
 * EEPROM.asm
 *
 *  Created: 2015-07-12 1:40:41 PM
 *   Author: Cameron
 */


/**
 * regTemp == low address byte
 * regArgument == value to save
 */
EEPROM_Update:

// Wait for completion of any current write operation
sbic	EECR, EEPE
rjmp	EEPROM_Update
 
// Load address
out		EEARL, regTemp

// Start EEPROM Read
sbi		EECR, EERE

// Read EEROM Byte
in		regTemp, EEDR

// Compare current EEPROM value with new value
cp		regTemp, regArgument

// Jump to the end return statement if they're already done
breq	EEPROM_UpdateEnd

out		EEDR, regDirectionDetect

sbi		EECR, EEMPE
sbi		EECR, EEPE

EEPROM_UpdateEnd:
ret