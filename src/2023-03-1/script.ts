export interface ComputerExports {
  mem: WebAssembly.Memory;
  compute: (width: number, height: number) => number;
}

export const imports: WebAssembly.Imports = {};

const textEncoder = new TextEncoder();

export function compute(
  inputString: string,
  computer: ComputerExports,
): number {
  const lines = inputString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l);
  const cleanInput = lines.join("");
  const memView = new Uint8Array(computer.mem.buffer);
  textEncoder.encodeInto(cleanInput, memView);

  return computer.compute(lines[0]!.length, lines.length);
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
