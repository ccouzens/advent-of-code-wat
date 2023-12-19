import fs from "node:fs/promises";
import { compute, imports, type ComputerExports } from "./script";

let computer: undefined | ComputerExports;

beforeAll(async () => {
  const buffer = await fs.readFile(`${__dirname}/compute.wasm`);
  computer = (await WebAssembly.instantiate(buffer, imports)).instance
    .exports as unknown as ComputerExports;
});

const testCase = `
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
`;

test("problem example gives 5905", async () => {
  expect(compute(testCase, computer!)).toEqual(5905);
});
