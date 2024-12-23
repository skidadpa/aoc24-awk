#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ""
    EAST = 0
    SOUTH = 1
    WEST = 2
    NORTH = 3
    MOVE[EAST] = "EAST"
    MOVE[SOUTH] = "SOUTH"
    MOVE[WEST] = "WEST"
    MOVE[NORTH] = "NORTH"
    INITIAL_FACING = EAST
    GO_STRAIGHT = 0
    TURN_LEFT = 3
    TURN_RIGHT = 1
}
function print_coords(coords,   c) {
    split(coords, c, SUBSEP)
    printf("(%d,%d) facing %s", c[1], c[2], MOVE[c[3]])
}
function step(coords, turn,    c) {
    split(pos, c, SUBSEP)
    c[3] += turn
    c[3] %= 4
    switch (c[3]) {
    case 0: # EAST:
        ++c[1]
        break
    case 1: # SOUTH:
        ++c[2]
        break
    case 2: # WEST:
        --c[1]
        break
    case 3: # NORTH:
        --c[2]
        break
    default:
        report_error("PROCESSING ERROR: unrecognized direction " dir)
    }
    return (c[1] SUBSEP c[2] SUBSEP c[3])
}
function conditional_move(pos, turn, cost,   move) {
    move = step(pos, turn)
    if (!(move in SEEN) && !(move in WALLS)) {
        if (DEBUG > 2) {
            printf("Adding move to ")
            print_coords(move)
            printf("\n")
        }
        ++COST[cost][move]
    }
}
$0 !~ /^[#.SE]+$/ {
    report_error("DATA ERROR: $0")
}
{
    for (i = 1; i <= NF; ++i) {
        MAP[i,NR] = $i
        switch ($i) {
        case "#":
            WALLS[i,NR,EAST] = WALLS[i,NR,SOUTH] = WALLS[i,NR,WEST] = WALLS[i,NR,NORTH] = 1
            break
        case "S":
            START = (i SUBSEP NR SUBSEP INITIAL_FACING)
            MAP[i,NR] = "."
            break
        case "E":
            FINISH[i,NR,EAST] = FINISH[i,NR,SOUTH] = FINISH[i,NR,WEST] = FINISH[i,NR,NORTH] = 1
            MAP[i,NR] = "."
            break
        }
    }
    WIDTH = NF
    HEIGHT = NR
}
function print_map(   x, y) {
    for (y = 1; y <= HEIGHT; ++y) {
        for (x = 1; x <= WIDTH; ++x) {
            printf("%s", MAP[x,y])
        }
        printf("\n")
    }
}
END {
    report_error()
    if (DEBUG) {
        print_map()
        split(START, c1, SUBSEP)
    }
    COST_LIMIT = 5000000
    ++COST[0][START]
    for (c = 0; c < COST_LIMIT; ++c) {
        if (c in COST) for (pos in COST[c]) {
            if (DEBUG > 1) {
                printf("%d: Evaluating move to ", c)
                print_coords(pos)
                printf("\n")
            }
            ++SEEN[pos]
            if (pos in FINISH) {
                print c
                exit
            }
            conditional_move(pos, GO_STRAIGHT, c+1)
            conditional_move(pos, TURN_LEFT, c+1001)
            conditional_move(pos, TURN_RIGHT, c+1001)
        }
    }
    print "NO SOLUTION FOUND WITH SCORE LESS THAN", COST_LIMIT
}
