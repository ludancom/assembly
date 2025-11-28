//--------------------------------------------------------------------
// mywc.s                                                             
// Author: Saleema & Ludan                                            
//--------------------------------------------------------------------
// enum {FALSE, TRUE};
        .equ    FALSE, 0
        .equ    TRUE, 1
        .equ    EOF, -1

//----------------------------------------------------------------------
        .section .rodata

printfFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------
        .section .bss // Stores unitialized variables

// static int iChar;                /* Bad style. */
iChar:
        .skip   4

//----------------------------------------------------------------------
        .section .data // Stores initialized variables

// static long lLineCount = 0;      /* Bad style. */
// static long lWordCount = 0;      /* Bad style. */
// static long lCharCount = 0;      /* Bad style. */
// static int iInWord = FALSE;      /* Bad style. */  

lLineCount:
        .quad   0
lWordCount:
        .quad   0
lCharCount:
        .quad   0
iInWord:
        .word   FALSE

//----------------------------------------------------------------------
        .section .text

    //------------------------------------------------------------------
    // Write to stdout counts of how many lines, words, and characters
    // are in stdin. A word is a sequence of non-whitespace characters.
    // Whitespace is defined by the isspace() function. Return 0.
    //------------------------------------------------------------------

    // Must be a multiple of 16
    .equ    MAIN_STACK_BYTECOUNT, 16

    .global main

main:
       // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]
loop1:
        // if((iChar = getchar()) == EOF) goto endloop1;
        bl      getchar // Stores result in w0
        adr     x1, iChar
        str     w0, [x1] // iChar = getchar()
        cmp     w0, EOF
        beq     endloop1
        // lCharCount++;
        adr     x2, lCharCount
        ldr     x7, [x2]
        add     x7, x7, 1
        str     x7, [x2]
        // if (!isspace(iChar)) goto else1;
        bl isspace
        cmp w0, FALSE
        beq else1
        // if (!iInWord) goto endif2;
        adr  x3, iInWord
        ldr  w4, [x3]
        cmp  w4, FALSE
        beq  endif2
        // lWordCount++;
        adr x5, lWordCount
        ldr x7, [x5]
        add x7, x7, 1
        str x7, [x5]
        // iInWord = FALSE;
        str wzr, [x3]
        // goto endif2;
        b endif2
else1:
        // if (iInWord) goto endif3;
        adr  x3, iInWord 
        ldr  w4, [x3] 
        cmp w4, TRUE
        beq endif3
        // iInWord = TRUE;
        mov w6, TRUE
        str w6, [x3]
endif2:
endif3:
        // if (iChar != '\n') goto endif4;
        adr x1, iChar 
        ldr w0, [x1] // BAD PRACTICE??????????????????????????????????
        cmp w0, 0X0A // 0X0A is '\n'
        bne endif4
        // lLineCount++;
        adr x6, lLineCount
        ldr x7, [x6]
        add x7, x7, 1 
        str x7, [x6]
endif4:
        // goto loop1;
        b loop1
endloop1:
        // if (!iInWord) goto endif5;
        adr  x3, iInWord 
        ldr  w4, [x3] 
        cmp w4, FALSE
        beq endif5
        // lWordCount++;
        adr x5, lWordCount 
        ldr x7, [x5]
        add x7, x7, 1
        str x7, [x5]
endif5: 
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr x0, printfFormatStr
        adr x1, lLineCount
        ldr x1, [x1]
        adr x2, lWordCount
        ldr x2, [x2]
        adr x3, lCharCount
        ldr x3, [x3]
        bl printf
        // Epilog and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
    