import fs from "node:fs/promises";
import { compute, imports, type ComputerExports } from "./script";

let computer: undefined | ComputerExports;

beforeAll(async () => {
  const buffer = await fs.readFile(`${__dirname}/compute.wasm`);
  computer = (await WebAssembly.instantiate(buffer, imports)).instance
    .exports as unknown as ComputerExports;
});

const testCase = `
Time:      7  15   30
Distance:  9  40  200
`;

test("problem example gives 288", async () => {
  expect(compute(testCase, computer!)).toEqual(288);
});
