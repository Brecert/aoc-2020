function dbg() {
  console.log(this.valueOf());
  return this;
}

function flip(axis) {
  if (axis === 'x') {
    return this.reverse();
  } else if (axis === 'y') {
    return this.map((row) => row.reverse());
  } else {
    return this;
  }
}

function* zip(other) {
  let iterA = this[Symbol.iterator]();
  let iterB = this[Symbol.iterator]();

  let nextA = iterA.next();
  let nextB = iterB.next();

  while (true) {
    yield [nextA.value, nextB.value];
    nextA = iterA.next();
    nextB = iterB.next();

    if (nextA.done || nextB.done) {
      break;
    }
  }
}

function transpose() {
  return this[0].map((x, i) => this.map((x) => x[i]));
}

function rotation(count = 1) {
  let last = this;
  for (let i = 0; i < count % 4; i++) {
    last = last::transpose()::flip('y');
  }
  return last;
}

function toSet() {
  return Set.from(this);
}

function* times(n = 0) {
  for (let i = n; i < this.valueOf(); i++) {
    yield i;
  }
}

function count(fn = () => true) {
  let i = 0;
  for (let el of this) {
    if (fn(el)) {
      i += 1;
    }
  }
  return i;
}

function* cons(n, reuse = false) {
  let iter = this[Symbol.iterator]();
  let values = [];

  for (let el of iter) {
    while (true) {
      values.push(el);
      if (values.length > n) {
        values.shift();
      }
      if (values.length === n) {
        break;
      }
    }

    if (reuse) {
      yield values;
    } else {
      yield Array.from(values);
    }
  }

  for (let el in this) {
    values.push(el);
    if (values.length > n) {
      values.shift();
    }
  }
}

function sum() {
  return this.reduce((a, b) => a + b, 0);
}

function width() {
  return this[0].length;
}

function height() {
  return this.length;
}

function matrixString() {
  return this.map((e) => e.join('')).join('\n');
}

function* variants() {
  yield this;
  yield this::flip('x');
  yield this::flip('y');
  yield this::flip('y')::flip('x');
  yield this::transpose();
  yield this::transpose()::flip('x');
  yield this::transpose()::flip('y');
  yield this::transpose()::flip('y')::flip('x');
}

function mask(arraySlice) {
  return arraySlice
    .map((row) => row.join('').replaceAll('.', '0').replaceAll('#', '1'))
    .map((e) => parseInt(e, 2))
    .reduce((a, b) => a + b);
}

// THE COMBINED TILES AS A STRING
const INPUT = ``.trim();

const MONSTER = `
..................#.
#....##....##....###
.#..#..#..#..#..#...
`
  .trim()
  .split('\n')
  .map((a) => [...a]);

const MONSTER_MASK = mask(MONSTER);
const MONSTER_COORDINATES = [];

for (let k = 0; k < MONSTER::height(); k++) {
  for (let l = 0; l < MONSTER::width(); l++) {
    if (MONSTER[k][l] === '#') MONSTER_COORDINATES.push([k, l]);
  }
}

const MAP = INPUT.split('\n').map((a) => [...a]);
const SIZE = Math.sqrt(MAP.flat().length);

function scan(grid) {
  let count = 0;
  grid::variants().forEach((variant) => {
    for (let py = 0; py < SIZE; py++) {
      for (let px = 0; px < SIZE; px++) {
        if(MONSTER_COORDINATES.every(([my, mx]) => variant[my + py]?.[mx + px] === '#')) {
          count += 1
        }
      }
    }
  });
  return count;
}

const monsters = scan(MAP);
MAP.flat()::count(e => e === '#') - MONSTER.flat()::count(e => e === '#') * monsters

