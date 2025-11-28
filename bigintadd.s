//--------------------------------------------------------------------
// bigintadd.s                                                            
// Author: Saleema & Ludan                                            
//--------------------------------------------------------------------
// enum {FALSE, TRUE};
        .equ    FALSE, 0
        .equ    TRUE, 1

//----------------------------------------------------------------------
        .section .rodata

//----------------------------------------------------------------------
        .section .bss 

//----------------------------------------------------------------------
        .section .data 

//----------------------------------------------------------------------
        .section .text

    //------------------------------------------------------------------
    // Return the larger of lLength1 and lLength2. 
    //------------------------------------------------------------------

    // Must be a multiple of 16
    .equ    STACK_BYTECOUNT, 32
    
    // Parameter stack offsets
    .equ LLENGTH1, 8
    .equ LLENGTH2, 16

    // Local variable stack offsets
    .equ LLARGER, 24

    .global BigInt_larger

// static long BigInt_larger(long lLength1, long lLength2)
BigInt_larger:
        // Prolog
        sub     sp, sp, STACK_BYTECOUNT
        str     x30, [sp]   // Save x30
        // Parameters: long lLength1, long lLength2
        str x0, [sp, LLENGTH1]    // Save lLength1
        str x1, [sp, LLENGTH2]    // Save lLength2 
        // if (lLength1 <= lLength2) goto else1;
        cmp [x0], [x1]  // x0 points to lLength1, x1 points lLength2 
        ble else1
        // long lLarger; lLarger = lLength1;
        str [x0], [sp, LLARGER] // Save lLarger; 
        b endif1 
    else1:
        // long lLarger; lLarger = lLength2;
        str [x1], [sp, LLARGER] // Save lLarger; 
    endif1:
        // return lLarger;
        ldr x0, [sp, LLLARGER]  // Load lLarger
        ldr x30, [sp]            // Restore x30
        add sp, sp, STACK_BYTECOUNT
        ret
    

/*--------------------------------------------------------------------*/

/* Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
   distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
   overflow occurred, and 1 (TRUE) otherwise. */

int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
{
   unsigned long ulCarry;
   unsigned long ulSum;
   long lIndex;
   long lSumLength;
 
   /* Determine the larger length. */
   lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

   /* Clear oSum's array if necessary. */
   if (oSum->lLength <= lSumLength) goto endif1;
   memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

   endif1:
   /* Perform the addition. */
   ulCarry = 0;
   lIndex = 0;
   loop1:
   if(lIndex >= lSumLength) goto endloop1;
   ulSum = ulCarry;
   ulCarry = 0;

   ulSum += oAddend1->aulDigits[lIndex];
   if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2; /* Check for overflow. */
   ulCarry = 1;
   
   endif2:
   ulSum += oAddend2->aulDigits[lIndex];
   if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3;  /* Check for overflow. */
   ulCarry = 1;

   endif3:
   oSum->aulDigits[lIndex] = ulSum;
   lIndex++;
   goto loop1;

   endloop1:
   /* Check for a carry out of the last "column" of the addition. */
   if (ulCarry != 1) goto endif4;
   
   if (lSumLength != MAX_DIGITS) goto endif5;
   return FALSE;
   
   endif5:
   oSum->aulDigits[lSumLength] = 1;
   lSumLength++;
   
   endif4:
   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;
}
