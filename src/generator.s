.data

    ; The seed and results for testing
    seed:         .word 1, 0
    results:      .word 17747, 2055, 3664, 15611, 9816

    ; The addresses for the seed and result variables
    seed_addr:    .word seed
    results_addr: .word results

    .equ N, 5  ; "results" array size

.text

bl main  ; Run the main program

/**
 * Calculates a pseudo-random number given two multiplying parameters.
 *
 * Function register mappings:
 * - R0, R1, R2, R3: Extended multiplicand/parameters/return
 * - R4, R5, R6, R7: Result
 * - R8: Previous least significant bit
 * - R9: i (iteration variable)
 * - R10, R11, R12: helpers 
 * 
 * @param multiplicand The multiplicand, stored at {R0, R1}
 * @param multiplier The multiplifer, stored at {R2, R3}
 *
 * @return The calculated random number, stored at {R0, R1}
 */
umull32:

    bl save_registers;

    ; Extend the multiplier to r4 - r7
    mov R4, R2
    mov R5, R3
    mov R6, #0x0
    mov R7, #0x0

    ; Extend the multiplicand from r0 - r3
    mov R2, #0x0
    mov R3, #0x0

    ; Setup the previous_lsb and i
    mov R8, #0x0
    mov R9, #0x0
    b umull32_for_condition

    umull32_for_condition:

        mov R12, #32

        ; Since we can only pass 3 bits into the second argument of
        ; cmp, use R0 temporarily
        push R0
        mov R0, R12
        cmp R0, R9
        pop R0

        blo umull32_for
        b umull32_for_end

    umull32_for:

        bl save_registers

        ; Increment i
        push R7
        mov R7, R9
        add R9, R7, #0x1  ; i++ 
        pop R7

        ; Useful registries for comparisons
        mov R11, #0x1
        mov R10, #0x0

        ; Until we need the R0 and R1 values, store them in stack so we can
        ; pass 3 bit registers into the comparisons
        push R0
        push R1
        mov R0, R10
        mov R1, R11

        ; IF (result & 0x1) == 0 && previous_lsb == 1
        and R12, R4, R11
        cmp R0, R12

        bne umull32_for_else_if_1
        cmp R1, R8
        bne umull32_for_else_if_1

        ; Get the value again to process
        pop R1
        pop R0

        ; IF BODY
        mov R2, R0
        mov R3, R1
        mov R0, #0x0
        mov R1, #0x0

        add R4, R4, R0
        adc R5, R5, R1
        adc R6, R6, R2
        adc R7, R7, R3
        
        b umull32_for_if_end

        umull32_for_else_if_1:
        
            ; Until we need the R0 and R1 values, store them in stack so we can
            ; pass 3 bit registers into the comparisons
            push R0
            push R1
            mov R0, R10
            mov R1, R11

            ; IF (result & 0x1) == 1 && previous_lsb == 0
            and R12, R4, R11
            cmp R1, R12

            bne umull32_for_if_end
            cmp R0, R8
            bne umull32_for_if_end

             ; Get the value again to process
            pop R1
            pop R0

            ; IF BODY
            mov R2, R0
            mov R3, R1
            mov R0, #0x0
            mov R1, #0x0

            sub R4, R4, R0
            sbc R5, R5, R1
            sbc R6, R6, R2
            sbc R7, R7, R3

            b umull32_for_if_end

        umull32_for_if_end:

            and R8, R4, R11

            ; LSR the highest registry and then rotate the rest
            lsr R7, R7, #1
            rrx R6, R6
            rrx R5, R5
            rrx R4, R4

            mov R0, R4
            mov R1, R5
            b umull32_for_condition

        umull32_for_end: 

    bl restore_registers
    mov pc, lr


/**
 * Sets a new random seed given a generated number
 * 
 * Registry mappings:
 * - R0, R1: Parameter (seed)
 * - R2: Seed address
 * - R3: Sum content
 *
 * @param seed A 32-bit integer acting as a seed 
 */
srand:

    bl save_registers

    mov R2, #seed_addr  ; Grab the address of the seed
    add R3, R2, #2  ; Get the MSB index of the seed

    ; Places the R0 contents on R2 (seed addr)
    ; Places the R1 contents on R3 (16 bits after seed)
    str R0, [R2]
    str R1, [R3]

    bl restore_registers
    mov pc, lr


