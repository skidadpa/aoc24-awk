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
    last_digit = number % 10
    if (DEBUG > 1) {
        printf(" %d", number)
    }
    split("", PRICE)
    split("", DELTA)
    for (i = 1; i <= NUM_STEPS; ++i) {
        number = and(xor(number, number * 64), 16777215)
        number = and(xor(number, rshift(number, 5)), 16777215)
        number = and(xor(number, number * 2048), 16777215)
        price = number % 10
        PRICE[i] = price
        DELTA[i] = price - last_digit
        last_digit = price
    }
    for (i = 4; i <= NUM_STEPS; ++i) {
        pattern = DELTA[i-3] "," DELTA[i-2] "," DELTA[i-1] "," DELTA[i]
        if (!(pattern in PATTERNS[NR])) {
            PATTERNS[NR][pattern] = PRICE[i]
            VALUE[pattern] += PRICE[i]
        }
    }
}
END {
    report_error()
    if (DEBUG > 1) {
        printf("\n")
    }
    best_price = 0
    for (pattern in VALUE) {
        if (VALUE[pattern] > best_price) {
            best_price = VALUE[pattern]
            if (DEBUG) {
                print pattern, "has value", best_price
            }
        }
    }
    print best_price
}
