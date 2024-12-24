#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function abs(x) {
    return (x < 0) ? -x : x
}
function go(x, y, t,   p) {
    p = (x SUBSEP y)
    if (!(p in WALLS) && !(p in TIME)) {
        if (DEBUG > 3) {
            printf(" (%d,%d)", x,y)
        }
        TIME[p] = t
        ++COMPUTE[t][p]
    }
    return p
}
function traverse(   t, p, c) {
    for (t = 1; t <= MAX_TIME; ++t) {
        if (DEBUG > 2) {
            printf("computing time %d", t)
            if (DEBUG > 3) {
                printf(":")
            }
        }
        for (p in COMPUTE[t-1]) {
            split(p, c, SUBSEP)
            if (go(c[1]-1, c[2], t) == FINISH) return
            if (go(c[1]+1, c[2], t) == FINISH) return
            if (go(c[1], c[2]-1, t) == FINISH) return
            if (go(c[1], c[2]+1, t) == FINISH) return
        }
        if (DEBUG > 2) {
            printf("\n")
        }
    }
}
BEGIN {
    DEBUG = 0
    FS = ""
}
$0 !~ /^[SE.#]+$/ {
    report_error("DATA ERROR: " $0)
}
{
    for (i=1; i <= NF; ++i) {
        MAP[i,NR] = $i
        switch ($i) {
            case "#":
            ++WALLS[i,NR]
            break
            case "S":
            START = (i SUBSEP NR)
            MAP[i,NR] = "."
            if (DEBUG) {
                printf("START at (%d,%d)\n", i, NR)
            }
            break
            case "E":
            FINISH = (i SUBSEP NR)
            MAP[i,NR] = "."
            if (DEBUG) {
                printf("FINISH at (%d,%d)\n", i, NR)
            }
            break
        }
    }
    HEIGHT = NR
    if (!WIDTH) {
        WIDTH = NF
    } else if (WIDTH != NF) {
        report_error("DATA ERROR: width changed from " WIDTH " to " NF " with " $0)
    }
}
END {
    report_error()
    CUTOFF = (HEIGHT > 20) ? 100 : 50
    MAX_TIME = WIDTH * HEIGHT
    TIME[START] = 0
    ++COMPUTE[0][START]
    traverse()
    if (DEBUG > 2) {
        printf("\n")
    }
    if (DEBUG) {
        for (y = 1; y <= HEIGHT; ++y) {
            for (x = 1; x <= WIDTH; ++x) {
                p = (x SUBSEP y)
                if (p in WALLS) {
                    printf("###")
                } else if (p in TIME) {
                    printf("%3d", TIME[p])
                } else {
                    printf(" . ")
                }
            }
            printf("\n")
        }
    }
    latest_start = TIME[FINISH] - CUTOFF
    SHORTCUTS = 0
    for (t = 0; t <= latest_start; ++t) {
        for (p in COMPUTE[t]) {
            split(p, c, SUBSEP)
            x = c[1]
            y = c[2]
            for (xd = -20; xd <= 20; ++xd) {
                for (yd = -20+abs(xd); yd <= 20-abs(xd); ++yd) {
                    if (TIME[x+xd,y+yd] >= t+abs(xd)+abs(yd)+CUTOFF) {
                        ++SHORTCUTS
                        if (DEBUG) {
                            ++SAVINGS[TIME[x+xd,y+yd]-(t+abs(xd)+abs(yd))]
                        }
                        if (DEBUG > 1) {
                            printf("%d ps shortcut from (%d,%d) [%d] to (%d,%d) [%d]\n", TIME[x+xd,y+yd]-(t+abs(xd)+abs(yd)), x, y, t, x+xd, y+yd, TIME[x+xd,y+yd])
                        }
                    }
                }
            }
        }
    }
    if (DEBUG) {
        for (s in SAVINGS) {
            print SAVINGS[s], "shortcuts save", s, "picoseconds"
        }
    }
    print SHORTCUTS
}
