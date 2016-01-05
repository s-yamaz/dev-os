void io_hlt(void);

void SosMain(void) {
fin:
    io_hlt();
    goto fin;
}
