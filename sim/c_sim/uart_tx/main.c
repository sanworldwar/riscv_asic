#include <stdint.h>

#include "../include/uart.h"




int main()
{
    uart_init();

    uart_putc(0x27);

    while (1);
}
