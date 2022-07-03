/*-
 * Copyright 2021 moatx. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

.file	"boot.S"

/* TODO: make this work with all bioses */

#include <asm.h>

#define KOFFSET 0x1000

.code16 /* excute code as 16 bit instructions */

ENTRY(start)
  /* fix code segment */
  ljmp $0x0,$main
  jmp .

main:

	/* clear interuppts and descriptors to not have any problems with some bioses */
	cli
	cld
	
	/* remember boot drive */
	mov %dl, BOOT_DRIVE 
	
	
	/* set segment registers to 0 */
	xorw    %ax,%ax             
	movw    %ax,%ds 
	movw    %ax,%es             
	movw    %ax,%ss             

	/* set up stack because stage2 will depend on this */
	mov $0x7b00, %ax
  	mov %ax, %sp

	/* put what we read to the memory location of the label stage2 */	
	mov $stage2, %bx
	/* read sectors into memory */
	mov $2, %ah 
	/* Number of sectors (512 bytes) to read. */
	mov $1, %al /* just 1 sector to read because why would it be in 2? */
	
	/* cylinder number */
	mov $0, %ch
	/* Head number */
	mov $0, %dh /* first head because its the only one that has stage2 */
	/* starting sector number. 2 because the first sector is the boot sector. */
	mov $2, %cl
	
	/* it'll only read sector number 2 */
	int $0x13

	call stage2

	/* should not return but if it does lets have a infinite loop */
	jmp .

.fill (510-(.-start)) /* fill 510 bytes with 0s */
BIOS_NUMBER: .word 0xAA55 /* BIOS MAGIC NUMBER */
	
.section .stage2
stage2:
	/* clear interuppts and descriptors to not have any problems with some bioses */
	cli
	cld

	mov $MSG_STAGE2_LOADED, %bx
	call rprint

/* enable the a20 line for 20th bit */
seta20:
	mov $MSG_CHECK_A20, %bx
	call rprint
	
	call wait_kbd
	
	movb    $0xd1, %al               /* 0xd1 -> port 0x64 */
	outb    %al, $0x64		   /* set command write to keyboard controller bit 1 */
	
	call wait_kbd
	
	movb    $0xdf, %al               /* 0xdf -> port 0x60 */
	outb    %al, $0x60		    /* enable A20 line */

	in $0x92, %al
	or $2, %al
	out %al, $0x92

load_kernel:
	mov $KOFFSET, %bx

	/* read sectors into memory */
        mov $0x02, %ah
	/* Number of sectors (512 bytes) to read. */
	mov $16, %al /* 16 because we dont know how big the kernel is and the only way to know how big it is to calculate it manually or use a fs */

	/* starting sector number. 3 because the first sector is the boot sector. */
	mov $0x03, %cl /* read the 3rd sector one time */

	/* cylinder number */
	mov $0x00, %ch

	/* Head number */
	mov $0x00, %dh
	int $0x13

jump2protected:

 /* load gdt for protected mode */
  lgdt gdtdescr
  mov $MSG_CHECK_GDT, %bx
  call rprint

  /* this bit needs to be switched on to go to 32 bit protected mode */
  /* FIXME: the problem seems to be here */
  movl %cr0, %eax
  orl $0x1, %eax
  movl %eax, %cr0

/*
  mov %cr0, %eax
  or $0x1, %eax
  mov %eax, %cr0
*/



  /* finnaly long jump into a label in 32 bit protected mode to reload %cs and %eip (inscrution pointer) */
  ljmp $0x08, $_start32 /* 0x08 is gdt code segment */

  mov $MSG_ERROR_JUMP, %bx
  call rprint

  /* should not return but if it does lets have a infinite loop */
  jmp .

/*
.code16
*/

/* GDT */
gdt_start:
gdt_null:
    .long 0x0
    .long 0x0
gdt_code:
    .word 0xffff
    .word 0x0
    .byte 0x0
    .byte 0b10011010
    .byte 0b11001111
    .byte 0x0
gdt_data:
    .word 0xffff
    .word 0x0
    .byte 0x0
    .byte 0b10010010
    .byte 0b11001111
    .byte 0x0
gdt_end:
gdtdescr:
    .word gdt_end - gdt_start
    .long gdt_start
.set CODE_SEG, gdt_code - gdt_start

/* FUNCTIONS */
wait_kbd:
	nop
    	inb $0x64, %al	/* wait until its not busy */
    	testb $0x2, %al
    	jnz wait_kbd
    	ret

/* real mode print */
rprint:
	pusha
	mov $0x0e, %ah
	1: 
		mov (%bx), %al
		
		cmp $0, %al
		je 1f
		
		int $0x10
		add $1, %bx
		jmp 1b
	1:
		popa
		ret

	
	
/* VARIABLES */
BOOT_DRIVE: .byte 0

/* MESSAGES */
MSG_STAGE2_LOADED: .asciz "stage2 has been loaded in 16 bit real mode \n \r"

MSG_CHECK_A20: .asciz "in A20 \n \r"
MSG_CHECK_GDT:	.asciz "loaded the gdt \n \r"
MSG_CHECK_LOAD: .asciz "in load_kernel \n \r"

MSG_ERROR_JUMP: .asciz "ERROR: did not jump to protected mode \n \r"
MSG_ERROR_READ: .asciz "ERROR: could not read disk \n \r"




.code32
DATA_SEG: .long (gdt_data - gdt_start)
_start32:

  /* setup 32 bit segment registers */
  movw DATA_SEG, %ax
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %fs
  movw %ax, %gs
  movw %ax, %ss

  mov $0x90000, %ebp
  mov %ebp, %esp


  call KOFFSET

  /* should not return but if it does lets have a infinite loop */
  jmp .




