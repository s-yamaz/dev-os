.file "func.s"
.global io_hlt
.global io_cli
.global io_in8, io_in16, io_in32
.global io_out8, io_out16, io_out32
.global io_load_eflags, io_store_eflags
.global write_mem8

.global load_gdtr, load_idtr

.arch i486

.section .text

io_hlt:
    hlt
    ret

io_cli:             # void io_cli
    cli
    ret

io_sti:
    sti
    ret

io_stihlt:
    sti
    hlt
    ret

io_in8:
    movl    4(%esp), %edx
    movl    $0, %eax
    inb     %dx, %al
    ret

io_out8:
    movl    4(%esp), %edx   # port
    movl    8(%esp), %eax   # data
    outb    %al, %dx
    ret

io_in16:
    movl    4(%esp), %edx
    movl    $0, %eax
    inw     %dx, %ax
    ret

io_out16:
    movl    4(%esp), %edx
    movl    8(%esp), %eax
    outw    %ax, %dx
    ret

io_in32:
    movl    4(%esp), %edx
    inl     %dx, %eax

io_out32:
    movl    4(%esp), %edx
    movl    8(%esp), %eax
    outl    %eax, %dx
    ret

io_load_eflags:
    pushfl
    pop     %eax
    ret

io_store_eflags:
    movl    4(%esp), %eax
    push    %eax
    popfl
    ret

load_gdtr:
    movw    4(%esp), %ax    #limit
    movw    %ax, 6(%esp)
    lgdtl   6(%esp)
    ret

load_idtr:
    movw    4(%esp), %ax
    movw    %ax, 6(%esp)
    lidtl   6(%esp)
    ret
