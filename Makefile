include config.mk

#OBJDIR is needed for PortOS
OBJDIR ?= .

all: i386-bios


#arm:
#	$(AS)
#
#arm-test:


i386-bios: 
	$(CC) $(CFLAGS) -I arch/i386/include -c arch/i386/bios/boot.S -o $(OBJDIR)/boot.o
	#$(LD) -s -N -e _start -Ttext 0x7C00 -o $(OBJDIR)/boot.bin $(OBJDIR)/boot.o --oformat binary
	$(LD) -s -N -e start -T arch/i386/bios/linker.ld -o $(OBJDIR)/boot.bin $(OBJDIR)/boot.o --oformat binary

test-i386-bios: i386-bios
	$(CC) $(CFLAGS) -c ./test/$(ARCH)_bios.c -o i386.o
	$(LD) -s -N -e aaa -o i386.bin -Ttext 0x1000 i386.o --oformat binary
	cat boot.bin i386.bin > test.bin
	qemu-system-i386 test.bin




clean:
	@rm -f *.o *.bin

.PHONY: all i386-bios test-i386-bios clean 
