OUTPUT_FORMAT("binary")

ENTRY("SosMain");

SECTIONS {
    .head 0x0 : {
        LONG(128 * 1024)
        LONG(0x54696e79)
        LONG(0)
        LONG(0x310000)
        LONG(SIZEOF(.data))
        LONG(LOADADDR(.data))
        LONG(0xE9000000)
        LONG(SosMain - 0x20)
        LONG(24 * 1024)
    }
    .text : { *(.text) }
    .data 0x310000 : AT ( ADDR(.text) + SIZEOF(.text) ) {
        *(.data)
        *(.rodata*)
        *(.bss)
    }
    .eh_frame : { *(.eh_frame) }
}
