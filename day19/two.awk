#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function num_arrangements(pattern,   count, start, t, len) {
    if (pattern in COUNTS) {
        return COUNTS[pattern]
    }
    if (DEBUG > 2) {
        print "computing", pattern
    }
    count = 0
    start = substr(pattern,1,1)
    for (t in TOWELS[start]) {
        len = TOWELS[start][t]
        if (substr(pattern, 1, len) == t) {
            count += num_arrangements(substr(pattern, len+1))
        }
    }
    if (DEBUG > 2) {
        print count, "arrangements for", pattern
    }
    COUNTS[pattern] = count
    return count
}
BEGIN {
    DEBUG = 0
    FS = ", "
    ARRANGEMENTS = 0
    COUNTS[""] = 1
}
(NR == 1) && ($0 !~ /^[wubrg]+(, [wubrg]+)*$/) {
    report_error("DATA ERROR: line " NR " unrecognized pattern " $0)
}
(NR == 1) {
    PATTERN = "^((" $i ")"
    for (i = 1; i <= NF; ++i) {
        PATTERN = PATTERN "|(" $i ")"
        TOWELS[substr($i,1,1)][$i] = length($i)
    }
    if (DEBUG) {
        print NF, "towel patterns:"
        for (t in TOWELS) {
            print "", t, ":", length(TOWELS[t])
        }
    }
    PATTERN = PATTERN ")+$"
}
(NR == 2) && ($0 !~ /^$/) {
    report_error("DATA ERROR: line " NR " expecting blank line got " $0)
}
(NR > 2) && ($0 !~ /^[wubrg]+$/) {
    report_error("DATA ERROR: line " NR " unrecognized pattern " $0)
}
(NR > 2) && ($0 ~ PATTERN) {
    if (DEBUG) {
        print (NR - 2), ":", $0
    }
    ARRANGEMENTS += num_arrangements($0)
}
END {
    report_error()
    print ARRANGEMENTS
}
