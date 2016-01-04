#img: $(IMG:%.img=%.o)
#	ld $^ -T binary.ls -o $(IMG)
IMG=./img/os.img
IPLSRC=./src/asm/ipl.s
LINKER=./src/asm/binary.ls
IPL=./bin/ipl.bin

all: $(IPLSRC)
	make ipl
	make img
	#make run

os.img: $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::

ipl.bin: $(IPLSRC) $(LINKER)
	gcc -nostdlib -o $(IPL) -T$(LINKER) $(IPLSRC)

run: $(IMG)
	qemu -m 32 -localtime -vga std -fda $(IMG)

ipl:;	make ipl.bin
img:;	make os.img
