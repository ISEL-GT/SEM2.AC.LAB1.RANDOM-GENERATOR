#include <cstdint>  // Biblioteca que fornece tipos inteiros com largura definida.
#define N 5          // Define uma constante N que representa o tamanho do array.

uint16_t expected_numbers[N] = {17747, 2055, 3664, 15611, 9816};  
// Array com 5 valores esperados para verificação no final.

uint32_t random_seed = 1;  
// Variável global que armazena a semente para o gerador de números pseudoaleatórios.

uint32_t multiply_and_shift(uint32_t multiplicand, uint32_t multiplier) {
    // Função que faz multiplicação e operações de deslocamento de bits simulando um processo pseudoaleatório.

    int64_t extended_multiplicand = multiplicand;  // Expande o multiplicando para 64 bits.
    int64_t result = multiplier;                   // Expande o multiplicador para 64 bits.
    uint8_t previous_lsb = 0;                      // Armazena o bit menos significativo anterior.

    // Laço que faz 32 iterações, realizando operações aritméticas e lógicas.
    for (uint16_t i = 0; i < 32; i++) {
        // Se o bit menos significativo for 0 e o anterior foi 1:
        if ((result & 0x1) == 0 && previous_lsb == 1) {
            result += extended_multiplicand << 32;  // Acrescenta o multiplicando deslocado 32 bits à esquerda.
        }
        // Se o bit menos significativo for 1 e o anterior foi 0:
        else if ((result & 0x1) == 1 && previous_lsb == 0) {
            result -= extended_multiplicand << 32;  // Subtrai o multiplicando deslocado 32 bits à esquerda.
        }

        previous_lsb = result & 0x1;  // Atualiza o bit menos significativo anterior.
        result >>= 1;                 // Desloca o valor resultante 1 bit à direita.
    }

    return result;  // Retorna o valor calculado após 32 iterações.
}

void set_random_seed(uint32_t new_seed) {
    // Função que inicializa a semente do gerador de números pseudoaleatórios.
    random_seed = new_seed;
}

uint16_t generate_random_number(void) {
    // Função que gera um número pseudoaleatório de 16 bits usando um algoritmo LCG (Linear Congruential Generator).

    random_seed = (multiply_and_shift(random_seed, 214013) + 2531011) % RAND_MAX;  
    // Atualiza a semente usando uma fórmula linear congruente.
    return (random_seed >> 16);  // Retorna os 16 bits superiores da nova semente.
}

int main(void) {
    uint8_t mismatch_detected = 0;  // Flag que verifica se houve alguma discrepância durante o teste.
    uint16_t random_number;         // Variável que armazenará o número aleatório gerado.
    uint16_t i;                     // Índice para o laço.

    set_random_seed(5423);  // Inicializa a semente com o valor 5423.

    // Laço que gera números aleatórios e compara com os valores esperados.
    for (i = 0; mismatch_detected == 0 && i < N; i++) {
        random_number = generate_random_number();  // Gera um número aleatório.
        if (random_number != expected_numbers[i]) {
            mismatch_detected = 1;  // Se o número não coincidir, marca o erro.
        }
    }

    return 0;  // Retorna 0 indicando execução bem-sucedida.
}
