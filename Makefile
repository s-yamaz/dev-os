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

all:
	make ipl
	make ./bin/lib.o
	make ./bin/hankaku.o
	make ./bin/bootpack.o
	make sos
	make os.img

$(IMG): $(IPL) $(SOSSYS)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(SOSSYS) -i $(IMG) ::


$(SOSSYS): $(ASRC)/asmhead.s $(ASRC)/func.s $(OBJ)/*.o 
	gcc -m32 $(ASRC)/asmhead.s -nostdlib -T$(HEADLS) -o $(OBJ)/asmhead.bin
	as --32 $(ASRC)/func.s -o $(OBJ)/func.o
	ld  -m elf_i386 -o $(OBJ)/boot.bin --script=$(LS)/boot.ls $(OBJ)/*.o
	cat $(OBJ)/asmhead.bin $(OBJ)/boot.bin > $(SOSSYS)
	
$(OBJ)/%.o: $(CSRC)/%.c
	gcc -m32 $(CSRC)/$*.c -I$(CSRC)/include $(BINOPT) -c -o $(OBJ)/$*.o

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
