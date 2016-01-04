.code16
.text
    jmp entry

    # FAT12のための記述
    .byte   0x90
    .ascii  "HELLOIPL"          # ブートセクタの名前
    .word   512                 # 1セクタの大きさ(512にしなければならない)
    .byte   1                   # クラスタの大きさ(1セクタにしなければならない)
    .word   1                   # FATがどこから始まるか(通常は1セクタ目からにする)
    .byte   2                   # FATの個数(2にしなければならない)
    .word   224                 # ルートディレクトリ領域の大きさ(通常は224エントリにする)
    .word   2880                # このドライブの大きさ(2880セクタにしなければならない)
    .byte   0xf0                # メディアのタイプ(0xf0にしなければいけない)
    .word   9                   # FAT領域の長さ(9セクタにしなければいけない)
    .word   18                  # 1トラックにいくつのセクタがあるか(18にしなければいけない)
    .word   2                   # ヘッドの数(2にしなければならない)
    .long   0                   # パーティションを使ってないので0
    .long   2880                # このドライブの大きさをもう一度記述
    .byte   0, 0, 0x29          # よくわからないけど、この値にしておくといいらしい
    .long   0xffffffff          # ボリュームシリアル番号(多分)
    .ascii  "HELLO-OS   "       # ディスクの名前(11bytes)
    .ascii  "FAT12   "          # フォーマットの名前(8bytes)
    .org    .+18

# プログラム本体
entry:
    movw    $0, %ax                # レジスタの初期化
    movw    %ax, %ss
    movw    $0x7c00, %sp
    movw    %ax, %ds
    movw    %ax, %es

    movw    $0x0820, %ax
    movw    %ax, %es
    movb    $0x00, %ch          # Cylinder 0
    movb    $0x00, %dh          # Head 0
    movb    $0x02, %cl          # Sector 2

    movb    $0x02, %ah          # ディスク読み込み
    movb    $0x01, %al          # 1セクタ読み込む
    movw    $0x00, %bx          # ES:BX Data buffer(0x8200に読み込む)
    movb    $0x00, %dl          # Aドライブ
    int     $0x13               # BIOS interrupt call
    jc      error
fin:
    hlt
    jmp    fin

error:
    movw    $msg, %si
putloop:
    movb    (%si), %al
    addw    $1, %si
    cmpb    $0, %al
    je      fin
    movb    $0x0e, %ah              # 一文字表示BIOSコール
    movw    $10, %bx                # カラーコード 15: white
    int     $0x10                   # ビデオBIOS呼び出し
    jmp    putloop

.data
msg: 
    .string "\n\nload error!\n"
