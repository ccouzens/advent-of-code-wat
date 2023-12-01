export interface WrappingPaperCalculatorExports {
  mem: WebAssembly.Memory;
  calculate: (length: number) => number;
}

export function calculate(
  dimensionsString: string,
  mem: WebAssembly.Memory,
  calculateWasm: WrappingPaperCalculatorExports["calculate"],
): number {
  let lineCount = 0;
  const memView = new Uint8Array(mem.buffer);
  for (const line of dimensionsString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l)) {
    const [x, y, z] = line.split("x").map((v) => parseInt(v, 10));
    memView[lineCount * 3 + 0] = x!;
    memView[lineCount * 3 + 1] = y!;
    memView[lineCount * 3 + 2] = z!;
    lineCount++;
  }
  return calculateWasm(lineCount);
}

export async function main() {
  const input = document.getElementById("input")! as HTMLTextAreaElement;
  const output = document.getElementById("output")! as HTMLPreElement;
  const button = document.getElementById("submit")! as HTMLButtonElement;

  const module = await WebAssembly.instantiateStreaming(
    fetch("2015-02-1.wasm"),
  );
  const instanceExports = module.instance
    .exports as unknown as WrappingPaperCalculatorExports;
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
