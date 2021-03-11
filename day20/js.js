const fs = require('fs');

const SIZE = 10;
const MONSTER = [
  '                  # '.split(''),
  '#    ##    ##    ###'.split(''),
  ' #  #  #  #  #  #   '.split(''),
];
const MONSTER_WIDTH = MONSTER[0].length;
const MONSTER_HEIGHT = MONSTER.length;
const MONSTER_COORDINATES = [];
for (let k = 0; k < MONSTER_HEIGHT; k++) {
  for (let l = 0; l < MONSTER_WIDTH; l++) {
    if (MONSTER[k][l] === '#') MONSTER_COORDINATES.push([k, l]);
  }
}

class BaseMatrix {
  constructor() {
    this.current = [[]];
    this.currentEdges = new Map();
  }

  flipVertically() {
    for (let i = 0; i < this.width; i++) {
      this.current[i].reverse();
    }
    this.refreshEdges();
  }

  rotate90clockwise() {
    const X = this.width / 2;
    const Y = this.width - 1;
    for (let i = 0; i < X; i++) {
      for (let j = i; j < Y - i; j++) {
        const k = this.current[i][j];
        this.current[i][j] = this.current[Y - j][i];
        this.current[Y - j][i] = this.current[Y - i][Y - j];
        this.current[Y - i][Y - j] = this.current[j][Y - i];
        this.current[j][Y - i] = k;
      }
    }
    this.refreshEdges();
  }

  refreshEdges() {
    this.currentEdges.set('top', this.current[0].join(''));
    this.currentEdges.set('bottom', this.current[this.width - 1].join(''));
    this.currentEdges.set('left', this.current.map((line) => line[0]).join(''));
    this.currentEdges.set(
      'right',
      this.current.map((line) => line[this.width - 1]).join('')
    );
  }

  *getNextPosition() {
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    this.flipVertically();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    this.flipVertically();
    this.rotate90clockwise();
    this.flipVertically();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    yield true;
    this.rotate90clockwise();
    yield true;
    yield false;
  }

  print() {
    for (const line of this.current) {
      console.log(line.join(''));
    }
  }
}

class Tile extends BaseMatrix {
  constructor(blob) {
    super();
    [this.title, this.raw] = blob.split(':\n');
    this.id = Number(this.title.slice(5, 10));
    this.original = this.extract(this.raw);
    this.width = SIZE;

    // Needed for part 1
    this.simpleEdges = this.getEdges();
    this.matchedEdges = 0;

    // Needed for part 2
    this.current = this.original.map((line) => [...line]);
    this.refreshEdges();
  }

  extract(blob) {
    return blob.split('\n').map((line) => line.split(''));
  }

  getEdges() {
    const edges = [
      this.original[0],
      this.original.map((line) => line[0]),
      this.original.map((line) => line[this.width - 1]),
      this.original[this.width - 1],
    ];
    edges.push(...edges.map((edge) => [...edge].reverse()));
    return edges.map((array) => array.join(''));
  }

  hasMatch(tileMap, where) {
    for (const [key, tile] of tileMap) {
      if (tile.simpleEdges.includes(this.currentEdges.get(where))) return true;
    }
    return false;
  }

  hasRightAndBottomMatch(tileMap) {
    return this.hasMatch(tileMap, 'right') && this.hasMatch(tileMap, 'bottom');
  }

  orientInitial(tileMap) {
    while (true) {
      this.rotate90clockwise();
      if (this.hasRightAndBottomMatch(tileMap)) {
        return;
      }
    }
  }

  matchesTiles(otherTile, where) {
    switch (where) {
      case 'top':
        return (
          otherTile.currentEdges.get('bottom') === this.currentEdges.get('top')
        );
      case 'right':
        return (
          otherTile.currentEdges.get('left') === this.currentEdges.get('right')
        );
      case 'left':
        return (
          otherTile.currentEdges.get('right') === this.currentEdges.get('left')
        );
      case 'bottom':
        return (
          otherTile.currentEdges.get('top') === this.currentEdges.get('bottom')
        );
      default:
        throw Error;
    }
  }

