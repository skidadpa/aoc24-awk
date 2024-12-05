#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = "|"
}
/^[[:digit:]]+\|[[:digit:]]+$/ {
    if (FS != "|") {
        report_error("rule " $0 " in wrong location")
    }
    AFTER[$1][$2] = 1
    next
}
/^$/ {
    if (FS != "|") {
        report_error("rule divider in wrong location")
    }
    FS = ","
    next
}
/^[[:digit:]]+(,[[:digit:]]+)+$/ {
    if (FS != ",") {
        report_error("manual pages " $0 " in wrong location")
    }
    split("", earlier_pages)
    earlier_pages[1] = $1
    for (p = 2; p <= NF; ++p) {
        if ($p in AFTER) {
            for (i in earlier_pages) {
                if (earlier_pages[i] in AFTER[$p]) {
                    next
                }
            }
        }
        earlier_pages[p] = $p
    }
    mid = (NF + 1)/ 2
    middles_sum += $mid
    next
}
{
    report_error("unrecognized input: " $0)
}
END {
    report_error()
    print middles_sum
}
