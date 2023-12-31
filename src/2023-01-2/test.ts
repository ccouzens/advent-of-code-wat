import fs from "node:fs/promises";
import { calculate, imports, type CalculatorExports } from "./script";

let instanceExports: undefined | CalculatorExports;

beforeAll(async () => {
  const buffer = await fs.readFile(`${__dirname}/compute.wasm`);
  const module = await WebAssembly.instantiate(buffer, imports);
  instanceExports = module.instance.exports as unknown as CalculatorExports;
});

const testCase = `
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
`;

test("problem example gives 281", () => {
  expect(
    calculate(testCase, instanceExports!.mem, instanceExports!.calculate),
  ).toEqual(281);
});
