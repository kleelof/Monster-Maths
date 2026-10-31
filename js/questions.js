export const LEVEL_DESCRIPTIONS = [
  "Single-digit addition",
  "Two-digit plus single-digit",
  "Single-digit subtraction",
  "Two-digit minus single-digit",
  "Two-digit addition",
  "Two-digit subtraction",
  "Single-digit multiplication",
  "Exact division",
  "Single-digit times a teen",
  "Teen multiplication"
];

const integer = (min, max, random = Math.random) =>
  Math.floor(random() * (max - min + 1)) + min;

export function generateQuestion(level, random = Math.random) {
  let a;
  let b;
  let result;
  let operator;

  switch (level) {
    case 1:
      a = integer(0, 8, random); b = integer(0, 8, random); operator = "+"; result = a + b; break;
    case 2:
      a = integer(10, 98, random); b = integer(0, 8, random); operator = "+"; result = a + b; break;
    case 3:
      a = integer(0, 8, random); b = a === 0 ? 0 : integer(0, a - 1, random); operator = "−"; result = a - b; break;
    case 4:
      a = integer(10, 98, random); b = integer(0, 8, random); operator = "−"; result = a - b; break;
    case 5:
      a = integer(0, 98, random); b = integer(0, 98, random); operator = "+"; result = a + b; break;
    case 6:
      a = integer(11, 99, random); b = integer(0, a - 1, random); operator = "−"; result = a - b; break;
    case 7:
      a = integer(0, 8, random); b = integer(0, 8, random); operator = "×"; result = a * b; break;
    case 8: {
      const quotient = integer(1, 8, random);
      b = integer(1, 8, random); a = quotient * b; operator = "÷"; result = quotient; break;
    }
    case 9:
      a = integer(0, 8, random); b = integer(10, 14, random); operator = "×"; result = a * b; break;
    case 10:
    default:
      a = integer(10, 14, random); b = integer(10, 14, random); operator = "×"; result = a * b; break;
  }

  return { a, b, operator, result, text: `${a} ${operator} ${b}` };
}
