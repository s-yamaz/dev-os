    # FAT12のための記述
    .byte   0xeb, 0x4e, 0x90
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
    
    .byte   0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
    .byte   0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
    .byte   0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
    .byte   0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
    .byte   0xee, 0xf4, 0xeb, 0xfd

# メッセージ部

    .byte   0x0a, 0x0a          # 改行 x 2
    .ascii  "Hello, World"
    .byte   0x0a
    .byte   0

    .org    0x1fe                  # 0x001feまでスキップする

    .byte   0x55, 0xaa

# ブートセクタ以外の部分の記述

    .byte 0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    .org .+4600
    .byte 0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    .org .+1469432
