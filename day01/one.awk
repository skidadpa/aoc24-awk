#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function abs(x) { return x < 0 ? -x : x }
BEGIN {
    DEBUG = 0
}
(NF != 2) { report_error("Illegal line:" $0) }
{
    left[NR] = 0 + $1
    right[NR] = 0 + $2
}
END {
    report_error()
    n = asort(left)
    asort(right)
    for (i = 1; i <= n; ++i) {
        total += abs(left[i] - right[i])
    }
    print total
}
