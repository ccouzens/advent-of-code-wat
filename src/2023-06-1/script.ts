export interface ComputerExports {
  compute: (time: number, distance: number) => number;
}

export const imports: WebAssembly.Imports = {};

interface Race {
  time: number;
  record: number;
}

function parse(input: string): Race[] {
  const [times, records] = input
    .split(/[a-zA-Z]+:/)
    .map((i) => i.trim())
    .filter((i) => i)
    .map((i) => i.split(/\s+/).map((n) => parseInt(n, 10)));

  if (
    times === undefined ||
    records === undefined ||
    times.length !== records.length
  ) {
    return [];
  }

  return times.map<Race>((time, i) => ({
    time,
    record: records[i]!,
  }));
}

export function compute(
  inputString: string,
  computer: ComputerExports,
): number {
  const races = parse(inputString);
  let product = 1;

  for (const race of races) {
    product *= computer.compute(race.time, race.record);
  }

  return product;
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
