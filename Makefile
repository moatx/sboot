include config.mk
OBJDIR ?= .

all: 
	$(AS) --fatal-warnings --warn -I ../include -c boot.S -o $(OBJDIR)/boot.o
	$(LD) -s -N -e _start -Ttext 0x7C00 -o $(OBJDIR)/boot.bin boot.o --oformat binary

test: all
	$(CC) $(CFLAGS) -c ./test/$(ARCH).c -o i386.o
	$(LD) -s -e main -o i386.bin -Ttext 0x1000 i386.o --oformat binary
	cat boot.bin i386.bin > test.bin




clean:
	@rm -f *.o *.bin

.PHONY: all test clean 
