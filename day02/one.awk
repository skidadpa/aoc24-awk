#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
}
$0 !~ /^[0-9 ]*$/ { report_error("illegal data: " $0) }
NF < 2 { report_error("too few fields: " $0) }
{
    left = 0 + $1
    right = 0 + $2
    increasing = (left < right)
    for (i = 1; i < NF; ++i) {
        left = 0 + $(i)
        right = 0 + $(i + 1)
        if (increasing) {
            smaller = left
            larger = right
        } else {
            smaller = right
            larger = left
        }
        diff = larger - smaller
        if ((diff < 1) || (diff > 3)) {
            if (DEBUG) {
                print "UNSAFE:", $0
            }
            next
        }
    }
    ++safe
    if (DEBUG) {
        print "SAFE:", $0
    }
}
END {
    report_error()
    print safe
}
