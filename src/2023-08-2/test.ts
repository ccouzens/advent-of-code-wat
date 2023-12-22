import fs from "node:fs/promises";
import { compute, imports, type ComputerExports } from "./script";

let computer: undefined | ComputerExports;

beforeAll(async () => {
  const buffer = await fs.readFile(`${__dirname}/compute.wasm`);
  computer = (await WebAssembly.instantiate(buffer, imports)).instance
    .exports as unknown as ComputerExports;
});

const testCase = `
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
`;

test("problem example gives 6", async () => {
  expect(compute(testCase, computer!)).toEqual(6n);
});
