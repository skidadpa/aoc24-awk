#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = "[: ]+"
    result = 0
}
$0 !~ /^[[:digit:]]+:( [[:digit:]]+){2,}$/ {
    report_error("ERROR: invalid data in " $0)
}
/ 0/ {
    report_error("ERROR: unsupported zero coefficient in " $0)
}
{
    split("", VALUES)
    ++VALUES[2][$2]
    for (i = 3; i < NF; ++i) {
        split("", VALUES[i])
        for (v in VALUES[i - 1]) {
            if (v + $i <= $1) {
                ++VALUES[i][v + $i]
            }
            if (v * $i <= $1) {
                ++VALUES[i][v * $i]
            }
            if (0 + (v $i) <= $1) {
                ++VALUES[i][0 + (v $i)]
            }
        }
    }
    for (v in VALUES[NF - 1]) {
        if (DEBUG) {
            print "testing", v + $NF, "against", $1
        }
        if (v + $NF == $1) {
            result += $1
            next
        }
        if (DEBUG) {
            print "testing", v * $NF, "against", $1
        }
        if (v * $NF == $1) {
            result += $1
            next
        }
        if (DEBUG) {
            print "testing", v $NF, "against", $1
        }
        if (0 + (v $NF) == $1) {
            result += $1
            next
        }
    }
}
END {
    report_error()
    print result
}
