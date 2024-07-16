#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>  // malloc y free

#define DIM_GIGA 268435456      // 2^28 * 4 bytes       => 1 GiB
#define DIM_MEGA 262144         // 2^18 * 4 bytes * 2   => 2 MiB
#define DIM_KILO 256            // 2^8 * 4 bytes * 4    => 4 KiB

// PTE structure based on Sv39
typedef struct {
    uint64_t valid : 1;       // Bit 0
    uint64_t read : 1;        // Bit 1
    uint64_t write : 1;       // Bit 2
    uint64_t execute : 1;     // Bit 3
    uint64_t user : 1;        // Bit 4
    uint64_t global : 1;      // Bit 5
    uint64_t accessed : 1;    // Bit 6
    uint64_t dirty : 1;       // Bit 7
    uint64_t ppn : 44;        // Bits 8-51 (assumes Sv39 44-bit PPN)
    uint64_t reserved : 10;   // Bits 52-63 (reserved for software)
} PTE;

void print_pte(PTE pte) {
    printf("PTE:\n");
    printf("Valid: %u\n", pte.valid);
    printf("Read: %u\n", pte.read);
    printf("Write: %u\n", pte.write);
    printf("Execute: %u\n", pte.execute);
    printf("User: %u\n", pte.user);
    printf("Global: %u\n", pte.global);
    printf("Accessed: %u\n", pte.accessed);
    printf("Dirty: %u\n", pte.dirty);
    printf("PPN: 0x%" PRIX64 "\n", (unsigned long) pte.ppn);  // Hexadecimal formatting for clarity
}

// Función para obtener los n bits más significativos
uint64_t get_n_most_significant_bits(uint64_t value, int n) {
    uint64_t mask = (1ULL << n) - 1;
    return (value >> (64 - n)) & mask;
}


void initialize_PTE(PTE* pte_vector, uint64_t* g_data, PTE* pte_mega, PTE* pte_kilo)
{
    // First PTE points to a 1 GiB structure, RWX != 000 & V = 1
    pte_vector[0] = (PTE) 
    {  
        .valid = 1,
        .read = 1,
        .write = 0,
        .execute = 0,
        .user = 0,
        .global = 0,
        .accessed = 0,
        .dirty = 0,
        .ppn = get_n_most_significant_bits((uintptr_t) g_data, 44)
    };

    // Second PTE points to a PTE that points to a 2 MiB structure, RWX = 000 & V = 1
    pte_vector[1] = (PTE){
        .valid = 1,
        .read = 0,
        .write = 0,
        .execute = 0,
        .user = 0,
        .global = 0,
        .accessed = 0,
        .dirty = 0,
        .ppn = get_n_most_significant_bits(pte_mega->ppn, 44)
    };

    // Third PTE points to a PTE that points to another PTE that points to a 4 KiB structure, RWX = 000 & V = 1
    pte_vector[2] = (PTE){
        .valid = 1,
        .read = 1,
        .write = 1,
        .execute = 1,
        .user = 0,
        .global = 0,
        .accessed = 0,
        .dirty = 0,
        .ppn = get_n_most_significant_bits(pte_kilo->ppn, 44)
    };
}

int main() 
{
    // Create the PTE vector
    PTE pte_vector[3];

    //uint64_t g_data[DIM_GIGA];  // Data Giga
    //uint64_t m_data[DIM_GIGA];  // Data Mega
    //uint64_t k_data[DIM_GIGA];  // Data Kilo

    // Memory allocation for data arrays (using malloc to avoid stack overflow)
    uint64_t* g_data = malloc(DIM_GIGA * sizeof(uint64_t));
    uint64_t* m_data = malloc(DIM_MEGA * sizeof(uint64_t));
    uint64_t* k_data = malloc(DIM_KILO * sizeof(uint64_t));

    // PTEs for the next levels (2 MiB and 4 KiB structures)
    PTE pte_mega = {
        .valid = 1,
        .read = 1,
        .write = 1,
        .execute = 1,
        .user = 0,
        .global = 0,
        .accessed = 0,
        .dirty = 0,
        .ppn = get_n_most_significant_bits((uintptr_t) m_data, 44)
    };

    PTE pte_kilo = {
        .valid = 1,
        .read = 1,
        .write = 1,
        .execute = 1,
        .user = 0,
        .global = 0,
        .accessed = 0,
        .dirty = 0,
        .ppn = get_n_most_significant_bits((uintptr_t) k_data, 44)
    };

    PTE *pte_address_mega = &pte_mega;      // ptr that will point to the Mega structure
    PTE *pte_address_kilo = &pte_kilo;      // ptr that will point to the Kilo structure

    // Initialize PTEs
    initialize_PTE(pte_vector, g_data, pte_address_mega, pte_address_kilo);

    printf("Giga addr: 0x%lX\n", (unsigned long) g_data); 
    printf("Mega addr: 0x%lX\n", (unsigned long) m_data); 
    printf("Kilo addr: 0x%lX\n", (unsigned long) k_data); 

    // Print all PTEs
    for (int i = 0; i < 3; ++i) {
        printf("PTE Vector [%d]:\n", i);
        print_pte(pte_vector[i]);
        printf("\n");
    }

    // Print the example PTEs for the next levels
    printf("PTE for Mega (2 MiB) structure:\n");
    print_pte(pte_mega);
    printf("\n");

    printf("PTE for Kilo (4 KiB) structure:\n");
    print_pte(pte_kilo);
    printf("\n");
    

    return 0;    
}
