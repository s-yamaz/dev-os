.file "func.s"
.global io_hlt
.global write_mem8

.arch i486

.section .text

io_hlt:
    hlt
    ret

write_mem8:                 # void write_mem8(int addr, int data)
    movl    4(%esp), %ecx   # [%esp + 4]にaddrが入っているのでそれをecxに読み込む
    movb    8(%esp), %al    # [%esp + 8]にdataが入っているのでそれをALに読む
    movb    %al, (%ecx)
    ret
    
