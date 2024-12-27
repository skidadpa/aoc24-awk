#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    NUM_STEPS = 2000
}
$0 !~ /^[[:digit:]]+$/ {
    report_error("DATA ERROR: " $0)
}
{
    number = 0 + $0
    for (i = 1; i <= NUM_STEPS; ++i) {
        number = and(xor(number, number * 64), 16777215)
        number = and(xor(number, rshift(number, 5)), 16777215)
        number = and(xor(number, number * 2048), 16777215)
    }
    if (DEBUG) {
        printf("%d: %d\n", $0, number)
    }
    sum += number
}
END {
    report_error()
    print sum
}
