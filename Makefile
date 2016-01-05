#img: $(IMG:%.img=%.o)
#	ld $^ -T binary.ls -o $(IMG)
OSNAME=sos

ASRC=./src/asm
CSRC=./src/c
OBJ=./bin
LS=./ls

IMG=./img/$(OSNAME).img
IPLSRC=$(ASRC)/ipl.s
SOSSYS=$(OBJ)/sos.sys
SOSSRC=$(ASRC)/sos.s
IPLLS=$(LS)/ipl.ls
HEADLS=$(LS)/asmhead.ls
IPL=$(OBJ)/ipl.bin

BINOPT=-nostdlib -Wl,--oformat=binary

all: $(IPLSRC)
	make ipl
	make sos
	make img

$(IMG): $(IPL) $(SOSSYS)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(SOSSYS) -i $(IMG) ::

$(SOSSYS): $(ASRC)/asmhead.s $(ASRC)/func.s $(CSRC)/bootpack.c
	gcc -m32 $(ASRC)/asmhead.s -nostdlib -T$(HEADLS) -o $(OBJ)/asmhead.bin
	gcc -m32 $(CSRC)/*.c $(BINOPT) -c -o $(OBJ)/boot.o
	as --32 $(ASRC)/func.s -o $(OBJ)/func.o
	ld -static -m elf_i386 -o $(OBJ)/boot.bin -e SosMain --oformat=binary $(OBJ)/boot.o $(OBJ)/func.o
	cat $(OBJ)/asmhead.bin $(OBJ)/boot.bin > $(SOSSYS)

$(IPL): $(IPLSRC)
	gcc -nostdlib -o $(IPL) -T$(IPLLS) $(IPLSRC)

run: $(IMG)
	qemu -m 32 -localtime -vga std -fda $(IMG)

ipl:;	make $(IPL)
sos:;	make $(SOSSYS)
img:;	make $(IMG)
clean:;	rm $(OBJ)/*
