#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function test(   X, Y, from, to, moves, x, y) {
    X[1] = X[4] = X[7] = X[W] = 1
    X[0] = X[2] = X[5] = X[8] = X[N] = X[S] = 2
    X[A] = X[3] = X[6] = X[9] = X[E] = 3
    Y[7] = Y[8] = Y[9] = 1
    Y[4] = Y[5] = Y[6] = 2
    Y[1] = Y[2] = Y[3] = 3
    Y[0] = Y[N] = Y[A] = 4
    Y[W] = Y[S] = Y[E] = 5
    for (from in KEYPAD) {
        for (to in KEYPAD) {
            if (!(to in KEYPAD[from])) {
                report_error("missing KEYPAD path from " from " to " to)
            }
            x = X[from]
            y = Y[from]
            moves = KEYPAD[from][to]
            for (i = 1; i < length(moves); ++i) {
                switch (substr(moves, i, 1)) {
                case "<":
                    x -= 1
                    break
                case ">":
                    x += 1
                    break
                case "^":
                    y -= 1
                    break
                case "v":
                    y += 1
                    break
                default:
                    report_error("PROGRAM ERROR: unknown direction in " moves)
                }
            }
            if ((x != X[to]) || (y != Y[to])) {
                report_error(moves " does not go from " from " (" X[from] "," Y[from] ") to " to " (" X[from] "," Y[to] ")")
            }
        }
    }
    for (from in DIRPAD) {
        for (to in DIRPAD) {
            if (!(to in DIRPAD[from])) {
                report_error("missing DIRPAD path from " from " to " to)
            }
            x = X[from]
            y = Y[from]
            moves = DIRPAD[from][to]
            for (i = 1; i < length(moves); ++i) {
                switch (substr(moves, i, 1)) {
                case "<":
                    x -= 1
                    break
                case ">":
                    x += 1
                    break
                case "^":
                    y -= 1
                    break
                case "v":
                    y += 1
                    break
                default:
                    report_error("PROGRAM ERROR: unknown direction in " moves)
                }
            }
            if ((x != X[to]) || (y != Y[to])) {
                report_error(moves " does not go from " from " (" X[from] "," Y[from] ") to " to " (" X[from] "," Y[to] ")")
            }
        }
    }
}
BEGIN {
    DEBUG = 0
    A = "A"
    N = "^"
    S = "v"
    E = ">"
    W = "<"
    KEYPAD[A][A] = "A"
    KEYPAD[A][0] = "<A"
    KEYPAD[A][1] = "^<<A"
    KEYPAD[A][2] = "<^A"
    KEYPAD[A][3] = "^A"
    KEYPAD[A][4] = "^^<<A"
    KEYPAD[A][5] = "<^^A"
    KEYPAD[A][6] = "^^A"
    KEYPAD[A][7] = "^^^<<A"
    KEYPAD[A][8] = "<^^^A"
    KEYPAD[A][9] = "^^^A"
    KEYPAD[0][A] = ">A"
    KEYPAD[1][A] = ">>vA"
    KEYPAD[2][A] = "v>A"
    KEYPAD[3][A] = "vA"
    KEYPAD[4][A] = ">>vvA"
    KEYPAD[5][A] = "vv>A"
    KEYPAD[6][A] = "vvA"
    KEYPAD[7][A] = ">>vvvA"
    KEYPAD[8][A] = "vvv>A"
    KEYPAD[9][A] = "vvvA"
    KEYPAD[0][1] = "^<A"
    KEYPAD[0][2] = "^A"
    KEYPAD[0][3] = "^>A"
    KEYPAD[0][4] = "^^<A"
    KEYPAD[0][5] = "^^A"
    KEYPAD[0][6] = "^^>A"
    KEYPAD[0][7] = "^^^<A"
    KEYPAD[0][8] = "^^^A"
    KEYPAD[0][9] = "^^^>A"
    KEYPAD[1][0] = ">vA"
    KEYPAD[2][0] = "vA"
    KEYPAD[3][0] = "<vA"
    KEYPAD[4][0] = ">vvA"
    KEYPAD[5][0] = "vvA"
    KEYPAD[6][0] = "<vvA"
    KEYPAD[7][0] = ">vvvA"
    KEYPAD[8][0] = "vvvA"
    KEYPAD[9][0] = "<vvvA"
    KEYPAD[0][0] = KEYPAD[1][1] = KEYPAD[2][2] = KEYPAD[3][3] = KEYPAD[4][4] = "A"
    KEYPAD[5][5] = KEYPAD[6][6] = KEYPAD[7][7] = KEYPAD[8][8] = KEYPAD[9][9] = "A"
    KEYPAD[1][2] = KEYPAD[2][3] = KEYPAD[4][5] = KEYPAD[5][6] = KEYPAD[7][8] = KEYPAD[8][9] = ">A"
    KEYPAD[2][1] = KEYPAD[3][2] = KEYPAD[5][4] = KEYPAD[6][5] = KEYPAD[8][7] = KEYPAD[9][8] = "<A"
    KEYPAD[1][4] = KEYPAD[2][5] = KEYPAD[3][6] = KEYPAD[4][7] = KEYPAD[5][8] = KEYPAD[6][9] = "^A"
    KEYPAD[4][1] = KEYPAD[5][2] = KEYPAD[6][3] = KEYPAD[7][4] = KEYPAD[8][5] = KEYPAD[9][6] = "vA"
    KEYPAD[1][3] = KEYPAD[4][6] = KEYPAD[7][9] = ">>A"
    KEYPAD[3][1] = KEYPAD[6][4] = KEYPAD[9][7] = "<<A"
    KEYPAD[1][7] = KEYPAD[2][8] = KEYPAD[3][9] = "^^A"
    KEYPAD[7][1] = KEYPAD[8][2] = KEYPAD[9][3] = "vvA"
    KEYPAD[1][5] = KEYPAD[2][6] = KEYPAD[4][8] = KEYPAD[5][9] = "^>A"
    KEYPAD[5][1] = KEYPAD[6][2] = KEYPAD[8][4] = KEYPAD[9][5] = "<vA"
    KEYPAD[2][4] = KEYPAD[3][5] = KEYPAD[5][7] = KEYPAD[6][8] = "<^A"
    KEYPAD[4][2] = KEYPAD[5][3] = KEYPAD[7][5] = KEYPAD[8][6] = "v>A"
    KEYPAD[1][6] = KEYPAD[4][9] = "^>>A"
    KEYPAD[6][1] = KEYPAD[9][4] = "<<vA"

    KEYPAD[1][8] = KEYPAD[2][9] = "^^>A"
    KEYPAD[8][1] = KEYPAD[9][2] = "<vvA"
    KEYPAD[1][9] = "^^>>A"
    KEYPAD[9][1] = "<<vvA"

    KEYPAD[2][7] = KEYPAD[3][8] = "<^^A"
    KEYPAD[7][2] = KEYPAD[8][3] = "vv>A"

    KEYPAD[3][7] = "<<^^A"
    KEYPAD[7][3] = "vv>>A"

    KEYPAD[3][4] = KEYPAD[6][7] = "<<^A"
    KEYPAD[4][3] = KEYPAD[7][6] = "v>>A"

    DIRPAD[A][A] = "A"
    DIRPAD[A][N] = "<A"
    DIRPAD[A][W] = "v<<A"
    DIRPAD[A][S] = "<vA"
    DIRPAD[A][E] = "vA"
    DIRPAD[N][A] = ">A"
    DIRPAD[N][N] = "A"
    DIRPAD[N][W] = "v<A"
    DIRPAD[N][S] = "vA"
    DIRPAD[N][E] = "v>A"
    DIRPAD[W][A] = ">>^A"
    DIRPAD[W][N] = ">^A"
    DIRPAD[W][W] = "A"
    DIRPAD[W][S] = ">A"
    DIRPAD[W][E] = ">>A"
    DIRPAD[S][A] = "^>A"
    DIRPAD[S][N] = "^A"
    DIRPAD[S][W] = "<A"
    DIRPAD[S][S] = "A"
    DIRPAD[S][E] = ">A"
    DIRPAD[E][A] = "^A"
    DIRPAD[E][N] = "<^A"
    DIRPAD[E][W] = "<<A"
    DIRPAD[E][S] = "<A"
    DIRPAD[E][E] = "A"

    FS = ""
    COMPLEXITY = 0
}
$0 !~ /^[[:digit:]]{3}A$/ {
    report_error("DATA ERROR: " $0)
}
{
    pos = A
    moves = ""
    for (i = 1; i <= NF; ++i) {
        moves = moves KEYPAD[pos][$i]
        pos = $i
    }
    for (robot = 1; robot <= 2; ++robot) {
        if (DEBUG > 1) {
            print "  ", robot, ":", moves
        }
        robot_moves = ""
        for (i = 1; i <= length(moves); ++i) {
            if (DEBUG > 2) {
                print "moving from", pos, "to", substr(moves,i,1)
            }
            robot_moves = robot_moves DIRPAD[pos][substr(moves, i, 1)]
            pos = substr(moves, i, 1)
        }
        moves = robot_moves
    }
    if (DEBUG) {
        print $0, ":", moves, "(" length(moves) ")"
    }
    numeric = 0 + substr($0, 1, length($0))
    COMPLEXITY += length(moves) * numeric
}
END {
    report_error()
    if (DEBUG) {
        test()
    }
    print COMPLEXITY
}
