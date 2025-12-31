ACME ?= acme
EMU  ?= x64sc

TARGET := viewer.prg
SRC    := main.asm

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SRC) chabuduo.bin
	$(ACME) -f cbm -o $@ $<

run: $(TARGET)
	$(EMU) -autostart $(TARGET)

clean:
	rm $(TARGET)

chabuduo.bin: tools/chabuduo.txt
	iconv -f UTF-8 -t gb2312 < $< > $@
