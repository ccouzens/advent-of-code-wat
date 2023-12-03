export interface ComputerExports {
  compute: (instance: Instance) => number;
}

interface Draw {
  r: number;
  g: number;
  b: number;
}

interface Game {
  id: number;
  draws: Draw[];
}

interface Instance {
  gameIndex: number;
  drawIndex: number;
  games: Game[];
}

export const imports: WebAssembly.Imports = {
  reader: {
    nextGame(i: Instance): number {
      i.gameIndex++;
      i.drawIndex = -1;
      return i.games[i.gameIndex]?.id ?? -1;
    },
    nextDraw(i: Instance): [number, number, number] {
      i.drawIndex++;
      const draw = i.games[i.gameIndex]?.draws[i.drawIndex];
      if (draw === undefined) {
        return [-1, -1, -1];
      } else {
        return [draw.r ?? 0, draw.g ?? 0, draw.b ?? 0];
      }
    },
  },
};

const gameParser = /^Game (?<id>\d+):(?<draws>.*)$/;
const drawParser = /(?<count>\d+) (?<colour>red|green|blue)/g;

export function compute(
  inputString: string,
  computer: ComputerExports,
): number {
  const gameStrings = inputString
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l);
  const games = gameStrings.map<Game>((gameString) => {
    const { draws, id } = gameString.match(gameParser)!.groups!;
    return {
      id: parseInt(id!, 10),
      draws: draws!
        .split(";")
        .map((d) => d.trim())
        .filter((d) => d)
        .map((d) => {
          const draw: Draw = {
            r: 0,
            g: 0,
            b: 0,
          };
          for (const match of d.matchAll(drawParser)) {
            let count = parseInt(match.groups!["count"]!, 10);
            switch (match.groups!["colour"]) {
              case "red":
                draw.r = count;
                break;
              case "green":
                draw.g = count;
                break;
              case "blue":
                draw.b = count;
                break;
            }
          }
          return draw;
        }),
    };
  });
  const instance = {
    gameIndex: -1,
    drawIndex: -1,
    games,
  };

  return computer.compute(instance);
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
