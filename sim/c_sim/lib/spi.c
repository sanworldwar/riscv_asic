#include <stdint.h>

#include "../include/spi.h"


void spi_init()
{
    SPI_REG(SPI_CTRL) = 0b00110111;      // en = 1, CPOL = 1, CPHA = 1,  nss = 10, div = 001
}


void spi_write_byte(uint8_t data)
{
    SPI_REG(SPI_DATA) = data;
}

void spi_write_bytes(uint8_t data[], uint32_t len)
{
    uint32_t i;

    for (i = 0; i < len; i++)
        spi_write_byte(data[i]);
}

uint8_t spi_read_byte()
{
    uint8_t data;

    data = SPI_REG(SPI_DATA);       // readback data

    return data;
}

void spi_read_bytes(uint8_t data[], uint32_t len)
{
    uint32_t i;

    for (i = 0; i < len; i++)
        data[i] = spi_read_byte();
}
