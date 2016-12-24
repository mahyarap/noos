AS = as
LD = ld

all: noos.img

noos.img: noos.o
	$(LD) --omagic --oformat=binary --Ttext=0x7C00 -o $@ $^

noos.o: noos.s
	$(AS) -o $@ $^

clean:
	-rm -f *.o
	-rm -f noos.img

.PHONY: clean
