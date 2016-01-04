#img: $(IMG:%.img=%.o)
#	ld $^ -T binary.ls -o $(IMG)
IMG=./img/sos.img
IPLSRC=./src/asm/ipl.s
IPLLST=./bin/ipl.lst
SOSSRC=./src/asm/sos.s
SOSSYS=./bin/sos.sys
SOSLST=./bin/sos.lst
LINKER=./src/asm/binary.ls
SOSLS=./src/asm/sos.ls
IPL=./bin/ipl.bin

all: $(IPLSRC)
	make ipl
	make img
	#make run

os.img: $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(SOSSYS) -i $(IMG) ::

sos.sys: $(SOSSRC) $(LINKER)
	gcc -nostdlib -o $(SOSSYS) -T$(SOSLS) $(SOSSRC)
	gcc -T$(SOSLS) -c -g -Wa,-a,-ad $(SOSSRC) > $(SOSLST)

ipl.bin: $(IPLSRC) $(LINKER)
	gcc -nostdlib -o $(IPL) -T$(LINKER) $(IPLSRC)
	gcc -T$(LINKER) -c -g -Wa,-a,-ad $(IPLSRC) > $(IPLLST)

run: $(IMG)
	qemu -m 32 -localtime -vga std -fda $(IMG)

ipl:;	make ipl.bin
img:;	make os.img
