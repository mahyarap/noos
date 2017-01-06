CC = gcc
LD = ld

targets = helloworld.img guess.img

all: $(targets)

%.img: %.o
	$(LD) --omagic --oformat=binary --Ttext=0x7C00 -o $@ $<

%.o: %.S
	$(CC) -c -o $@ $<

clean:
	-rm -f *.o
	-rm -f $(targets)

.PHONY: clean
