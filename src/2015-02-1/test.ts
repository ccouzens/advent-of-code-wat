import fs from "node:fs/promises";
import { type WrappingPaperCalculatorExports, calculate } from "./script";

let instanceExports: undefined | WrappingPaperCalculatorExports;

beforeAll(async () => {
  const buffer = await fs.readFile(`${__dirname}/compute.wasm`);
  const module = await WebAssembly.instantiate(buffer);
  instanceExports = module.instance
    .exports as unknown as WrappingPaperCalculatorExports;
});

const testCase = `
2x3x4
1x1x10
`;

test("problem example gives 101", () => {
  expect(
    calculate(testCase, instanceExports!.mem, instanceExports!.calculate),
  ).toEqual(58 + 43);
});
