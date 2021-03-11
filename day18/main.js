import { lang } from 'https://cdn.skypack.dev/parser-lang';
const input = (await Deno.readTextFile('input.txt')).trim().split('\n')

const OP = {
  '+': (a, b) => a + b,
  '*': (a, b) => a * b,
}

const applyOp = ([head, tail]) => tail.reduce((sum, [op, expr]) => OP[op](sum, expr), head)

let { uop, mul } = lang`  
  uop = lit (('*' | '+') uop)* > ${applyOp};

  mul = add ('*' mul)* > ${applyOp};
  add = lit ('+' add)* > ${applyOp};

  lit
    = '(' uop ')' > ${a => a[1]}
    | num ;

  num = /[0-9]+/ > ${ch => parseInt(ch, 10)};
`;

const run_uop = (input) => uop.tryParse(input.trim().replace(/\s+/g, ''))
const run_mul = (input) => mul.tryParse(input.trim().replace(/\s+/g, ''))


const part1 = input.reduce((sum, line) => sum + run_uop(line), 0)
const part2 = input.reduce((sum, line) => sum + run_mul(line), 0)

console.log(`
  Part1: ${part1}
  Part1: ${part2}`)