/**
 * Generates a new random number and sets it as the seed
 *
 * Registry mappings:
 * - R0, R1: umull32 parameters/return
 * - R2, R3: umull232 parameters
 * - R4, R5: Seed/Sum values 
 * - R6, R7: Seed addresses
 * - R8, R9: umull32 mod
 * - R10, R11: MAX RAND / 0x00269EC3
 *
 * @return The upper 16 bits of the generated number
 */
rand:

    bl save_registers

    ; Loads the seed address into the R6 register
    ; and calculates the upper bits address
    mov R6, #seed_addr
    add R7, R6, #2

    ; Loads the seed value into the {R4, R5} registers
    ldr R4, [R6]
    ldr R5, [R7]

    ; Sets the multiplicand parameters
    mov R0, R4
    mov R1, R5

    ; Sets the multiplier parameters (214013) (0x000343FD)
    mov R2, #0xFD
    movt R2, #0x43
    mov R3, #0x03

    ; Moves the 2531011 (0x00269EC3) number into a register for later usage
    mov R10, #0xC3
    movt R10, #0x9E
    mov R11, #0x26

    ; Adds the umull32 return value and a constant together
    add R4, R0, R10
    adc R5, R0, R11

    bl umull32

    ; Loads a 32-bit number with the maximum integer limit
    mov R10, #0xFF
    movt R10, #0xFF
    mov R11, #0xFF
    movt R11, #0xFF

    ; Checks if the max rand is higher than the addition
    ; (Check the higher bits first to be faster)
    cmp R5, R11
    bzs if_equal_higher_bits
    b if_not_equal

    ; If the max rand is higher, then check the lower bits
    if_equal_higher_bits:

        cmp R4, R10
        bzs if_equal_lower_bits
        b if_not_equal

        ; If the bits are all equal, then set the mod to 0
        if_equal_lower_bits:

            mov R8, #0x00
            mov R9, #0x00
            b if_end
            
    ; If the bits aren't all equal, then just use {R4, R5}
    if_not_equal:
        mov R8, R4
        mov R9, R5

    if_end:

    ; Loads the calculated value into memory
    str R8, [R6]
    str R9, [R7]

    ; Return the shifted random seed
    mov R1, #0x0
    mov R0, R8

    bl restore_registers
    mov pc, lr


/**
 * Main entrypoint of the program. Generates a new random
 * number until the error flag fires due to a mismatch.
 *
 * Register mappings:
 * - R0, R1: srand and rand parameters
 * - R2: (uint8_t) mismatch_detected variable
 * - R3: (uint16_t) random_number variable
 * - R4: (uint16_t) for loop iterable variable
 * - R5: zero
 * - R6: maximum array size
 * - R7: expected number array address
 * - R8: expected number based on index
 */
main:

    bl save_registers

    ; Initialises the error detection with the 0 flag.
    ; 0 -> No errors
    ; 1 -> Mismatch detected
    mov R2, #0x0
    mov R3, #0x0
    mov R6, #N
    
    ; Call srand(5423)
    mov R0, #0x2E
    movt R0, #0x15 
    bl srand

    ; Start the for loop until there's a mismatch
    mov R4, #0x0  ; i = 0
    b main_for_condition

    main_for_condition:

        ; !(mismatch_detected == 0 && i < N)
        mov R5, #0x0
        cmp R2, R5
        bne main_for_end

        cmp R4, R6
        bhs main_for_end

        ; If the condition succeeds, then go to the body
        beq main_for
        b main_for_end

    main_for:

        ; Load the random number variable with the return value
        bl rand
        mov R3, R0
        
        ; Load the results address array
        mov R7, #results_addr
        ldr R8, [R7, R4]

        cmp R3, R8
        bne mismatch
        b main_for_condition

        mismatch:
            mov R2, #0x1
            b main_for_condition


    main_for_end:

    mov R0, #0x0

    bl restore_registers
    mov pc, lr

/**
 * Save the values on the registers [r4-r12] into the stack
 */
save_registers:
    push r4
    push r5
    push r6
    push r7
    push r8
    push r9
    push r10
    push r11
    push r12
    mov pc, lr

/**
 * Restore the values on the registers [r4-r12] from the stack
 */
restore_registers:
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    mov pc, lr


end:
