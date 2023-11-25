wasms = \
src/2015-01-1.wasm \

.PHONY : all
all : $(wasms)

.PHONY : clean
clean :
	rm -f $(wasms) src/*.js

%.wasm: %.wat
	wat2wasm $< -o $@

