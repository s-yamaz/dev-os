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
	make os.img

$(IMG): $(IPL) $(SOSSYS)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(SOSSYS) -i $(IMG) ::

$(SOSSYS): $(ASRC)/asmhead.s $(ASRC)/func.s $(CSRC)/bootpack.c $(CSRC)/hankaku.c
	gcc -m32 $(ASRC)/asmhead.s -nostdlib -T$(HEADLS) -o $(OBJ)/asmhead.bin
	gcc -m32 $(CSRC)/bootpack.c $(BINOPT) -c -o $(OBJ)/boot.o
	gcc -m32 $(CSRC)/hankaku.c $(BINOPT) -c -o $(OBJ)/hankaku.o
	as --32 $(ASRC)/func.s -o $(OBJ)/func.o
	ld  -m elf_i386 -o $(OBJ)/boot.bin --script=$(LS)/boot.ls -e SosMain --oformat=binary $(OBJ)/boot.o $(OBJ)/func.o $(OBJ)/hankaku.o
	cat $(OBJ)/asmhead.bin $(OBJ)/boot.bin > $(SOSSYS)

$(IPL): $(IPLSRC)
	gcc -nostdlib -o $(IPL) -T$(IPLLS) $(IPLSRC)

run: $(IMG)
	qemu -m 32 -localtime -vga std -fda $(IMG)

ipl:;	make $(IPL)
sos:;	make $(SOSSYS)
os.img:;	make $(IMG)
clean:	
	rm $(OBJ)/*
	rm $(IMG)
