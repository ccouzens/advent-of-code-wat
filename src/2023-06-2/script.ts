export interface ComputerExports {
  compute: (time: number, distance: number) => number;
}

export const imports: WebAssembly.Imports = {};

interface Race {
  time: number;
  record: number;
}

function parse(input: string): Race {
  const [time, record] = input
    .split(/[a-zA-Z]+:/)
    .map((i) => i.trim())
    .filter((i) => i)
    .map((i) => parseInt(i.replaceAll(/\s+/g, ""), 10));

  return {
    time: time ?? 0,
    record: record ?? 0,
  };
}

export function compute(
  inputString: string,
  computer: ComputerExports,
): number {
  const race = parse(inputString);
  return computer.compute(race.time, race.record);
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
