export interface CalculatorExports {
  mem: WebAssembly.Memory;
  calculate: (length: number) => number;
}

const textEncoder = new TextEncoder();

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

  const module = await WebAssembly.instantiateStreaming(fetch("compute.wasm"));
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
