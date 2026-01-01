ACME ?= acme
EMU  ?= x64sc

TARGET := viewer.prg
SRC    := main.asm

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SRC) chabuduo.bin gb40_rows.asm font8.bin
	$(ACME) -f cbm -o $@ $<

run: $(TARGET)
	$(EMU) -autostart $(TARGET)

clean:
	rm $(TARGET)

chabuduo.bin: tools/chabuduo.txt
	iconv -f UTF-8 -t gb2312 < $< > $@

gb40_rows.asm: gb2312_chars.txt tools/gb40.py
	tools/gb40.py $<

font8.bin font7.bin gb2312_chars.txt: tools/sheet.png tools/tilemap.txt
	tools/conv.py $+
