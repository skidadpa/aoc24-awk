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
    for (coords in HEIGHT[9]) {
        TRAILS[coords][coords] = 1
    }
    for (h = 8; h >= 0; --h) {
        for (coords in HEIGHT[h]) {
            split(coords, c, SUBSEP)
            left = (c[1]-1) SUBSEP c[2]
            right = (c[1]+1) SUBSEP c[2]
            up = c[1] SUBSEP (c[2] - 1)
            down = c[1] SUBSEP (c[2] + 1)
            if ((left in HEIGHT[h+1]) && (left in TRAILS)) {
                for (dst in TRAILS[left]) {
                    TRAILS[coords][dst] = 1
                }
            }
            if ((right in HEIGHT[h+1]) && (right in TRAILS)) {
                for (dst in TRAILS[right]) {
                    TRAILS[coords][dst] = 1
                }
            }
            if ((up in HEIGHT[h+1]) && (up in TRAILS)) {
                for (dst in TRAILS[up]) {
                    TRAILS[coords][dst] = 1
                }
            }
            if ((down in HEIGHT[h+1]) && (down in TRAILS)) {
                for (dst in TRAILS[down]) {
                    TRAILS[coords][dst] = 1
                }
            }
        }
    }
    for (coords in HEIGHT[0]) {
        if (coords in TRAILS) {
            sum += length(TRAILS[coords])
        }
    }
    report_error()
    print sum
}
