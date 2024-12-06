#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ""
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3
    DX[UP] = DX[DOWN] = DY[LEFT] = DY[RIGHT] = 0
    DX[LEFT] = DY[UP] = -1
    DX[RIGHT] = DY[DOWN] = 1
    DIRS = 4
    STUCK = 0
    NOT_STUCK = 1
}
function patrol(    x, y, dir, i, nx, ny) {
    split("", VISITED)
    x = start_x
    y = start_y
    dir = start_dir
    while ((x SUBSEP y) in MAP) {
        if (++VISITED[x,y] > DIRS) {
            return STUCK
        }
        for (i = 0; i < DIRS; ++i) {
            nx = x + DX[dir]
            ny = y + DY[dir]
            if ((nx SUBSEP ny) in OBSTACLES) {
                dir = (dir + 1) % DIRS
            } else {
                break
            }
        }
        if (i >= DIRS) {
            report_error("ERROR: no moves at " x "," y)
            return STUCK
        }
        x = nx
        y = ny
    }
    return NOT_STUCK
}
{
    for (i = 1; i <= NF; ++i) {
        MAP[i,NR] = $i
        if ($i == "#") {
            OBSTACLES[i,NR] = 1
        } else if ($i == "^") {
            MAP[i,NR] = "."
            start_x = i
            start_y = NR
            start_dir = UP
        } else if ($i != ".") {
            report_error("Invalid square " $i " in " $0)
        }
    }
    height = NR
    width = NF
}
END {
    report_error()
    if (DEBUG) {
        print "MAP:"
        for (iy = 1; iy <= height; ++iy) {
            for (ix = 1; ix <= width; ++ix) {
                printf("%c", MAP[ix,iy])
            }
            printf("\n")
        }
        print "start: x =", x, "y =", y, "dir = UP"
    }
    patrol()
    start_square = start_x SUBSEP start_y
    for (i in VISITED) {
        if (i != start_square) {
            CANDIDATES[i] = 1
        }
    }
    if (DEBUG) {
        print "route length =", length(VISITED)
        print length(CANDIDATES), "candidate locations"
    }
    # Terribly inefficient but effective...
    for (i in CANDIDATES) {
        if (DEBUG) {
            ++tries
        }
        OBSTACLES[i] = 1
        if (patrol() == STUCK) {
            if (DEBUG) {
                split(i, c, SUBSEP)
                print "at try", tries ", obstacle at", c[1] "," c[2], "causes loop"
            }
            ++loops
        }
        delete OBSTACLES[i]
    }
    print loops
}
