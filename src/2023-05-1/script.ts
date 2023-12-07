export interface ComputerExports {
  mem: WebAssembly.Memory;
  compute: (seed: BigInt) => BigInt;
}

export const imports: WebAssembly.Imports = {};

interface Almanac {
  seeds: number[];
  maps: number[][];
}

function parse(input: string): Almanac {
  const [seeds, ...maps] = input
    .split(/[a-z- ]+:/)
    .map((i) => i.trim())
    .filter((i) => i)
    .map((i) => i.split(/\s+/).map((n) => parseInt(n, 10)));

  return {
    seeds: seeds!,
    maps,
  };
}

export function compute(
  inputString: string,
  computer: ComputerExports,
): BigInt | undefined {
  const almanac = parse(inputString);
  /*
  memory layout:

  numOfMaps: i64
  maps[]:
    numOfRanges: i64
    ranges[]:
      destinationRangeStart: i64
      sourceRangeStart: i64
      rangeLength: i64
  */
  const memView = new BigUint64Array(computer.mem.buffer);
  memView[0] = BigInt(almanac.maps.length);
  let i = 1;
  for (const m of almanac.maps) {
    memView[i++] = BigInt(m.length / 3);
    for (const n of m) {
      memView[i++] = BigInt(n);
    }
  }

  const locations = almanac.seeds.map((s) => {
    return computer.compute(BigInt(s));
  });
  let smallestLocation = locations[0];
  for (const location of locations) {
    if (location < smallestLocation!) {
      smallestLocation = location;
    }
  }

  return smallestLocation;
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
