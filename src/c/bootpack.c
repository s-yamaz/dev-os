void io_hlt(void);

void SosMain(void) {
    int i;
    char *p;

    for (i = 0xa0000; i <= 0xaffff; i++) {
        p = (char*) i; /* 番地を代入 */
        *p = i & 0x0f;
    }
    for (;;) {
        io_hlt();
    }
}
