#include <stdint.h>

#include "../include/spi.h"



int main()
{
    spi_init();
    spi_write_byte(0x76);

    while (1);
}
