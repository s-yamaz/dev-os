.equ    CYLS,   0x0ff0          # ブートセクタに設定される読み込みシリンダ数の番地
.equ    LEDS,   0x0ff1
.equ    VMODE,  0x0ff2          # 色数に関する情報。nビットカラー
.equ    SCRNX,  0x0ff4          # 解像度のX (screen x) 
.equ    SCRNY,  0x0ff6          # 解像度のY (screen y)
.equ    VRAM,   0x0ff8          # グラフィックバッファの開始番地

.text
.code16
    movb    $0x13, %al          # VGA 320x200x8ビットカラー
    movb    $0x00, %ah
    int     $0x10               # BIOS interrupt call
    movb    $8, (VMODE)         # 画面モードをメモ
    movw    $320,   (SCRNX)
    movw    $200,   (SCRNY)
    movl    $0x000a0000, (VRAM)

# キーボードのLED状態をBIOSに教えてもらう

    movb    $0x02, %ah
    int     $0x16
    movb    %al, (LEDS)
fin:
    hlt
    jmp fin
