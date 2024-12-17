#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function blink() {
}
BEGIN {
    DEBUG = 0
}
$0 !~ /^[[:digit:]]+( [[:digit:]]+)*$/ {
    report_error("DATA ERROR: " $0)
}
{
    for (i = 1; i <= NF; ++i) {
        ++BLINK[0][$i]
        STARTS[1][$i] = 1
    }
    if (DEBUG) {
        printf("START:")
        total = 0
        for (b in BLINK[0]) {
            printf(" %dx%d", BLINK[0][b], b)
            total += BLINK[0][b]
        }
        printf(" (total %d)\n", total)
    }
    for (start_level = 1; start_level < 75; ++start_level) {
        for (start in STARTS[start_level]) {
            if (start in NEXT) {
                continue
            }
            if (DEBUG > 2) {
                printf("Blinks from %d:", start)
            }
            if (0 + start == 0) {
                ++NEXT[start][1]
            } else {
                len = length("" start)
                if (len % 2 == 0) {
                    ++NEXT[start][0 + substr(start, 1, len/2)]
                    ++NEXT[start][0 + substr(start, len/2 + 1)]
                } else {
                    ++NEXT[start][2024 * (0 + start)]
                }
            }
            for (b in NEXT[start]) {
                if (DEBUG > 2) {
                    printf(" %dx%d", NEXT[start][b], b)
                }
                if (!(b in NEXT)) {
                    STARTS[start_level + 1][b] = 1
                }
            }
            if (DEBUG > 2) {
                printf("\n")
            }
        }
    }
    for (b = 1; b <= 75; ++b) {
        for (stone in BLINK[b - 1]) {
            for (s in NEXT[stone]) {
                BLINK[b][s] += BLINK[b - 1][stone] * NEXT[stone][s]
            }
        }
        if (DEBUG) {
            total = 0
            for (stone in BLINK[b]) {
                total += BLINK[b][stone]
            }
            printf("Pass %d (%d stones)", b, total)
            if (DEBUG > 1) {
                for (stone in BLINK[b]) {
                    printf(" %dx%d", BLINK[b][stone], stone)
                }
            }
            printf("\n")
        }
    }
}
END {
    report_error()
    total = 0
    for (stone in BLINK[75]) {
        total += BLINK[75][stone]
    }
    print total
}
