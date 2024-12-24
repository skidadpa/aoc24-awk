#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ", "
    POSSIBLE = 0
}
(NR == 1) && ($0 !~ /^[wubrg]+(, [wubrg]+)*$/) {
    report_error("DATA ERROR: line " NR " unrecognized pattern " $0)
}
(NR == 1) {
    PATTERN = "^((" $i ")"
    for (i = 1; i <= NF; ++i) {
        PATTERN = PATTERN "|(" $i ")"
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
    ++POSSIBLE
}
END {
    report_error()
    print POSSIBLE
}
