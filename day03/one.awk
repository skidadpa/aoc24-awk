#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FPAT = "mul\\([[:digit:]]{1,3},[[:digit:]]{1,3}\\)"
}
{
    if (DEBUG) {
        print NF, "ops in", $0
    }
    for (i = 1; i <= NF; ++i) {
        if (DEBUG) {
            print "operation", $i
        }
        split($i, op, /[(,)]/)
        total += op[2] * op[3]
    }
}
END {
    report_error()
    print total
}
