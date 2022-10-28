ifndef CROSS_COMPILE
CROSS_COMPILE = ../../tools/riscv_toolchain/bin/riscv32-unknown-elf-
endif

CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

CFLAG = -march=rv32im -mabi=ilp32


.PHONY: clean

all:  inst_rom.data inst_rom.objdump

%.o: %.S
	$(CC) $(CFLAG) $< -o $@

inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@

inst_rom.bin: inst_rom.om
	$(OBJCOPY) -O binary $< $@

inst_rom.data: inst_rom.bin bin2divide_data.py
	python bin2divide_data.py $<

inst_rom.objdump: $(OBJECTS)
	$(OBJDUMP) -d $< > $@

clean:
	rm -f *.o *.om *.bin inst*.data