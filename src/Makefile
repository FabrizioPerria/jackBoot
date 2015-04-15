TARGET = i486-slitaz-linux-
AS     = as
GCC    = gcc
LD     = ld
DD     = dd
ZERO   = /dev/zero
IMAGE  = floppy.img
BIN    = jackBoot.bin
OBJS   = boot.o

all:boot.o floppy
boot.o:
	${TARGET}${AS} boot.s -o boot.o 
floppy:
	${TARGET}${LD} -T linker.ld --oformat=binary ${OBJS} -o ${BIN}    
	${DD} if=${ZERO} of=${IMAGE} bs=512 count=2880
	${DD} if=${BIN} of=${IMAGE}

clean: clean_o
	rm *.bin

clean_o:
	rm *.o
