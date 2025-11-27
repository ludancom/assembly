//--------------------------------------------------------------------
    //enum { FALSE, TRUE };
    //EOF as a constant
    //FALSE: .equ 0
   //TRUE: .equ 1
    //EOF: .equ -1

//--------------------------------------------------------------------

    .section .rodata

PrintfFormatStr:
    .string "%7ld %7ld %7ld\n"

//--------------------------------------------------------------------

    .section .data
    
    // static long lLineCount = 0;      /* Bad style. */
    // static long lWordCount = 0;      /* Bad style. */
    // static long lCharCount = 0;      /* Bad style. */
    // tatic int iInWord = FALSE;      /* Bad style. */

    .global lLineCount
    lLineCount: .quad 0

    .global lWordCount
    lWordCount: .quad 0

    .global lCharCount
    lCharCount: .quad 0

    .global iInWord
    iInWord: .word FALSE;


//--------------------------------------------------------------------

    .section .bss

// static int iChar;         
iChar:
    .skip 4;


//--------------------------------------------------------------------

    .section .text

    //----------------------------------------------------------------
    //Write to stdout counts of how many lines, words, and characters
    //are in stdin. A word is a sequence of non-whitespace characters.
    //Whitespace is defined by the isspace() function. Return 0. 
    //----------------------------------------------------------------
    .equ MAIN_STACK_BYTECOUNT, 16

main:
    //Prolog
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]


    loop1:

    //if((iChar = getChar()) == EOF) b endloop1
        bl      getChar //returned to x0
        adr     x1, iChar //store the address of ichar into x1 (adr needs x, not w)
        str     w0, [x1] //store whatever is returned into w0 into iChar
    
        cmp w0, EOF
        beq endloop1

        //if(!(isspace(iChar))) b else1
        adr     x1, iChar //store the address of ichar into x1 (adr needs x, not w)
        ldr     w0, [x1] //put iCHAR into w0, the argument reg
        bl      isspace

        cmp     w0, FALSE
        beq     else1

            //if(!(iInWord)) b endif2
            adr     x2, iInWord; //always produces 64-bit address, so use x
            ldr     w1, [x2];
            cmp     w1, FALSE
            beq     endif2
            
            adr     x2, lWordCount //x2 has lwordcount address
            ldr     x3, [x2] // x3 has wordcount value
            add     x3, x3, 1 //lWordCount++
            str     x3, [x2] //save into lWordcount the value of x3


            adr     x4, iInWord //w4 has inword address
            mov     w5, FALSE //iInWord = FALSE;
            str     w5, [x4] //store inro iInWord the falue from w4
            endif2:

        else1:
        //if(!(iInWord)) b endif3
            adr     x1, iInWord
            ldr     w2, [x1]
            cmp     w2, FALSE
            beq     endif3

            mov     w3, TRUE
            str     w3, [x1] //iInWord = TRUE;
        endif3:

        endif1:
        //if(iChar != '\n') b endif4
        adr     x1, iChar;
        ldr     w2, [x1];
        cmp     w2, #'\n'; //comparing iChar with newline character
        beq     endif4

        adr     x1, lLineCount
        ldr     x2, [x1]
        add     x2, x2, 1 //lLineCount++
        str     x2, [x1];
        endif4:
    b loop1

    endloop1:

    //if(!(iInWord)) b endif5
    adr     x1, iInWord
    ldr     w2, [x1]
    cmp     w2, FALSE
    beq     endif5
 
    //lWordCount++
    adr     x1, lWordCount
    ldr     x2, [x1]
    add     x2, x2, 1 
    str     x2, [x1];
    endif5:
    
    //printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
    adr     x0, printfFormatStr
    adr     x1, lLineCount
    ldr     x1, [x1]
    adr     x2, lWordCount
    ldr     x2, [x2]
    adr     x3, lCharCount
    ldr     x3, [x3]
    bl      printf


    //Epilog
    mov    w0, 0
    ldr     x30, [sp]
    add     sp, sp, MAIN_STACK_BYTECOUNT
    ret

.size main, (. - main)


