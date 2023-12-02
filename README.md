# Advent of Code WAT

[Advent of Code](https://adventofcode.com/2023) attempted using
[web assembly text format](https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format).

Each day part has

- Tests written in TypeScript and Jest (eg
  [src/2015-02-1.test.ts](src/2015-02-1.test.ts))
- A webpage to run through the browser and take puzzle input (eg
  [src/2015-02-1.html](src/2015-02-1.html))
- A WASM module written in text format (eg
  [src/2015-02-1.wat](src/2015-02-1.wat))
- A TypeSript module to tie it all together (eg
  [src/2015-02-1.ts](src/2015-02-1.ts)). This will often do text parsing.

## Requirements

### WebAssembly Binary Toolkit

[wabt](https://github.com/WebAssembly/wabt) provides `wat2wasm` which translates
from `wat` to `wasm`. `wabt` can be found in most package managers.

### NodeJS

NodeJS is used to bring in other tools such as the test runner and the
TypeScript compiler.

### Python3

Python's inbuilt webserver is used as a convenient way of running a webserver.
Browsers cannot load JavaScript modules from the local filesystem.

## Running tests

```bash
npm install
make
npm test
```

## Running via a web-browser

```bash
npm install
make
npm run build:typescript
npm run serve
```
