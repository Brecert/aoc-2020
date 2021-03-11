import { lang } from "https://cdn.skypack.dev/parser-lang";
const alpha = (n) => String.fromCharCode(65 + Number(n));

let input = (await Deno.readTextFile("input.txt"));

input = input.replace(/^8: .+/gm, "8: 42 | 42 8");
input = input.replace(/^11: .+/gm, "11: 42 31 | 42 11 31");

input = input
  .replaceAll(":", "=")
  .replaceAll('"', "'")
  .replace(/(\d+)/g, "R$1")
  .split("\n\n");

const rules = input[0].split("\n").map(l => l + ';').sort().join('\n');
const mesggages = input[1].split("\n");

console.log(rules);

const patterns = lang({
  raw: [rules],
});

const c = mesggages.filter((m) => {
  const p = patterns["R0"].parse(m);
  return p.success
});

console.log(c.length);
