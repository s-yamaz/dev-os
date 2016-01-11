#include <prot.h>
#define COL8_000000 0
#define COL8_FF0000 1
#define COL8_00FF00 2
#define COL8_FFFF00 3
#define COL8_0000FF 4
#define COL8_FF00FF 5
#define COL8_00FFFF 6
#define COL8_FFFFFF 7
#define COL8_C6C6C6 8
#define COL8_840000 9
#define COL8_008400 10
#define COL8_848400 11
#define COL8_000084 12
#define COL8_840084 13
#define COL8_008484 14
#define COL8_848484 15

void io_hlt(void);
void io_cli(void);
void io_out8(int port, int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);
void boxfill8(unsigned char *vram, int xsize,
        unsigned char c, int x0, int y0, int x1, int y1);
void putfont8(char *vram, int xsize, int x, int y, char c, char *font);
void putfont8_asc(char *vram, int xsize, int x, int y, char c, unsigned char *s);
void init_screen(char *vram, int xsize, int ysize);
void init_mouse_curor8(char *mouse, char bc);
void putblock8_8(char *vram, int vxsize, int pxsize,
        int pysize, int px0, int py0, char *buf, int bxsize);

struct BOOTINFO {
    char cyls, leds, vmode, reserve;
    short scrnx, scrny;
    char *vram;
};

void SosMain(void) {
    struct BOOTINFO *binfo = (struct BOOTINFO *) 0x0ff0;
    char s[40], mcursor[256];
    int mx, my;

    init_palette(); /* 色パレットを設定 */
    init_screen(binfo -> vram, binfo -> scrnx, binfo -> scrny);
    mx = (binfo->scrnx - 16) / 2;
    my = (binfo->scrny - 28 - 16) / 2;
    init_mouse_cursor8(mcursor, COL8_008484);
    putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);
    lsprintf(s, "(%d, %d)", mx, my);
    putfont8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

    for (;;) {
        io_hlt();
    }
}

void init_palette(void) {
    static unsigned char table_rgb[16 * 3] = {
        0x00, 0x00, 0x00,   /* brack */
        0xff, 0x00, 0x00,   /* red */
        0x00, 0xff, 0x00,   /* green */
        0xff, 0xff, 0x00,   /* yellow */
        0x00, 0x00, 0xff,   /* blue */
        0xff, 0x00, 0xff,   /* purple */
        0x00, 0xff, 0xff,   /* sky */
        0xff, 0xff, 0xff,   /* white */
        0xc6, 0xc6, 0xc6,   /* gray */
        0x84, 0x00, 0x00,   /* dark red */
        0x00, 0x84, 0x00,   /* dark green */
        0x84, 0x84, 0x00,   /* dark yellow */
        0x00, 0x00, 0x84,   /* dark blue */
        0x84, 0x00, 0x84,   /* dark purple */
        0x00, 0x84, 0x84,   /* dark sky */
        0x84, 0x84, 0x84,   /* dark gray */
    };
    set_palette(0, 15, table_rgb);
    return;
}

void set_palette(int start, int end, unsigned char *rgb) {
    int i, eflags;
    eflags = io_load_eflags(); /*割り込み許可フラグの値を記録する*/
    io_cli(); /* 許可フラグを0にして割り込み禁止にする */
    io_out8(0x03c8, start);
    for(i = start; i <= end ; i++) {
        io_out8(0x3c9, rgb[0] / 4);
        io_out8(0x3c9, rgb[1] / 4);
        io_out8(0x3c9, rgb[2] / 4);
        rgb += 3;
    }
    io_store_eflags(eflags);
    return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c,
        int x0, int y0, int x1, int y1) {
    int x, y;
    for (y = y0; y <= y1 ; y++) {
        for(x = x0 ; x < x1 ; x++) {
            vram[y * xsize + x] = c;
        }
    }
    return;
}

