export interface ComputerExports {
  mem: WebAssembly.Memory;
  compute: () => number;
}

export const imports: WebAssembly.Imports = {};

export function compute(
  inputString: string,
  computer: ComputerExports,
): number {
  /*
  mem layout
  handCount: i64
  hands[]:
    card[5]: i8 (ASCII)
    alignment: i8
    bid: i16
    value: i64
    -- total of 16 bytes
  orderedIndexes[]:
    index: i16
  */
  const hands = inputString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l);
  const memView = new Uint8Array(computer.mem.buffer);
  let memPointer = 0;
  memView[memPointer++] = hands.length % 0x100;
  memView[memPointer++] = hands.length / 0x100;
  for (let i = 2; i < 8; i++) {
    memView[memPointer++] = 0;
  }
  for (const hand of hands) {
    const [cards, bid] = hand.split(" ");
    for (let i = 0; i < 5; i++) {
      memView[memPointer++] = cards?.charCodeAt(i) ?? 0;
    }
    memView[memPointer++] = 0;
    memView[memPointer++] = parseInt(bid ?? "", 10) % 0x100;
    memView[memPointer++] = parseInt(bid ?? "", 10) / 0x100;
    for (let i = 0; i < 8; i++) {
      memView[memPointer++] = 0;
    }
  }

  return computer.compute();
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
