.file "func.s"
.section .text
.global io_hlt

io_hlt:
    hlt
    ret
