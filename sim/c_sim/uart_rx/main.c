#include <stdint.h>

#include "../include/uart.h"




int main()
{
    uart_init();
    uart_getc();
    while (1);
}
