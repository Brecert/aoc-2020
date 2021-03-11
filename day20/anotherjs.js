const getTiles = (input) =>
  input.split('\n\n').map((tile) => {
    const tileId = Number(/Tile (\d{4}):/.exec(tile.split('\n')[0])[1]);
    const fullTile = tile
      .split('\n')
      .slice(1)
      .map((row) => row.split(''));

    return { tileId, fullTile };
  });

const getBorders = (tile) => {
  const topBorder = tile[0].join('');
  const rightBorder = tile.map((row) => row[9]).join('');
  const bottomBorder = tile[9].join('');
  const leftBorder = tile.map((row) => row[0]).join('');

  return [topBorder, rightBorder, bottomBorder, leftBorder];
};

const rotate = (tile, rotations) => {
  let newTile = tile;
  for (let i = 0; i < rotations; i++) {
    newTile = newTile[0].map((_, index) => newTile.map((row) => row[index]).reverse());
  }
  return newTile;
};

const flip = (tile, type) => {
  if (type === 0) return tile.slice().reverse();
  if (type === 1) return tile.map((row) => row.slice().reverse());
};

const transform = (tile, type) => {
  switch (type) {
    case 0:
      return tile;
    case 1:
      return flip(tile, 0);
    case 2:
      return flip(tile, 1);
    case 3:
      return rotate(tile, 1);
    case 4:
      return rotate(tile, 2);
    case 5:
      return rotate(tile, 3);
    case 6:
      return rotate(flip(tile, 0), 1);
    case 7:
      return rotate(flip(tile, 0), 3);
  }
};

const getNaiveStats = (tiles) => {
  const stats = tiles.reduce((acc, { tileId }) => {
    acc[tileId] = [null, null, null, null];
    return acc;
  }, {});

  for (let i = 0; i < tiles.length; i++) {
    const mainTile = tiles[i];
    const borders = getBorders(mainTile.fullTile);
    for (let b = 0; b < 4; b++) {
      checkerLoop: for (let j = i + 1; j < tiles.length; j++) {
        const tile = tiles[j];
        for (let m = 0; m < 8; m++) {
          const modifiedTile = transform(tile.fullTile, m);
          const modifiedTileBorders = getBorders(modifiedTile);
          const borderId = modifiedTileBorders.findIndex((border) => border === borders[b]);
          if (borderId !== -1) {
            stats[mainTile.tileId][b] = tile.tileId;
            stats[tile.tileId][borderId] = mainTile.tileId;
            break checkerLoop;
          }
        }
      }
    }
  }

  return stats;
};

const createCanvas = (size) => Array.from({ length: size }).map(() => Array.from({ length: size }));

const getCornerIds = (stats) =>
  Object.entries(stats)
    .filter(([, values]) => values.filter((value) => value === null).length > 1)
    .map(([id]) => Number(id));

const matchBorders = ({
  baseTile,
  baseTileTransformation,
  tileToTransform,
  baseTileBorder,
  tileToTransformBorder,
}) => {
  const borderToCompare = getBorders(transform(baseTile, baseTileTransformation))[baseTileBorder];
  for (let m = 0; m < 8; m++) {
    const transformedTile = transform(tileToTransform, m);
    const transformedTileBorder = getBorders(transformedTile)[tileToTransformBorder];
    if (transformedTileBorder === borderToCompare) {
      return m;
    }
  }
  return -1;
};

const findSeedCorner = (stats, fullTiles) => {
  const corners = getCornerIds(stats);

  const test = (candidates, cornerId, transformation) => {
    const bottomTransformId = matchBorders({
      baseTile: fullTiles[cornerId],
      baseTileTransformation: transformation,
      baseTileBorder: 2,
      tileToTransform: fullTiles[candidates[0]],
      tileToTransformBorder: 0,
    });

    const rightTransformId = matchBorders({
      baseTile: fullTiles[cornerId],
      baseTileTransformation: transformation,
      baseTileBorder: 1,
      tileToTransform: fullTiles[candidates[1]],
      tileToTransformBorder: 3,
    });

    if (bottomTransformId !== -1 && rightTransformId !== -1) {
      return {
        corner: [cornerId, transformation],
        bottom: [candidates[0], bottomTransformId],
        right: [candidates[1], rightTransformId],
      };
    }
  };

  for (const cornerId of corners) {
    for (let transformation = 0; transformation < 8; transformation++) {
      const check1 = test(stats[cornerId].filter(Boolean), cornerId, transformation);
      if (check1) {
        return check1;
      }
      const check2 = test(stats[cornerId].filter(Boolean).reverse(), cornerId, transformation);
      if (check2) {
        return check2;
      }
    }
  }

  return results;
};

const findPartsPositions = (stats, fullTiles) => {
  const placedTiles = new Set();

  const imageSize = Math.sqrt(Object.keys(stats).length);
  const canvas = createCanvas(imageSize);

  const { corner, bottom, right } = findSeedCorner(stats, fullTiles);

  canvas[0][0] = corner;
  canvas[0][1] = right;
  canvas[1][0] = bottom;
  placedTiles.add(canvas[0][0][0]);
  placedTiles.add(canvas[0][1][0]);
  placedTiles.add(canvas[1][0][0]);

  for (let row = 2; row < imageSize; row++) {
    const [topTileId, topTileTransformation] = canvas[row - 1][0];
    for (const candidate of stats[topTileId].filter((i) => i && !placedTiles.has(i))) {
      const transformId = matchBorders({
        baseTile: fullTiles[topTileId],
        baseTileTransformation: topTileTransformation,
        baseTileBorder: 2,
        tileToTransform: fullTiles[candidate],
        tileToTransformBorder: 0,
      });

      if (transformId !== -1) {
        canvas[row][0] = [candidate, transformId];
        break;
      }
    }
    placedTiles.add(canvas[row][0][0]);
  }

  for (let row = 0; row < imageSize; row++) {
    for (let col = 1; col < imageSize; col++) {
      if (col === 1 && row === 0) continue;
      const [leftTileId, leftTileTransformation] = canvas[row][col - 1];

      for (const candidate of stats[leftTileId].filter((i) => i && !placedTiles.has(i))) {
        const transformId = matchBorders({
          baseTile: fullTiles[leftTileId],
          baseTileTransformation: leftTileTransformation,
          baseTileBorder: 1,
          tileToTransform: fullTiles[candidate],
          tileToTransformBorder: 3,
        });

        if (transformId !== -1) {
          canvas[row][col] = [candidate, transformId];
          break;
        }
      }

      placedTiles.add(canvas[row][col][0]);
    }
  }

  return canvas;
};

const removeBorder = (tile) =>
  tile.slice(1, tile.length - 1).map((row) => row.slice(1, row.length - 1));

const toFullImage = (imageInParts) =>
  imageInParts.flatMap((bigRow) =>
    bigRow.reduce((acc, group) => {
      group.forEach((row, index) => {
        acc[index] = [...(acc[index] || []), ...row];
      });
      return acc;
    }, [])
  );

const lookForMonsters = (image) => {
  const topMonster = /.{18}#{1}.{1}/;
  const midMonster = /#{1}.{4}#{2}.{4}#{2}.{4}#{3}/g;
  const botMonster = /.{1}#{1}.{2}#{1}.{2}#{1}.{2}#{1}.{2}#{1}.{2}#{1}.{3}/;
  const monsterHashes = 15;

  let foundHashes = 0;

  image.forEach((row, i, arr) => {
    let midTest;
    while ((midTest = midMonster.exec(row)) !== null) {
      if (midTest) {
        const topFragment = arr[i - 1].slice(midTest.index, midTest.index + 20);
        const botFragment = arr[i + 1].slice(midTest.index, midTest.index + 20);

        if (topMonster.test(topFragment) && botMonster.test(botFragment)) {
          foundHashes += monsterHashes;
        }
      }
    }
  });

  return foundHashes;
};

const puzzle1 = (input) => {
  const tiles = getTiles(input);
  const stats = getNaiveStats(tiles);

  return getCornerIds(stats).reduce((result, id) => result * id, 1);
};

// There is a bug somewhere but I can't find it, to me it looks like it returns correct result
// but there was an error in input - looking at it manually it feels like the algorithm works properly
// I got a star by putting value lower by 15, which is value that would be returned if I commented out
// the if statement in line 243, but it doesn't make sense to not check for lines above and below...
const puzzle2 = (input) => {
  const tiles = getTiles(input);
  const stats = getNaiveStats(tiles);
  const fullTiles = tiles.reduce((acc, { tileId, fullTile }) => {
    acc[tileId] = fullTile;
    return acc;
  }, {});

  const canvas = findPartsPositions(stats, fullTiles);
  const imageInParts = canvas.map((row) =>
    row.map(([tileId, transformation]) =>
      removeBorder(transform(fullTiles[tileId], transformation))
    )
  );

  const fullImage = toFullImage(imageInParts);

  for (let i = 0; i < 8; i++) {
    const transformedImage = transform(fullImage, i).map((row) => row.join(''));
    const foundMonsterParts = lookForMonsters(transformedImage);
    if (foundMonsterParts > 0) {
      return transformedImage.join('').replace(/\./g, '').length - foundMonsterParts;
    }
  }
};

const fs = require('fs');
const INPUT = fs.readFileSync("input.txt", 'utf8');
console.log(puzzle1(INPUT))
console.log(puzzle2(INPUT))