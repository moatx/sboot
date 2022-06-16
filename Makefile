include config.mk
OBJDIR ?= .

all: 
	$(AS) -I ../include -c boot.S -o $(OBJDIR)/boot.o
	$(LD) -s -N -e _start -Ttext 0x7C00 -o $(OBJDIR)/boot.bin boot.o --oformat binary

clean:
	@rm -f *.o *.bin

.PHONY: all clean
