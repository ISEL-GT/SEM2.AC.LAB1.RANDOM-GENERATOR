#include <cstdint>
# define N 5

uint16_t result [ N ] = { 17747 , 2055 , 3664 , 15611 , 9816 };

uint32_t seed = 1;

uint32_t umull32 ( uint32_t M , uint32_t m ) {

    int64_t M_ext = M ;
    int64_t p = m ;
    uint8_t p_1 = 0;

    for ( uint16_t i = 0, i < 32, i ++ ) {
        if ( ( p & 0x1 ) == 0 && p_1 == 1 ) {
                p += M_ext << 32;
        } else if ( ( p & 0x1 ) == 1 && p_1 == 0 ) {
        p -= M_ext << 32;
        }
        p_1 = p & 0x1 ;
        p >> = 1;
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
    for ( i = 0, error == 0 && i < N, i ++ ) {
        rand_number = rand () ;
        if ( rand_number != result [ i ] ) {
            error = 1;
        }
    }
    return 0;
}