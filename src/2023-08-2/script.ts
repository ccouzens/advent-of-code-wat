export interface ComputerExports {
  mem: WebAssembly.Memory;
  compute: (
    instructionsCount: number,
    networkPointer: number,
    networkCount: number,
  ) => bigint;
}

export const imports: WebAssembly.Imports = {};

const textEncoder = new TextEncoder();

export function compute(
  inputString: string,
  computer: ComputerExports,
): bigint {
  /*
  mem layout
  instructions: [] {
    LR: i8
  }
  network: [] { total 64
    name: i8 * 3
    padding: i8
    L: i16
    R: i16
  }
  ghosts: [] {
    index: i16
  }

  mem debugging:
  ghost indices
  new Uint16Array(memories.$mem.buffer, $ghostPointer.value, $ghostCount.value)

  label at index
  ((i) => new TextDecoder().decode(new Uint8Array(memories.$mem.buffer, $networkPointer.value + i * 8, 3)))(50)

  LR at index
  ((i) => new Uint16Array(memories.$mem.buffer, $networkPointer.value + i * 8 + 4, 2))(50)
  */
  const [instructions, ...networkLines] = inputString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l);
  const labelsToIndex = new Map(
    networkLines.map((networkLine, i) => [networkLine.slice(0, 3), i]),
  );
  const memView = new Uint8Array(computer.mem.buffer);
  let memPointer = 0;
  const write16 = (value: number) => {
    memView[memPointer++] = value % 0x100;
    memView[memPointer++] = value / 0x100;
  };

  memPointer += textEncoder.encodeInto(
    instructions!,
    memView.subarray(memPointer),
  ).written;

  while (memPointer % 2 !== 0) {
    memView[memPointer++] = 0;
  }

  const networkPointer = memPointer;

  for (const networkLine of networkLines) {
    const name = networkLine.slice(0, 3);
    const left = networkLine.slice(7, 10);
    const right = networkLine.slice(12, 15);

    memPointer += textEncoder.encodeInto(
      name!,
      memView.subarray(memPointer),
    ).written;
    memView[memPointer++] = 0;
    write16(labelsToIndex.get(left)!);
    write16(labelsToIndex.get(right)!);
  }

  return computer.compute(
    instructions!.length,
    networkPointer,
    networkLines!.length,
  );
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
