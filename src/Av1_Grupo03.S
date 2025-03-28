.data

seed:       .word 1, 0
result:     .word 17747 , 2055 , 3664 , 15611 , 9816

.text


;código da seed
;ldr r0, seed_addr
;ldr r2, [r0]
;ldr r2, [r0, #2]


umull32:                    
    push lr
    push r4
    push r5
    push r6
    push r7     
    push r8 
    push r9
    push r10
    push r11
    push r12          
                            ;r[4-7] = M_ext
    mov r4, r0             
    mov r5, r1             
    mov r6, #0             
    mov r7, #0
                            ;r[8-11] = p
    mov r8, r2
    mov r9, r3
    mov r10, #0
    mov r11, #0
                            ;r12 = p_1
    mov r12, #0
    mov r0, #0              ;r0 = i = 0
loop_umull32:               ;for (i in 0..32)
                 
    mov r1, #32             ;r1 = i = 32
    cmp r1, r0              ;i == 32
    blo first_if
    b end_loop              

first_if:
    mov r2, #1
    mov r3, r8                   
    cmp r3, r2              ;p == 1
    bne check_p1_1          ;Se p == 1, saltar if; Se p == 0, p and 1 = 0 e segue o if
    b check_p1_0


check_p1_1:
    cmp r2, r12             ;p_1 == 1
    bne shift_p             ;saltar if
    add r8, r4, r10         ;p += p + M << 32
    adc r9, r5, r11
    b shift_p

check_p1_0:
    
    cmp r2, r12             ;p_1 == 1
    beq shift_p             ;saltar if
    mov r3, r8              
    sub r3, r3, r4          ;p -= M_ext << 32
    mov r8, r3
    mov r3, r9
    sbc r3, r3, r5
    mov r9, r3 
    b shift_p 


shift_p:
    and r12, r2, r8         ;p_1 = p and 0x1

    mov r3, r8              ;p[0 regist] >> 1 
    lsr r3, r3, #1
    mov r8, r3

    mov r3, r9              ;p[1 regist] >> 1
    rrx r3, r3
    mov r9, r3

    mov r3, r10             ;p[2 regist] >> 1
    rrx r3, r3
    mov r10, r3
    
    mov r3, r11             ;p[3 regist] >> 1
    rrx r3, r3
    mov r11, r3

    add r0, r0, #1          ;i++
    b loop_umull32          ;for (i in 0..32)

end_loop:
    mov r0, r8
    mov pc, lr

