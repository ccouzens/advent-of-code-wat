wasms = \
src/2015-01-1/compute.wasm \
src/2015-01-2/compute.wasm \
src/2015-02-1/compute.wasm \
src/2015-02-2/compute.wasm \
src/2023-01-1/compute.wasm \
src/2023-01-2/compute.wasm \
src/2023-02-1/compute.wasm \
src/2023-02-2/compute.wasm \
src/2023-03-1/compute.wasm \
src/2023-03-2/compute.wasm \
src/2023-04-1/compute.wasm \
src/2023-04-2/compute.wasm \
src/2023-05-1/compute.wasm \
src/2023-05-2/compute.wasm \
src/2023-06-1/compute.wasm \
src/2023-06-2/compute.wasm \
src/2023-07-1/compute.wasm \
src/2023-07-2/compute.wasm \
src/2023-08-1/compute.wasm \
src/2023-08-2/compute.wasm \

.PHONY : all
all : $(wasms)

.PHONY : clean
clean :
	rm -f $(wasms) src/*/*.js

%.wasm: %.wat
	wat2wasm --debug-names $< -o $@

