.file	"stage1.S"
.code16

start
    cli
    /* Set %cs to 0. */
    ljmp $0, $1f
    1:
    xor %ax, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %bp
    mov %ax, %ss
    mov %bp, %sp
    /* Store the initial dl to load stage 2 later on. */
    mov %dl, initial_dl
    jmp after_locals
    initial_dl: .byte 0
after_locals:
