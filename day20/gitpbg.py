
import sys
from functools import reduce
import numpy as np

NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3
directions = (NORTH, EAST, SOUTH, WEST)
dirnames = ("North", "East", "South", "West")


def invs(side):
    tmp = list("{:010b}".format(side))
    tmp.reverse()
    return int("".join(tmp), 2)


def make_palindrome(s):
    s = "1" + s + s[::-1] + "1"
    return s


def tonumber(s, doreverse=False):
    s = s.replace("#", "1")
    s = s.replace(".", "0")
    res = int(s, 2)
    # print("{} => {}".format(s, res))
    return res


class TileImageData:
    def __init__(self):
        self.tileimages = {}
        self.tilewidth = None
        self.tileheight = None

    def add_tile(self, tileid, imagedata):
        if self.tilewidth is None:
            self.tilewidth = len(imagedata[0])
        if self.tileheight is None:
            self.tileheight = len(imagedata)
        self.tileimages[tileid] = imagedata

    def get_image_array(self, tileid):
        rv = np.zeros((self.tileheight-2, self.tilewidth-2))
        for (r, row) in enumerate(self.tileimages[tileid][1:-1]):
            for (c, col) in enumerate(row[1:-1]):
                if col == '#':
                    rv[r][c] = 1
        return rv

    def get_image(self, tileid):
        return self.tileimages[tileid]


DEFAULT = 0
CW = 1
CW180 = 2
CCW = 3
VFLIP = 4
HFLIPCW = 5
HFLIP = 6
VFLIPCW = 7


orientations = [DEFAULT, CW, CW180, CCW, VFLIP, VFLIPCW, HFLIP, HFLIPCW]
orientatation_names = ["DEFAULT", "CW", "CW180",
                       "CCW", "VFLIP", "VFLIPCW", "HFLIP", "HFLIPCW"]


def rotate(sides):
    a, b, c, d = sides
    return invs(d), a, invs(b), c


def vflip(sides):
    a, b, c, d = sides
    return c, invs(b), a, invs(d)


class TileView:
    def __init__(self, t, o=DEFAULT):
        self.tile = t
        self.orientation = o

    def set_orientation(self, o):
        self.orientation = o

    def get_sides(self):
        return self.tile.get_orientation(self.orientation)

    def __str__(self):
        sides = self.get_sides()
        return "{}: {} O {}".format(self.tile.id,
                                    str(sides),
                                    orientatation_names[self.orientation])

    def __repr__(self):
        return self.__str__()


class Tile:
    def __init__(self):
        self.id = -1
        self.sides = [None for i in range(4*8)]

    def initialize(self, tileid, top, right, bottom, left):
        self.id = tileid
        orientation = [None for i in range(8)]
        orientation[DEFAULT] = (top, right, bottom, left)
        orientation[CW] = rotate(orientation[DEFAULT])
        orientation[CW180] = rotate(orientation[CW])
        orientation[CCW] = rotate(orientation[CW180])
        orientation[VFLIP] = vflip(orientation[DEFAULT])
        orientation[VFLIPCW] = rotate(orientation[VFLIP])
        orientation[HFLIP] = rotate(orientation[VFLIPCW])
        orientation[HFLIPCW] = rotate(orientation[HFLIP])
        self.sides = []
        self.side_set = set()
        for o in orientation:
            for s in o:
                self.sides.append(s)
                self.side_set.add(s)

    def get_orientation(self, o):
        return tuple(self.sides[o*4:o*4+4])

    def __str__(self):
        return "ID:{} Sides:{}".format(self.id, str(self.side_set))

    def __repr__(self):
        return self.__str__()


def canmatch(t1, t2, dir):
    opp = (dir+2) % 4
    return t1.sides[dir] == t2.sides[opp]


def readdata(filename):
    tiles = {}
    tile_image_data = TileImageData()
    with open(filename, "r") as f:
        curid = -1
        curtile = []
        for line in f.readlines():
            line = line.strip()
            if line == "":
                if curid > 0:
                    left = ""
                    right = ""
                    top = ""
                    bottom = ""
                    last = len(curtile)-1

                    for (i, row) in enumerate(curtile):
                        if i == 0:
                            top = row
                        if i == last:
                            bottom = row
                        left = left + row[0]
                        right = right + row[-1]
                    # print("tileid", curid)
                    tid = tonumber(top)
                    rid = tonumber(right)
                    bid = tonumber(bottom)
                    lid = tonumber(left)
                    # print(tid, bid, lid, rid)
                    t = Tile()
                    t.initialize(curid, tid, rid, bid, lid)
                    tiles[curid] = t
                tile_image_data.add_tile(curid, curtile)
                curid = -1
                curtile = []
                continue
            elif ":" in line:
                parts = line.split()
                if parts[0] == "Tile":
                    curid = int(parts[1][:-1])
                    # print("Tile ID=", curid)
            else:
                curtile.append(line)
    return (tiles, tile_image_data)


def find_corners(tiles) -> list:
    corners = []
    for t in tiles.values():
        # print(t)
        count = 0
        for tt in tiles.values():
            if tt.tile.id == t.tile.id:
                continue
            ixn = t.tile.side_set.intersection(tt.tile.side_set)
            # print(t, tt, ixn)
            if len(ixn) > 0:
                count = count + 1
        if count == 2:
            corners.append(t.tile.id)
    return corners


def get_neighbors(tid, tiles) -> list:
    t = tiles[tid]
    rv = []
    for tt in tiles.values():
        if tt.tile.id == tid:
            continue
        ixn = t.tile.side_set.intersection(tt.tile.side_set)
        if len(ixn) > 0:
            rv.append(tt.tile.id)
    return rv


def try_to_fit(t1, t2):
    ixn = t1.tile.side_set.intersection(t2.tile.side_set)
    for common in ixn:
        s1 = t1.get_sides()
        if common not in s1:
            continue
        dirn = s1.index(common)
        print("Matching on the ", dirnames[dirn])
        opp = (dirn + 2) % 4
        for o in orientations:
            t2.set_orientation(o)
            s2 = t2.get_sides()
            if s2[opp] == common:
                print("Match found for orientation ", orientatation_names[o])
                return dirn
    return -1


def trytogrow(vtile, tiles):
    tlist = [vtile]
    tilepos = {}
    tilepos[vtile.tile.id] = (0, 0)
    while tlist:
        v = tlist.pop()
        print(v.tile)
        curx, cury = tilepos[v.tile.id]
        nbrs = get_neighbors(v.tile.id, tiles)
        for n in nbrs:
            if n in tilepos:
                continue
            ntile = tiles[n]
            dirn = try_to_fit(v, ntile)
            if dirn == -1:
                print("Could not fit neighbor")
            else:
                if dirn == NORTH:
                    tilepos[n] = (curx, cury-1)
                    tlist.append(ntile)
                elif dirn == EAST:
                    tilepos[n] = (curx+1, cury)
                    tlist.append(ntile)
                elif dirn == SOUTH:
                    tilepos[n] = (curx, cury+1)
                    tlist.append(ntile)
                elif dirn == WEST:
                    tilepos[n] = (curx-1, cury)
                    tlist.append(ntile)
                else:
                    print("Unknown direction")
    print(tilepos)
    minx, miny = 9999999, 9999999
    maxx, maxy = -minx, -miny
    for x, y in tilepos.values():
        if x < minx:
            minx = x
        if x > maxx:
            maxx = x
        if y < miny:
            miny = y
        if y > maxy:
            maxy = y

    rx = maxx - minx
    ry = maxy - miny
    print(minx, maxx)
    print(miny, maxy)
    print(rx, ry)
    tilearray = np.zeros(shape=(ry+1, rx+1), dtype=int)
    for tid, (curx, cury) in tilepos.items():
        #print(curx, cury)
        #print(curx-minx, cury-miny)
        tilearray[cury-miny][curx-minx] = tid
    print(tilearray)
    return tilearray


def reorient_image(timg, o):
    if o == DEFAULT:
        return timg
    elif o == CW:
        return np.rot90(timg, 3)
    elif o == CW180:
        return np.rot90(timg, 2)
    elif o == CCW:
        return np.rot90(timg, 1)
    elif o == VFLIP:
        return np.flipud(timg)
    elif o == VFLIPCW:
        return np.rot90(np.flipud(timg), 3)
    elif o == HFLIP:
        return np.fliplr(timg)
    elif o == HFLIPCW:
        return np.rot90(np.fliplr(timg), 3)
    else:
        print("Illegal orientation")
    return timg


def make_image(tile_array, vtiles, tileimages):
    h, w = tile_array.shape
    tw, th = tileimages.tileheight-2, tileimages.tilewidth-2
    ih, iw = h * (tileimages.tileheight-2), w * (tileimages.tileheight-2)
    iarr = np.zeros((ih, iw))
    for r in range(h):
        for c in range(w):
            tid = tile_array[r][c]
            timg = tileimages.get_image_array(tid)
            # print(timg)
            oimg = reorient_image(timg, vtiles[tid].orientation)
            # print(oimg)
            xpos, ypos = c*tw, r*th
            iarr[ypos:ypos+th, xpos:xpos+tw] = oimg

    h, w = iarr.shape
    for r in range(h):
        rstr = ""
        for c in range(w):
            if iarr[r][c] == 1:
                rstr = rstr + "#"
            else:
                rstr = rstr + "."
        print(rstr)
    return iarr


def readmonster(filename):
    data = []
    with open(filename, "r") as f:
        for line in f.readlines():
            if line.strip() == "":
                break
            print(len(line))
            tmp = []
            for ch in line:
                if ch == "#":
                    tmp.append(1)
                else:
                    tmp.append(0)
            data.append(tmp)
    return np.array(data)


def convolve(image, monster):
    ih, iw = image.shape
    mh, mw = monster.shape
    monster_pieces = []
    for y in range(mh):
        for x in range(mw):
            if monster[y][x] == 1:
                monster_pieces.append((y, x))
    mfound = True
    for my, mx in monster_pieces:
        if monster[my][mx] != 1:
            mfound = False
            break
    if mfound:
        print("Test Passed")
    else:
        sys.exit(1)
    mcount = 0
    image2 = np.copy(image)
    for y in range(ih-mh):
        for x in range(iw-mw):
            mfound = True
            for my, mx in monster_pieces:
                if image[y+my][x+mx] != 1:
                    mfound = False
                    break
            if mfound:
                mcount = mcount + 1
                for yy, xx in monster_pieces:
                    image2[y+yy][x+xx] = 0
    count = 0
    for yy in range(ih):
        for xx in range(iw):
            count = count + image2[yy][xx]
    return (mcount, count)


def main():
    (tiles, tile_images) = readdata("input.txt")
    vtiles = {}
    for t in tiles.values():
        vtiles[t.id] = TileView(t)
    #vtiles = [TileView(t) for t in tiles.values()]
    corners = find_corners(vtiles)
    print("corners = ", corners)
    print(reduce(lambda a, b: a*b, corners, 1))

    tilearray = trytogrow(vtiles[corners[0]], vtiles)
    image = make_image(tilearray, vtiles, tile_images)
    monster = readmonster("monster.txt")
    for o in orientations:
        monster = reorient_image(monster, o)
        rv = convolve(image, monster)
        print(rv)

    # for c in corners:
    #     print("Corner", c)
    #     cur = tiles[c]
    #     nbrs = get_neighbors(c, tiles)
    #     print(nbrs)


if __name__ == "__main__":
    main()
