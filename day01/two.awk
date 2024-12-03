#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function abs(x) { return x < 0 ? -x : x }
BEGIN {
    DEBUG = 0
}
(NF != 2) { report_error("Illegal line:" $0) }
{
    ++left[0 + $1]
    ++right[0 + $2]
}
END {
    report_error()
    for (i in left) {
        total += i * left[i] * (0 + right[i])
    }
    print total
}
