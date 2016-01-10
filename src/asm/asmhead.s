.equ    BOTPAK,     0x00280000
.equ    DSKCAC,     0x00100000
.equ    DSKCAC0,    0x00008000

# BOOT INFO
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

# PICが割り込みを受け付けないようにする

    movb    0xff, %al
    outb    %al, $0x21
    nop                         # outは連続して使用しない
    outb    %al, $0xa1
    cli                         # CPUでも割り込み禁止

# CPUから1MB以上のメモリにアクセスできるようにA20互換モードを無効にする
    call    waitkbdout
    movb    $0xd1, %al
    outb    %al, $0x64
    call    waitkbdout
    movb    $0xdf, %al
    outb    %al, $0x60
    call    waitkbdout
# プロテクトモードに移行する
    .arch i486                  # 486の命令まで利用する
    lgdt    (GDTR0)
    movl    %cr0, %eax
    andl    $0x7fffffff, %eax   # ページング禁止
    orl     $0x00000001, %eax   # プロテクトモード移行
    movl    %eax, %cr0
    jmp     pipelineflush
pipelineflush:
    movw    $1*8, %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %fs
    movw    %ax, %gs
    movw    %ax, %ss
# bootpackを転送する
    movl    $bootpack, %esi     # 転送元
    movl    $BOTPAK, %edi       # 転送先
    movl    $512*1024/4, %ecx   # 4で割っているのは4byte単位で処理するため
    call    memcpy
# ブートセクタを転送
    movl    $0x7c00, %esi
    movl    $DSKCAC, %edi
    movl    $512/4, %ecx
    call    memcpy
# ブートセクタ以外の残り全て
    movl    $DSKCAC0+512, %esi  # 転送元
    movl    $DSKCAC+512, %edi   # 転送先
    movl    $0, %ecx
    movb    (CYLS), %cl         # 読み込んだシリンダ数
    imull   $512*18*2/4, %ecx   # シリンダ数からバイト数/4に変換
    subl    $512/4, %ecx        # IPL分引く
    call    memcpy
# bootpackの起動
    movl    $BOTPAK, %ebx
    movl    16(%ebx), %ecx
    addl    $3, %ecx
    shrl    $2, %ecx            # ecx /= 4 shr = SHifit Right
    jz      skip                # 転送するものがない
    movl    20(%ebx), %esi      # 転送元
    addl    %ebx, %esi
    movl    12(%ebx), %edi      # 転送先
    call    memcpy
skip:
    movl    12(%ebx), %esp      # スタック初期位置
    ljmpl   $2*8, $0x0000001b

waitkbdout:
    inb     $0x64, %al
    andb    $0x02, %al
    inb     $0x60, %al          # 元のソースにはないので注意
    jnz     waitkbdout
    ret

memcpy:
    movl    (%esi), %eax
    addl    $4, %esi
    movl    %eax, (%edi)
    addl    $4, %edi
    subl    $1, %ecx
    jnz     memcpy
    ret

.align 16
GDT0:
    .skip   8, 0x00
    .word   0xffff, 0x0000, 0x9200, 0x00cf  # 読み書き可能セグメント32bit
    .word   0xffff, 0x0000, 0x9a28, 0x0047  # 実行可能セグメント32bit

    .word   0x0000

GDTR0:
    .word   8*3-1
    .int    GDT0

.align 16
bootpack:
## + 0 : stack + .data + heapの大きさ(4KBの倍数)
#.int 0x00
## +4: シグネチャ
#.ascii "Simp"
## +8: mmareaの大きさ(4KBの倍数)
#.int 0x00
## +12: スタック初期値 & .data転送先
#.int 0x00310000
## +16: .dataのサイズ
#.int 0x11a8
## +20: .dataの初期値列がファルのどこにあるか
#.int 0x10c8
## +24 +28のセットで1bからの命令がE9 XXXXXXXX(JMP)になり、C言語のエントリポイントへJMP
## +24: 0xe9000000
#.int 0xe9000000
## +28: エントリアドレス-0x20
#.int 0x00
##+32: heap領域(malloc領域)開始アドレス
#.int 0x00
