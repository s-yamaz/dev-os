.text
.code16
    movb    $0x13, %al          # VGA 320x200x8ビットカラー
    movb    $0x00, %ah
    int     $0x10               # BIOS interrupt call
fin:
    hlt
    jmp fin
