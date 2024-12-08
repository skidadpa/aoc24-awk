#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ""
}
$0 !~ /^[.[:alnum:]]+$/ {
    report_error("ERROR: illegal line " $0)
}
{
    for (i = 1; i <= NF; ++i) {
        MAP[i,NR] = "" $i
        if ($i != ".") {
            ANTENNAS[$i][i,NR] = 1
        }
    }
    width = NF
    height = NR
}
END {
    report_error()
    if (DEBUG) {
        print "MAP:"
        for (y = 1; y <= height; ++y)  {
            for (x = 1; x <= width; ++x) {
                printf("%c", MAP[x,y])
            }
            printf("\n")
        }
        print "ANTENNAS:"
        for (a in ANTENNAS) {
            printf("%c:", a)
            for (coords in ANTENNAS[a]) {
                split(coords, c, SUBSEP)
                printf(" %d,%d", c[1], c[2])
            }
            printf("\n")
        }
    }
    if (DEBUG > 1) {
        print "ANTINODES:"
    }
    for (a in ANTENNAS) {
        for (coords0 in ANTENNAS[a]) {
            if (DEBUG > 1) {
                printf("%c:", a)
            }
            split(coords0, c0, SUBSEP)
            x0 = 0 + c0[1]
            y0 = 0 + c0[2]
            for (coords1 in ANTENNAS[a]) {
                if (coords1 != coords0) {
                    split(coords1, c1, SUBSEP)
                    x1 = 0 + c1[1]
                    y1 = 0 + c1[2]
                    x = (x1 - x0) + x1
                    y = (y1 - y0) + y1
                    if ((x,y) in MAP) {
                        ++ANTINODES[x,y]
                    }
                    if (DEBUG > 1) {
                        printf(" ")
                    }
                    if (DEBUG > 2) {
                        printf("%d,%d->%d,%d=", x0, y0, x1, y1)
                    }
                    if (DEBUG > 1) {
                        printf("%c", ((x,y) in ANTINODES)?"(":"[")
                        printf("%d,%d", x, y)
                        printf("%c", ((x,y) in ANTINODES)?")":"]")
                    }
                }
            }
            if (DEBUG > 1) {
                printf("\n")
            }
        }
    }
    print length(ANTINODES)
}
