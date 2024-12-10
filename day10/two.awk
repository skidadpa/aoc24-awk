#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ""
}
$0 !~ /^[.[:digit:]]+$/ {
    report_error("Illegal map line " $0)
}
{
    for (i = 1; i <= NF; ++i) {
        MAP[i,NR] = $i
        if ($i != ".") {
            HEIGHT[$i][i,NR] = 1
        }
    }
    width = NF
    height = NR
}
END {
    if (DEBUG) {
        for (y = 1; y <= height; ++y) {
            for (x = 1; x <= width; ++x) {
                printf(" %s", MAP[x,y])
            }
            printf("\n")
        }
    }
    for (coords in MAP) {
        NUM_PATHS[coords] = 0
    }
    if (DEBUG > 1) {
        print "Height", 9
    }
    for (coords in HEIGHT[9]) {
        if (DEBUG > 1) {
            split(coords, c, SUBSEP)
            print "1 path at", c[1] "," c[2]
        }
        ++NUM_PATHS[coords]
    }
    for (h = 8; h >= 0; --h) {
        if (DEBUG > 1) {
            print "Height", h
        }
        for (coords in HEIGHT[h]) {
            split(coords, c, SUBSEP)
            if ((c[1]+1,c[2]) in HEIGHT[h+1]) {
                if (DEBUG > 2) {
                    print NUM_PATHS[c[1]+1,c[2]], "paths through", c[1]+1 "," c[2]
                }
                NUM_PATHS[coords] += NUM_PATHS[c[1]+1,c[2]]
            }
            if ((c[1]-1,c[2]) in HEIGHT[h+1]) {
                if (DEBUG > 2) {
                    print NUM_PATHS[c[1]-1,c[2]], "paths through", c[1]-1 "," c[2]
                }
                NUM_PATHS[coords] += NUM_PATHS[c[1]-1,c[2]]
            }
            if ((c[1],c[2]+1) in HEIGHT[h+1]) {
                if (DEBUG > 2) {
                    print NUM_PATHS[c[1],c[2]+1], "paths through", c[1] "," c[2]+1
                }
                NUM_PATHS[coords] += NUM_PATHS[c[1],c[2]+1]
            }
            if ((c[1],c[2]-1) in HEIGHT[h+1]) {
                if (DEBUG > 2) {
                    print NUM_PATHS[c[1],c[2]-1], "paths through", c[1] "," c[2]-1
                }
                NUM_PATHS[coords] += NUM_PATHS[c[1],c[2]-1]
            }
            if (DEBUG > 1) {
                print "->", NUM_PATHS[coords], "paths from", c[1] "," c[2]
            }
        }
    }
    for (coords in HEIGHT[0]) {
        sum += NUM_PATHS[coords]
    }
    report_error()
    print sum
}
