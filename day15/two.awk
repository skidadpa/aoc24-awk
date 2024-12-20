#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function print_map(   x, y, coords) {
    for (y = TOP; y <= BOTTOM; ++y) {
        for (x = LEFT; x <= RIGHT; ++x) {
            coords = (x SUBSEP y)
            if (coords in WALLS) {
                printf("#")
            } else if (coords in BOXES) {
                printf("%s", BOXES[coords] < 2 ? "[" : "]")
            } else if (coords == ROBOT) {
                printf("@")
            } else {
                printf(".")
            }
        }
        printf("\n")
    }
}
function step(coords, m,   c) {
    split(coords, c, SUBSEP)
    if (DEBUG > 3) {
        printf("....step from (%d,%d)", c[1], c[2])
    }
    switch (m) {
    case "<":
        --c[1]
        break
    case ">":
        ++c[1]
        break
    case "^":
        --c[2]
        break
    case "v":
        ++c[2]
        break
    default:
        report_error("PROCESSING ERROR: unrecognized move " m)
    }
    if (DEBUG > 3) {
        printf(" to (%d,%d)\n", c[1], c[2])
    }
    return (c[1] SUBSEP c[2])
}
function can_push_boxes(pos, m,   pair_pos, ok) {
    switch (m) {
    case "<":
    case ">":
        while (pos in BOXES) {
            pos = step(pos, m)
        }
        return (!(pos in WALLS))
    case "^":
    case "v":
        pair_pos = step(pos, (BOXES[pos] < RIGHT_BOX) ? ">" : "<")
        pos = step(pos, m)
        if (pos in BOXES) {
            ok = can_push_boxes(pos, m)
        } else {
            ok = !(pos in WALLS)
        }
        if (ok) {
            pos = step(pair_pos, m)
            if (pos in BOXES) {
                ok = can_push_boxes(pos, m)
            } else {
                ok = !(pos in WALLS)
            }
        }
        return ok
    }
    
    report_error("PROCESSING ERROR: unrecognized move " m)
    return 0
}
function can_robot_move(m,   pos) {
    pos = step(ROBOT, m)
    if (pos in BOXES) {
        return can_push_boxes(pos, m)
    }
    return (!(pos in WALLS))
}
function push_boxes(pushed_box, pos, m,   pair_pos, c) {
    if (DEBUG > 3) {
        split(pos, c, SUBSEP)
        printf("pushing %s from (%d,%d)\n", m, c[1], c[2])
    }
    if (pos in BOXES) {
        if (DEBUG > 3) {
            print "in a BOX"
        }
        push_boxes(BOXES[pos], step(pos, m), m)
        if ((pushed_box != PAIR_BOX) && ((m == "^") || (m == "v"))) {
            pair_pos = step(pos, (BOXES[pos] < RIGHT_BOX) ? ">" : "<")
            if (!(pair_pos in BOXES)) {
                report_error("PROCESSING ERROR: box pair not in boxes array")
            }
            push_boxes(PAIR_BOX, pair_pos, m)
        }
    }
    if (pushed_box <= NON_BOX) {
        if (DEBUG > 3) {
            printf("deleting box at (%d,%d)\n", c[1], c[2])
        }
        if (!(pos in BOXES)) {
            report_error("PROCESSING ERROR: pushed box not in boxes array")
        }
        delete BOXES[pos]
    } else {
        if (DEBUG > 3) {
            printf("moving box %d to (%d,%d)\n", pushed_box, c[1], c[2])
        }
        if ((pos in WALLS)) {
            report_error("PROCESSING ERROR: pushed box into wall")
        }
        BOXES[pos] = pushed_box
    }
}
function move_robot(m,   pos) {
    ROBOT = step(ROBOT, m)
    if (ROBOT in BOXES) {
        if (DEBUG > 2) {
            print "...moving boxes"
        }
        push_boxes(NON_BOX, ROBOT, m)
    }
    if (ROBOT in WALLS) {
        report_error("PROCESSING ERROR: robot ran into a wall")
    }
}
BEGIN {
    DEBUG = 0
    FS = ""
    PAIR_BOX = -1
    NON_BOX = 0
    LEFT_BOX = 1
    RIGHT_BOX = 2
}
/^#+$/ {
    if (!TOP) {
        TOP = NR
        LEFT = 2
        RIGHT = 2*NF-1
        if (TOP != 1) {
            report_error("DATA ERROR: first top at line " NR)
        }
    } else if (2*NF-1 != RIGHT) {
        report_error("DATA ERROR: bottom width " NF " instead of " RIGHT " at line " NR)
    } else if (!BOTTOM) {
        BOTTOM = NR
    } else {
        report_error("DATA ERROR: second bottom at line " NR)
    }
    for (i = 1; i <= NF; ++i) {
        WALLS[2*i-1,NR] = 1
        WALLS[2*i,NR] = 1
    }
    next
}
/^#[.#@O]+#$/ {
    if (!TOP) {
        report_error("DATA ERROR: map data before top at line  " NR)
    } else if (BOTTOM) {
        report_error("DATA ERROR: map data after bottom at line  " NR)
    } else if (2*NF-1 != RIGHT) {
        report_error("DATA ERROR: map width " NF " instead of " RIGHT " at line " NR)
    }
    for (i = 1; i <= NF; ++i) {
        switch ($i) {
        case "#":
            WALLS[2*i-1,NR] = 1
            WALLS[2*i,NR] = 1
            break
        case "O":
            BOXES[2*i-1,NR] = LEFT_BOX
            BOXES[2*i,NR] = RIGHT_BOX
            break
        case "@":
            ROBOT = (2*i-1 SUBSEP NR)
            break
        case ".":
            break
        default:
            report_error("DATA ERROR: unrecognized square " $i " in " $0)
        }
    }
    next
}
/^$/ {
    if (!BOTTOM) {
        report_error("DATA ERROR: divider seen with no bottom at line " NR)
    }
    next
}
/^[<>^v]+$/ {
    for (i = 1; i <= NF; ++i) {
        MOVES[++num_moves] = $i
    }
    next
}
{
    report_error("DATA ERROR: unrecognized line " $0)
}
END {
    report_error()
    if (!num_moves) {
        report_error("DATA ERROR: no moves detected")
    }
    if (num_moves != length(MOVES)) {
        report_error("PROCESSING ERROR: illegal move array")
    }
    if (DEBUG) {
        print "At start:"
        print_map()
        split(ROBOT, c, SUBSEP)
        printf("Robot starting at (%d,%d), processing %d moves\n", c[1], c[2], num_moves)
    }
    for (i = 1; i <= num_moves; ++i) {
        if (DEBUG > 1) {
            print "Move", i, ":", MOVES[i]
        }
        if (can_robot_move(MOVES[i])) {
            if (DEBUG > 1) {
                print "...can move robot"
            }
            move_robot(MOVES[i])
        }
        if (DEBUG > 2) {
            print_map()
        }
    }
    if (DEBUG) {
        print "At end:"
        print_map()
    }
    gps_sum = 0
    for (coords in BOXES) {
        if (BOXES[coords] == RIGHT_BOX) {
            split(coords, c, SUBSEP)
            gps_sum += 100 * (c[2] - TOP) + (c[1] - LEFT)
        }
    }
    print gps_sum
}
