/*
 * USART.asm
 *
 *  Created: 2015-07-12 11:21:40 PM
 *   Author: Cameron
 */ 

USART_ReadByte:
lds		regTemp, UCSR0A
sbrs	regTemp, RXC0
rjmp	USART_ReadByte
// Grab latest byte
lds		regTemp, UDR0
ret