  match(knownNeighbors) {
    const positionIterator = this.getNextPosition();
    while (positionIterator.next().value === true) {
      let abort = false;
      for (const where in knownNeighbors) {
        if (knownNeighbors[where]) {
          if (!this.matchesTiles(knownNeighbors[where], where)) {
            abort = true;
            break;
          }
        }
      }
      if (abort) {
        continue;
      } else {
        return true;
      }
    }
    return false;
  }
}

class Image extends BaseMatrix {
  constructor(positions) {
    super();
    const width = Math.sqrt(positions.size);
    this.width = width * (SIZE - 2);
    this.current = new Array(width * (SIZE - 2));
    for (let i = 0; i < this.current.length; i++) {
      this.current[i] = new Array(width * (SIZE - 2));
    }
    for (let i = 0; i < width; i++) {
      for (let j = 0; j < width; j++) {
        const currentTile = positions.get(`${i}-${j}`);
        for (let k = 1; k < SIZE - 1; k++) {
          for (let l = 1; l < SIZE - 1; l++) {
            this.current[i * (SIZE - 2) + k - 1][j * (SIZE - 2) + l - 1] =
              currentTile.current[k][l];
          }
        }
      }
    }
  }

  findMonsters() {
    let numMonsters = 0;
    const positionIterator = this.getNextPosition();
    while (numMonsters === 0 && positionIterator.next().value === true) {
      for (let i = 0; i <= this.width - MONSTER_HEIGHT; i++) {
        for (let j = 0; j <= this.width - MONSTER_WIDTH; j++) {
          if (
            MONSTER_COORDINATES.every(
              ([k, l]) => this.current[i + k][j + l] === '#'
            )
          ) {
            numMonsters++;
            MONSTER_COORDINATES.map(
              ([k, l]) => (this.current[i + k][j + l] = '0')
            );
          }
        }
      }
    }
    return numMonsters;
  }

  countClear() {
    let num = 0;
    for (let i = 0; i < this.width; i++) {
      for (let j = 0; j < this.width; j++) {
        if (this.current[i][j] === '#') num++;
      }
    }
    return num;
  }
}

const getInput = (fileName) => {
  let fileContent = fs.readFileSync(fileName, 'utf8');
  const tilesAsText = fileContent.split('\n\n');
  return tilesAsText.map((blob) => new Tile(blob));
};

const INPUT_FILE = 'input.txt';
const tiles = getInput(INPUT_FILE);

// part 1
const cornerCandidates = [];
for (const tile of tiles) {
  for (const comparisonTile of tiles) {
    if (tile.id === comparisonTile.id) continue;
    for (const edge of tile.simpleEdges) {
      if (comparisonTile.simpleEdges.includes(edge)) tile.matchedEdges++;
    }
  }
  if (tile.matchedEdges === 4) cornerCandidates.push(tile.id);
}
console.log('part 1: ' + cornerCandidates.reduce((a, b) => a * b, 1));

// part 2
// 1) Keep track of tiles left to place
const candidates = new Map();
tiles.map((tile) => candidates.set(tile.id, tile));
const positions = new Map();
// 2) Start from one corner. Orient it so that it is top left
width = Math.sqrt(candidates.size);
const startingCorner = candidates.get(cornerCandidates[0]);
candidates.delete(startingCorner.id);
startingCorner.orientInitial(candidates);
positions.set('0-0', startingCorner);
// 3) Orient and find all corners
for (let i = 0; i < width; i++) {
  for (let j = 0; j < width; j++) {
    if (positions.has(`${i}-${j}`)) {
      continue;
    }
    const knownNeighbors = {
      left: positions.get(`${i}-${j - 1}`),
      top: positions.get(`${i - 1}-${j}`),
      right: positions.get(`${i}-${j + 1}`),
      bottom: positions.get(`${i + 1}-${j}`),
    };
    for (const [id, candidateTile] of candidates) {
      const canMatch = candidateTile.match(knownNeighbors);
      if (canMatch) {
        candidates.delete(id);
        positions.set(`${i}-${j}`, candidateTile);
      }
    }
  }
}
// 4) Merge image and find monsters
const image = new Image(positions);
const numMonsters = image.findMonsters();
// image.print();
console.log('part 2: ' + image.countClear());
