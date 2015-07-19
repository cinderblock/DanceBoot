/*
 * SignalPropagate.asm
 *
 *  Created: 2015-07-12 1:56:33 PM
 *   Author: Cameron
 */

DistalLow:
// If value is invalid, return
sbrc	regDirectionAndLast, 7
ret

// If Bit 0 is set, don't skip, since PrevIsDistal
sbrc	regDirectionAndLast, 0
rjmp	PrevLow

NextLow:
cbi		NextPRT, NextNum
sbi		NextDDR, NextNum
ret

NextPrevLow:
rcall	NextLow
PrevLow:
cbi		PrevPRT, PrevNum
sbi		PrevDDR, PrevNum

Return:
ret

NextRelease:
cbi		NextDDR, NextNum
sbi		NextPRT, NextNum
ret

NextPrevRelease:
rcall	NextRelease
PrevRelease:
cbi		PrevDDR, PrevNum
sbi		PrevPRT, PrevNum
ret