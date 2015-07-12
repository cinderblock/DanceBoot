/*
 * SignalPropagate.asm
 *
 *  Created: 2015-07-12 1:56:33 PM
 *   Author: Cameron
 */ 

SignalPropagate:

// Skip the jump if Next is still High
sbis	NextPIN, NextNum
// If Next is Low, jump to propagating to Prev
rjmp	SignalPropagateToPrev

// Skip the return if Prev is Low
sbic	PrevPIN, PrevNum

ret

SignalPropagateToNext:
// Next Low
cbi		NextPRT, NextNum
sbi		NextDDR, NextNum

WaitForPrevHigh:
// If Prev becomes High, skip the loop
sbis	PrevPIN, PrevNum
rjmp	WaitForPrevHigh

// Next Release
cbi		NextDDR, NextNum
sbi		NextPRT, NextNum

ret

SignalPropagateToPrev:
// Prev Low
cbi		PrevPRT, PrevNum
sbi		PrevDDR, PrevNum

WaitForNextHigh:
// If Next becomes High, skip the loop
sbis	NextPIN, NextNum
rjmp	WaitForNextHigh

// Prev Release
cbi		PrevDDR, PrevNum
sbi		PrevPRT, PrevNum

Return:
ret

ProximalLow:
cpi		regDirectionDetect, 2
// If regDirectionDetect == 0x02 (NextIsDistal), set Prev to Low
breq	PrevLow

cpi		regDirectionDetect, 1
// If regDirectionDetect != 0x01 (NextIsProximal), return since that's invalid
brne	Return

// Next Low
cbi		NextPRT, NextNum
sbi		NextDDR, NextNum
ret

DistalLow:
cpi		regDirectionDetect, 1
// If regDirectionDetect == 0x01 (NextIsProximal), set Prev to Low
breq	PrevLow

cpi		regDirectionDetect, 2
// If regDirectionDetect != 0x02 (NextIsDistal), return since that's invalid
brne	Return

NextLow:
cbi		NextPRT, NextNum
sbi		NextDDR, NextNum
ret


PrevLow:
cbi		PrevPRT, PrevNum
sbi		PrevDDR, PrevNum
ret


