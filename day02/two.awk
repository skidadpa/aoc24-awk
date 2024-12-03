#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
}
$0 !~ /^[0-9 ]*$/ { report_error("illegal data: " $0) }
NF < 4 { report_error("too few fields: " $0) }
{
    if (DEBUG > 1) {
        print "TESTING :", $0
    }
    for (pass = 0; pass < NF; ++pass) {
        dampened = pass ? pass : NF
        left = 0 + $(dampened <= 1 ? 2 : 1)
        right = 0 + $(dampened <= 2 ? 3 : 2)
        increasing = (left < right)
        if (DEBUG > 1) {
            print "skipping", dampened, ":", increasing ? "increasing" : "decreasing"
        }
        for (i = 1; i < NF - 1; ++i) {
            left = 0 + $(dampened <= i ? i + 1 : i)
            right = 0 + $(dampened <= i + 1 ? i + 2 : i + 1)
            if (increasing) {
                smaller = left
                larger = right
            } else {
                smaller = right
                larger = left
            }
            diff = larger - smaller
            if ((diff < 1) || (diff > 3)) {
                if (DEBUG > 1) {
                    print "fails from", left, "to", right
                }
                break
            }
        }
        if (i >= NF - 1) {
            break
        }
    }
    if (pass < NF) {
        ++safe
    }
    if (DEBUG) {
        if (pass < NF) {
           print "SAFE (", dampened, "):", $0
       } else {
           print "UNSAFE:", $0
       }
    }
}
END {
    report_error()
    print safe
}
