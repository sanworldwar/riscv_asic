ifndef CROSS_COMPILE
CROSS_COMPILE = ../tools/riscv_toolchain/bin/riscv32-unknown-linux-gnu-
endif

CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

CFLAG = -march=rv32i -mabi=ilp32

export CROSS_COMPILE

all: inst_rom.data

%.o: %.S
	$(CC) $(CFLAG) $< -o $@

inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@

inst_rom.bin: inst_rom.om
	$(OBJCOPY) -O binary $< $@

inst_rom.data: inst_rom.bin
	python bin2data.py $<

.PHONY: clean

clean:
	rm -f *.o *.om *.bin *.data

