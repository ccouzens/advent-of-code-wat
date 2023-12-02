wasms = \
src/2015-01-1/compute.wasm \
src/2015-01-2/compute.wasm \
src/2015-02-1/compute.wasm \
src/2015-02-2/compute.wasm \
src/2023-01-1/compute.wasm \
src/2023-01-2/compute.wasm \

.PHONY : all
all : $(wasms)

.PHONY : clean
clean :
	rm -f $(wasms) src/*/*.js

%.wasm: %.wat
	wat2wasm $< -o $@

