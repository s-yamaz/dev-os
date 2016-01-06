.file "func.s"
.global io_hlt
.global write_mem8

.arch i486

.section .text

io_hlt:
    hlt
    ret
