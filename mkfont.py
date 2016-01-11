#!/usr/bin/python
# -*- coding: utf-8 -*-
# mkfont *** The Python Script making C source from font source file ***
# Usage ./mkfont [font src] (-o [c src file])
import sys

def caution(msg) :
    print msg
    exit()

usage = "usage: ./mkfont [font src] (-o [c src file])"
error = "error: ./mkfont --help"

data = [0] * (16 * 256)

argv = sys.argv
argc = len(argv)

# show help
if argv[-1] == "--help" : caution(usage)
# too few argument
if argc < 2 : caution(error)
# wrong argument
if argv[1] == "-o" : caution(error)
# open font source file
src = open(argv[1], "r")
# open c source file
if argc >= 4 :
    if argv[2] == "-o" :
        dst = open(argv[3], "w")
else :
    dst = open("font.c", "w")

i = 0
c = 0

# フォントソースファイルを1行ずつ読む
for line in src :
    if i > 0 :
        tmp = 0 # 横1列の16進数データ
        j = 7
        while j >= 0 :
            # "*" -> 1, "." -> 0に変換する
            if line[j] == "*" :
                tmp += (1 << (7 - j))
            j -= 1
        data[ c * 16 + (16 - i) ] = tmp
        i -= 1
    # 文字コードを取得
    if line[0:4] == "char" :
        i = 16
        c = int(line[7:9], 16)

code = "char hankaku[4096] = {"
i = 0
for d in data :
    if i != 0 : code += ","
    if i % 16 == 0 : code += "\n\t"
    code += (hex(d))
    i += 1
code += "\n};"
dst.write(code)

src.close()
dst.close()
