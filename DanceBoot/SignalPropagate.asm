/*
 * SignalPropagate.asm
 *
 *  Created: 2015-07-12 1:56:33 PM
 *   Author: Cameron
 */

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

Return:
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



ProximalRelease:
cpi		regDirectionDetect, 2
// If regDirectionDetect == 0x02 (NextIsDistal), Prev Release
breq	PrevRelease

cpi		regDirectionDetect, 1
// If regDirectionDetect != 0x01 (NextIsProximal), return since that's invalid
brne	Return

// Next Release
cbi		NextDDR, NextNum
sbi		NextPRT, NextNum
ret

DistalRelease:
cpi		regDirectionDetect, 1
// If regDirectionDetect == 0x01 (NextIsProximal), set Prev to Low
breq	PrevRelease

cpi		regDirectionDetect, 2
// If regDirectionDetect != 0x02 (NextIsDistal), return since that's invalid
brne	Return

NextRelease:
cbi		NextDDR, NextNum
sbi		NextPRT, NextNum
ret


PrevRelease:
cbi		PrevDDR, PrevNum
sbi		PrevPRT, PrevNum
ret


NextPrevLow:
rcall	PrevLow
rjmp	NextLow

NextPrevRelease:
rcall	PrevRelease
rjmp	NextRelease