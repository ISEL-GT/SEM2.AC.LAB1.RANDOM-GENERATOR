/*
Código a implementar em C

# define N 5

uint16_t result [ N ] = { 17747 , 2055 , 3664 , 15611 , 9816 };

uint32_t seed = 1;

uint32_t umull32 ( uint32_t M , uint32_t m ) {

    int64_t M_ext = M ;
    int64_t p = m ;
    uint8_t p_1 = 0;

    for ( uint16_t i = 0; i < 32; i ++ ) {
        if ( ( p & 0 x1 ) == 0 && p_1 == 1 ) {
                p += M_ext << 32;
        } else if ( ( p & 0 x1 ) == 1 && p_1 == 0 ) {
        p -= M_ext << 32;
        }
        p_1 = p & 0 x1 ;
        p > >= 1;
    }
    return p ;
}

void srand ( uint32_t nseed ) {

    seed = nseed ;
}

uint16_t rand ( void ) {

    seed = ( umull32 ( seed , 214013 ) + 2531011 ) % RAND_MAX ;
    return ( seed >> 16 ) ;
}

int main ( void ) {

    uint8_t error = 0;
    uint16_t rand_number ;
    uint16_t i ;

    srand ( 5423 ) ;
    for ( i = 0; error == 0 && i < N ; i ++ ) {
        rand_number = rand () ;
        if ( rand_number != result [ i ] ) {
            error = 1;
        }
    }
    return 0;
}
*/



.data

seed:       .word 1, 0
result:     .word 17747 , 2055 , 3664 , 15611 , 9816

.text


;código da seed
ldr r0, seed_addr
ldr r2, [r0]
ldr r2, [r0, #2]


umull32:                    
    push lr
    push r4
    push r5
    push r6
    push r7                 ;guardar os registos r4-r7

    mov r4, r0              ;r4 = M
    mov r5, r1              ;r5 = m
    mov r6, #0              ;p_1 = 0
    mov r7, #32             ;r7 = nº de loops
    mov r8, #1              ;valor temporário de 0x1

loop_umull32:
    and r5, r8              ;operação de AND entre m && 1 
    add r5, r5, #0          ;M + 0 para confirmar se o bit menos significativo é 0 ou 1
    beq check_p1            ;Se r5 = 0, verificar o p1

check_p1:
    cmp r6, r8              ;p_1 == 1
    bne shift_p             ;
    add r5, r5, r4          ;p += p + M
    lsl r5, #32             ;p << 32

