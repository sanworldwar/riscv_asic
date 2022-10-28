#include <stdint.h>

#include "../include/uart.h"


// send one char to uart
void uart_putc(uint8_t c)
{
    UART0_REG(UART0_DATA) = c;
}

// Block, get one char from uart.
uint8_t uart_getc()
{
    uint8_t c = UART0_REG(UART0_DATA);
    return c;
}

// 115200bps, 8 1 1 1
void uart_init()
{
    // enable tx and rx
    UART0_REG(UART0_CTRL) = 0x3;

}
