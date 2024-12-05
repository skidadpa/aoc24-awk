#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function page_order_compare(i1, v1, i2, v2)
{
    if ((v1 in AFTER) && (v2 in AFTER[v1])) {
        return -1
    } else if ((v2 in AFTER) && (v1 in AFTER[v2])) {
        return 1
    } else {
        return 0
    }
}
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
    split("", pages)
    pages[1] = $1
    sorted = 1
    for (p = 2; p <= NF; ++p) {
        if ($p in AFTER) {
            for (i in pages) {
                if (sorted && (pages[i] in AFTER[$p])) {
                    sorted = 0
                    break
                }
            }
        }
        pages[p] = $p
    }
    if (DEBUG) {
        printf("%s:", sorted ? "SORTED" : "UNSORTED")
        for (i = 1; i <= length(pages); ++i) {
            printf(" %d", pages[i])
        }
        printf("\n")
    }
    if (sorted) {
        next
    }
    asort(pages, sorted_pages, "page_order_compare")
    if (DEBUG) {
        printf(" AFTER SORTING:")
        for (i = 1; i <= length(sorted_pages); ++i) {
            printf(" %d", sorted_pages[i])
        }
        printf("\n")
    }
    mid = (NF + 1)/ 2
    middles_sum += sorted_pages[mid]
    next
}
{
    report_error("unrecognized input: " $0)
}
END {
    report_error()
    print middles_sum
}