void init_screen(char *vram, int xsize, int ysize) {

    boxfill8(vram, xsize, COL8_008484, 0, 0, xsize - 1, ysize - 29);
    boxfill8(vram, xsize, COL8_C6C6C6, 0, ysize - 28, xsize - 1, ysize - 28);
    boxfill8(vram, xsize, COL8_FFFFFF, 0, ysize - 27, xsize - 1, ysize - 27);
    boxfill8(vram, xsize, COL8_C6C6C6, 0, ysize - 26, xsize - 1, ysize - 1);

    // スタートボタン
    boxfill8(vram, xsize, COL8_FFFFFF, 3, ysize - 24, 59, ysize - 24);
    boxfill8(vram, xsize, COL8_FFFFFF, 2, ysize - 24, 2, ysize - 4);
    boxfill8(vram, xsize, COL8_848484, 3, ysize - 4, 59, ysize - 4);
    boxfill8(vram, xsize, COL8_848484, 59, ysize - 23, 59, ysize - 5);
    boxfill8(vram, xsize, COL8_000000, 2, ysize - 3, 59, ysize - 3);
    boxfill8(vram, xsize, COL8_000000, 60, ysize - 24, 60, ysize - 3);

    // 時刻表示領域
    boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 24, xsize - 4, ysize - 24);
    boxfill8(vram, xsize, COL8_848484, xsize - 47, ysize - 23, xsize - 47, ysize - 4);
    boxfill8(vram, xsize, COL8_FFFFFF, xsize - 47, ysize - 24, xsize - 4, ysize - 3);
    boxfill8(vram, xsize, COL8_FFFFFF, xsize - 3, ysize - 24, xsize - 3, ysize - 3);
    return;
}

void putfont8(char *vram, int xsize, int x, int y, char c, char *font) {
    int i;
    char *p, d;
    for (i = 0 ; i < 16 ; i++) {
        p = vram + (y + i) * xsize + x;
        d = font[i];
        if( (d & 0x80) != 0) { p[0] = c; }
        if( (d & 0x40) != 0) { p[1] = c; }
        if( (d & 0x20) != 0) { p[2] = c; }
        if( (d & 0x10) != 0) { p[3] = c; }
        if( (d & 0x08) != 0) { p[4] = c; }
        if( (d & 0x04) != 0) { p[5] = c; }
        if( (d & 0x02) != 0) { p[6] = c; }
        if( (d & 0x01) != 0) { p[7] = c; }
    }
    return;
}

void putfont8_asc(char *vram, int xsize, int x, int y, char c, unsigned char *s) {
    extern char hankaku[4096];
    for(; *s != 0x00 ; s++) {
        putfont8(vram, xsize, x, y, c, hankaku + *s * 16);
        x += 8;
    }
    return;
}

void init_mouse_cursor8(char *mouse, char bc){
    static char cursor[16][16] = {
        "**************..",
        "*OOOOOOOOOOO*...",
        "*OOOOOOOOOO*....",
        "*OOOOOOOOO*.....",
        "*OOOOOOOO*......",
        "*OOOOOOO*.......",
        "*OOOOOOO*.......",
        "*OOOOOOOO*......",
        "*OOOO**OOO*.....",
        "*OOO*..*OOO*....",
        "*OO*....*OOO*...",
        "*O*......*OOO*..",
        "**........*OOO*.",
        "*..........*OOO*",
        "............*OO*",
        ".............***"
    };
    int x, y;

    for(y = 0 ; y < 16 ; y++){
        for(x = 0 ; x < 16 ; x++){
            if(cursor[y][x] == '*') {
                mouse[y * 16 + x] = COL8_000000;
            }
            if(cursor[y][x] == 'O'){
                mouse[y * 16 + x] = COL8_FFFFFF;
            }
            if(cursor[y][x] == '.'){
                mouse[y * 16 + x] = bc;
            }
        }
    }
    return;
}

void putblock8_8(char *vram, int vxsize, int pxsize,
        int pysize, int px0, int py0, char *buf, int bxsize){
    int x, y;
    for(y = 0 ; y < pysize ; y++){
        for(x = 0 ; x < pxsize; x++){
            vram[(py0 + y) * vxsize + (px0 + x)] = buf[y * bxsize + x];
        }
    }
    return;
}
