export interface CalculatorExports {
  mem: WebAssembly.Memory;
  calculate: (length: number) => number;
}

const textEncoder = new TextEncoder();

function stringTo8Byte(input: string): WebAssembly.Global<"i64"> {
  const bytes = new Uint8Array(8);
  textEncoder.encodeInto(input, bytes);
  const longs = new BigUint64Array(bytes.buffer);
  return new WebAssembly.Global({ value: "i64" }, longs[0]);
}

export const imports: WebAssembly.Imports = {
  nums: {
    zero: stringTo8Byte("zero"),
    one: stringTo8Byte("one"),
    two: stringTo8Byte("two"),
    three: stringTo8Byte("three"),
    four: stringTo8Byte("four"),
    five: stringTo8Byte("five"),
    six: stringTo8Byte("six"),
    seven: stringTo8Byte("seven"),
    eight: stringTo8Byte("eight"),
    nine: stringTo8Byte("nine"),
  },
};

export function calculate(
  inputString: string,
  mem: WebAssembly.Memory,
  calculateWasm: CalculatorExports["calculate"],
): number {
  const cleanInput = inputString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l)
    .join("\n");
  const memView = new Uint8Array(mem.buffer);
  const { written } = textEncoder.encodeInto(cleanInput, memView);
  memView[written] = "\n".charCodeAt(0);
  return calculateWasm(written + 1);
}

export async function main() {
  const input = document.getElementById("input")! as HTMLTextAreaElement;
  const output = document.getElementById("output")! as HTMLPreElement;
  const button = document.getElementById("submit")! as HTMLButtonElement;

  const module = await WebAssembly.instantiateStreaming(
    fetch("2023-01-2.wasm"),
    imports,
  );
  const instanceExports = module.instance
    .exports as unknown as CalculatorExports;
  function eventListener() {
    output.textContent = `${calculate(
      input.value,
      instanceExports.mem,
      instanceExports.calculate,
    )}`;
  }

  input.addEventListener("change", eventListener);
  button.addEventListener("click", eventListener);
  eventListener();
}
