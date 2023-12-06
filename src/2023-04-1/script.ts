export interface ComputerExports {
  mem: WebAssembly.Memory;
  compute: (length: number) => number;
}

export const imports: WebAssembly.Imports = {};

const textEncoder = new TextEncoder();

export function compute(
  inputString: string,
  computer: ComputerExports,
): number {
  const cleaned = inputString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l)
    .join("");
  const memView = new Uint8Array(computer.mem.buffer);
  const { written } = textEncoder.encodeInto(cleaned, memView);
  memView[written] = "\n".charCodeAt(0);

  return computer.compute(written + 1);
}

export async function main() {
  const input = document.getElementById("input")! as HTMLTextAreaElement;
  const output = document.getElementById("output")! as HTMLPreElement;
  const button = document.getElementById("submit")! as HTMLButtonElement;

  const computer = (
    await WebAssembly.instantiateStreaming(fetch("compute.wasm"), imports)
  ).instance.exports as unknown as ComputerExports;
  async function eventListener() {
    output.textContent = `${compute(input.value, computer)}`;
  }

  input.addEventListener("change", eventListener);
  button.addEventListener("click", eventListener);
  eventListener();
}
