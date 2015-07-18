/*
 * LoadEEPROMAddress.asm
 *
 *  Created: 2015-07-18 1:46:26 PM
 *   Author: Cameron
 */

LoadEEPROMAddress:

ldi		regTemp, EEPROM_AddressLocation
rcall	EEPROM_Read
mov		regAddress, regTemp