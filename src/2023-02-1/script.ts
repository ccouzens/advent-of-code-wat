interface Draw {
  r: number;
  g: number;
  b: number;
}

interface Game {
  id: number;
  draws: Draw[];
}

const gameParser = /^Game (?<id>\d+):(?<draws>.*)$/;
const drawParser = /(?<count>\d+) (?<colour>red|green|blue)/g;

export async function compute(
  inputString: string,
  computeModule: WebAssembly.Module,
): Promise<number> {
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
  let gameIndex = -1;
  let drawIndex = -1;

  const computeInstance = await WebAssembly.instantiate(computeModule, {
    reader: {
      nextGame(): number {
        gameIndex++;
        drawIndex = -1;
        return games[gameIndex]?.id ?? -1;
      },
      nextDraw(): [number, number, number] {
        drawIndex++;
        const draw = games[gameIndex]?.draws[drawIndex];
        if (draw === undefined) {
          return [-1, -1, -1];
        } else {
          return [draw.r ?? 0, draw.g ?? 0, draw.b ?? 0];
        }
      },
    },
  });

  return (computeInstance.exports["compute"] as () => number)();
}

export async function main() {
  const input = document.getElementById("input")! as HTMLTextAreaElement;
  const output = document.getElementById("output")! as HTMLPreElement;
  const button = document.getElementById("submit")! as HTMLButtonElement;

  const module = await WebAssembly.compileStreaming(fetch("compute.wasm"));
  async function eventListener() {
    output.textContent = `${await compute(input.value, module)}`;
  }

  input.addEventListener("change", eventListener);
  button.addEventListener("click", eventListener);
  eventListener();
}
