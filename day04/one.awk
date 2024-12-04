#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function count_matches(s,   f, b) { split(s, f, "XMAS")
                                    split(s, b, "SAMX")
                                    return length(f) + length(b) - 2 }
BEGIN {
    DEBUG = 0
    FS = ""
}
{
    VERTICAL[NR] = $0
    for (i = 1; i <= NF; ++i) {
        HORIZONTAL[i] = HORIZONTAL[i] $i
        LEFT_DIAG[NF - NR + i] = LEFT_DIAG[NF - NR + i] $i
        RIGHT_DIAG[NR - 1 + i] = $i RIGHT_DIAG[NR - 1 + i] 
    }
}
END {
    report_error()
    for (i in VERTICAL) {
        matches += count_matches(VERTICAL[i])
    }
    for (i in HORIZONTAL) {
        matches += count_matches(HORIZONTAL[i])
    }
    for (i in LEFT_DIAG) {
        matches += count_matches(LEFT_DIAG[i])
    }
    for (i in RIGHT_DIAG) {
        matches += count_matches(RIGHT_DIAG[i])
    }
    print matches
}
