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

.file	"stage1.S"

#include <asm.h>

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

	/* set up stack */
	mov $0x7b00, %ax
  	mov %ax, %sp
	
	mov $stage2, %bx

        mov (BOOT_DRIVE), %dl
        mov $0x02, %ah
        mov %dh, %al
	mov $0x02, %cl
	mov $0x00, %ch
	mov $0x00, %dh
	int $0x13
	ret


  /* should not return but if it does lets have a infinite loop */
  jmp .

	
.section .stage2
stage2:
   	 hlt
	 jmp .

