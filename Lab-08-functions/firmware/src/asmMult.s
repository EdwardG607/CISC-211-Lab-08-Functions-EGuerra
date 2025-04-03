/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Edward Guerra Ramirez"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,a_Sign,b_Sign,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    
    lsrs r3, r0, #16      /* Extracts the upper 16 bits from r0 (assumed multiplicand), stores in r3 */
    sxth r3, r3           /* Sign-extends the upper 16 bits to 32 bits */
    str r3, [r1]          /* Stores the sign-extended upper 16 bits to the address pointed to by r1 */

    uxth r3, r0           /* Extracts the lower 16 bits from r0 (assumed multiplier), store in r3 */
    sxth r3, r3           /* Sign-extends the lower 16 bits to 32 bits */
    str r3, [r2]          /* Store the sign-extended lower 16 bits to the address pointed to by r2 */
    bx lr                 /* Return from function */
    
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit 0 = "+", 1 = "-")
 *    outputs:  r0: Absolute value of r0 input. Same value as stored to location given in r1
 *              memory: store absolute value in location given by r1
 *                      store sign bit in location given by r2
 */    
asmAbs:  

    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    
    cmp r0, #0              /* Compare r0 (input value) with 0 */
    bge is_positive         /* If r0 >= 0, branch to is_positive */

    /* Handle negative input */
    mvn r3, r0              /* r3 = bitwise NOT of r0 (~r0) */
    add r3, r3, #1          /* r3 = -r0 (compute absolute value using two's complement) */
    str r3, [r1]            /* Store the absolute value at address pointed to by r1 */
    mov r0, r3              /* Copy absolute value into r0 as the return value */
    movs r3, #1             /* Set r3 = 1 to indicate negative sign */
    str r3, [r2]            /* Store sign = 1 at address pointed to by r2 */
    bx lr                   /* Return from function */

    is_positive:
    /* Handle non-negative input */
    str r0, [r1]            /* Store r0 directly as absolute value */
    movs r3, #0             /* Set r3 = 0 to indicate non-negative sign */
    str r3, [r2]            /* Store sign = 0 at address pointed to by r2 */
    /* r0 already contains the correct absolute value */
    bx lr                   /* Return from function */

    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */ 
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/

    mul r0, r0, r1        /* Multiply r0 by r1, store result in r0 */
    bx lr                 /* Return from function */

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/

   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product from previous step: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/

    eor r3, r1, r2        /* r3 = r1 ^ r2 (XOR the signs of A and B to determine result sign) */
    cmp r3, #0            /* Check if the result sign is 0 (i.e., signs are the same) */
    beq no_negate         /* If signs are the same, no need to negate the result */

    rsb r0, r0, #0        /* Negate r0: r0 = -r0 (if signs were different) */

    no_negate:
    bx lr                 /* Return from function */
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */  
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/		    
    
    /* Step 1: unpack */
    ldr r1, =a_Multiplicand     /* Load address of a_Multiplicand into r1 */
    ldr r2, =b_Multiplier       /* Load address of b_Multiplier into r2 */
    bl asmUnpack                /* Call asmUnpack to extract and store signed 16-bit values */

    /* Step 2a: abs(a) */
    ldr r0, =a_Multiplicand     /* Load address of a_Multiplicand into r0 */
    ldr r0, [r0]                /* Load the actual value of a_Multiplicand into r0 */
    ldr r1, =a_Abs              /* Load address of a_Abs into r1 (for output) */
    ldr r2, =a_Sign             /* Load address of a_Sign into r2 (for output) */
    bl asmAbs                   /* Call asmAbs to compute absolute value and sign of a */

    /* Step 2b: abs(b) */
    ldr r0, =b_Multiplier       /* Load address of b_Multiplier into r0 */
    ldr r0, [r0]                /* Load the actual value of b_Multiplier into r0 */
    ldr r1, =b_Abs              /* Load address of b_Abs into r1 (for output) */
    ldr r2, =b_Sign             /* Load address of b_Sign into r2 (for output) */
    bl asmAbs                   /* Call asmAbs to compute absolute value and sign of b */

    /* Step 3: multiply */
    ldr r0, =a_Abs              /* Load address of a_Abs into r0 */
    ldr r0, [r0]                /* Load the value of a_Abs into r0 */
    ldr r1, =b_Abs              /* Load address of b_Abs into r1 */
    ldr r1, [r1]                /* Load the value of b_Abs into r1 */
    bl asmMult                  /* Call asmMult to multiply a_Abs and b_Abs */
    mov r4, r0                  /* Store result of multiplication in r4 */
    ldr r3, =init_Product				
    str r4, [r3]                /* Save the initial product before sign correction */

    /* Step 4: fix sign */
    mov r0, r4                  /* Move initial product into r0 for sign correction */
    ldr r1, =a_Sign             /* Load address of a_Sign into r1 */
    ldr r1, [r1]                /* Load the sign of a into r1 */
    ldr r2, =b_Sign             /* Load address of b_Sign into r2 */
    ldr r2, [r2]                /* Load the sign of b into r2 */
    bl asmFixSign              /* Call asmFixSign to apply the correct sign to the product */

    /* Step 5: store final result */
    mov r4, r0                  /* Moves final signed product into r4 */
    ldr r3, =final_Product      /* Loads address of final_Product into r3 */
    str r4, [r3]                /* Stores the final product */
    bx lr                       /* Returns from the function */

    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */
