type Logger = (
  event: "ghostEnd",
  ghostIndex: number,
  networkIndex: number,
  stepIndex: bigint,
  instructionIndex: number,
) => void;

export interface ComputerExports {
  mem: WebAssembly.Memory;
  compute: (
    instructionsCount: number,
    networkPointer: number,
    networkCount: number,
    maxSteps: bigint,
    logger: Logger,
  ) => bigint;
}

export const imports: WebAssembly.Imports = {
  js: {
    logGhostEnd(
      logger: Logger,
      ghostIndex: number,
      networkIndex: number,
      stepIndex: bigint,
      instructionIndex: number,
    ) {
      logger("ghostEnd", ghostIndex, networkIndex, stepIndex, instructionIndex);
    },
  },
};

const textEncoder = new TextEncoder();

export function compute(
  inputString: string,
  maxSteps: string,
  computer: ComputerExports,
  logger: Logger,
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
    BigInt(maxSteps),
    logger,
  );
}

export async function main() {
  const input = document.getElementById("input")! as HTMLTextAreaElement;
  const maxSteps = document.getElementById(
    "maxIterations",
  )! as HTMLInputElement;
  const output = document.getElementById("output")! as HTMLPreElement;
  const button = document.getElementById("submit")! as HTMLButtonElement;
  const ghostInfo = document.getElementById("ghostInfo")! as HTMLDivElement;

  const computer = (
    await WebAssembly.instantiateStreaming(fetch("compute.wasm"), imports)
  ).instance.exports as unknown as ComputerExports;
  async function eventListener() {
    ghostInfo.textContent = "";
    const p = document.createElement("p");
    const ghostDivs: HTMLDivElement[] = [];

    output.textContent = `${compute(
      input.value,
      maxSteps.value,
      computer,
      function (event, ghostIndex, networkIndex, stepIndex, instructionIndex) {
        if (event !== "ghostEnd") {
          return;
        }
        while (ghostIndex >= ghostDivs.length) {
          const d = document.createElement("div");
          const label = document.createElement("p");
          ghostInfo.appendChild(d);
          ghostDivs.push(d);
          d.appendChild(label);
          label.textContent = `Ghost ${ghostDivs.length}`;
        }
        const p = document.createElement("p");
        p.textContent = `Ghost came to end node ${networkIndex} after ${stepIndex} steps at instruction ${instructionIndex}`;
        ghostDivs[ghostIndex]?.appendChild(p);
      },
    )}`;
  }

  document.body.addEventListener("change", eventListener);
  button.addEventListener("click", eventListener);
  eventListener();
}
