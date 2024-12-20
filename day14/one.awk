#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FPAT = "-?[[:digit:]]+"
    WIDTH = 11
    MIDX = 5
    HEIGHT = 7
    MIDY = 3
}
$0 !~ /^p=-?[[:digit:]]+,-?[[:digit:]]+ v=-?[[:digit:]]+,-?[[:digit:]]+$/ {
    report_error("DATA ERROR: $0")
}
{
    X[NR] = $1
    Y[NR] = $2
    VX[NR] = $3
    VY[NR] = $4
    if (($1 >= WIDTH) || ($2 >= HEIGHT)) {
        WIDTH = 101
        MIDX = 50
        HEIGHT = 103
        MIDY = 51
    }
    if (DEBUG) {
        printf("Robot at (%d,%d) is moving at (%d,%d)\n", $1, $2, $3, $4)
    }
}
END {
    report_error()
    q1 = q2 = q3 = q4 = 0
    if (DEBUG) {
        printf("%d robots on %d x %d field with midpoint (%d,%d)\n", NR, WIDTH, HEIGHT, MIDX, MIDY)
    }
    for (i = 1; i <= NR; ++i) {
        if (DEBUG) {
            printf("Robot at (%d,%d)", X[i], Y[i])
        }
        X[i] = (X[i] + 100 * VX[i]) % WIDTH
        if (X[i] < 0) {
            X[i] += WIDTH
        }
        Y[i] = (Y[i] + 100 * VY[i]) % HEIGHT
        if (Y[i] < 0) {
            Y[i] += HEIGHT
        }
        if (DEBUG) {
            printf(" moves to (%d,%d)", X[i], Y[i])
        }
        if (X[i] < MIDX) {
            if (Y[i] < MIDY) {
                ++q1
                if (DEBUG) {
                    printf(" (quadrant 1)")
                }
            } else if (Y[i] > MIDY) {
                ++q3
                if (DEBUG) {
                    printf(" (quadrant 3)")
                }
            }
        } else if (X[i] > MIDX) {
            if (Y[i] < MIDY) {
                ++q2
                if (DEBUG) {
                    printf(" (quadrant 2)")
                }
            } else if (Y[i] > MIDY) {
                ++q4
                if (DEBUG) {
                    printf(" (quadrant 4)")
                }
            }
        }
        if (DEBUG) {
            printf("\n")
        }
    }
    print q1*q2*q3*q4
}
