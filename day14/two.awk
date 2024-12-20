#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function map_row(ROW,   x, s) {
    s = ""
    for (x = 0; x < WIDTH; ++x) {
        if (x in ROW) {
            s = s "X"
        } else {
            s = s "."
        }
    }
    return s
}
function show_map(   y) {
    for (y = 0; y < HEIGHT; ++y) {
        if (y in ROWS) {
            print map_row(ROWS[y])
        } else {
            print map_row(EMPTY_ROW)
        }
    }
}
BEGIN {
    DEBUG = 0
    FPAT = "-?[[:digit:]]+"
    WIDTH = 101
    HEIGHT = 103
    BASE_MATCH = "XXXXXXXXXXXX"
    split("", EMPTY_ROW)
}
$0 !~ /^p=-?[[:digit:]]+,-?[[:digit:]]+ v=-?[[:digit:]]+,-?[[:digit:]]+$/ {
    report_error("DATA ERROR: $0")
}
{
    X[NR] = $1
    Y[NR] = $2
    VX[NR] = $3
    VY[NR] = $4
    ROWS[$2][$1] = 1
}
END {
    report_error()
    if (NR < 20) {
        print NR
        exit
    }
    if (DEBUG > 1) {
        print "Initially:"
        show_map()
    }
    BASE_MATCH_LEN = length(BASE_MATCH)
    for (n = 1; n <= 50000; ++n) {
        split("", ROWS)
        for (i = 1; i <= NR; ++i) {
            X[i] += VX[i]
            X[i] %= WIDTH
            if (X[i] < 0) {
                X[i] += WIDTH
            }
            Y[i] += VY[i]
            Y[i] %= HEIGHT
            if (Y[i] < 0) {
                Y[i] += HEIGHT
            }
            ROWS[Y[i]][X[i]] = 1
        }
        found = 0
        for (y = 0; y < HEIGHT; ++y) {
            if ((y in ROWS) && (length(ROWS[y]) >= BASE_MATCH_LEN) && (map_row(ROWS[y]) ~ BASE_MATCH)) {
                if (DEBUG) {
                    print "After", n, "move(s):"
                    show_map()
                }
                print n
                exit
            }
        }
    }
    print "NOT FOUND"
}
