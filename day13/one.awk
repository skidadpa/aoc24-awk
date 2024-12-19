#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FPAT = "[[:digit:]]+"
    SEPARATOR = 0
    A = 1
    B = 2
    PRIZE = 3
    X = 1
    Y = 2
    PATTERN[A] = "^Button A: X\\+[[:digit:]]+, Y\\+[[:digit:]]+$"
    PATTERN[B] = "^Button B: X\\+[[:digit:]]+, Y\\+[[:digit:]]+$"
    PATTERN[PRIZE] = "^Prize: X=[[:digit:]]+, Y=[[:digit:]]+$"
    PATTERN[SEPARATOR] = "^$"
    scan = A
    tokens = 0
}
$0 !~ PATTERN[scan] {
    report_error("DATA ERROR: " $0 ", expected " PATTERN[scan])
}
{
    VALUE[scan][X] = $X
    VALUE[scan][Y] = $Y
    if (scan == PRIZE) {
        if (DEBUG > 1) {
            printf("%d/%d A + %d/%d B == %d/%d\n", VALUE[A][Y], VALUE[A][X], VALUE[B][Y], VALUE[B][X], VALUE[PRIZE][Y], VALUE[PRIZE][X])
        }
        a = (VALUE[PRIZE][Y] / VALUE[B][Y] - VALUE[PRIZE][X] / VALUE[B][X]) / (VALUE[A][Y] / VALUE[B][Y] - VALUE[A][X] / VALUE[B][X])
        b = (VALUE[PRIZE][Y] / VALUE[A][Y] - VALUE[PRIZE][X] / VALUE[A][X]) / (VALUE[B][Y] / VALUE[A][Y] - VALUE[B][X] / VALUE[A][X])
        round_a = int(a * 10000 + 0.00001) / 10000
        round_b = int(b * 10000 + 0.00001) / 10000
        if ((int(round_a) == round_a) && int(round_b) == round_b) {
            tokens += 3 * round_a + round_b
            if (DEBUG) {
                print "A =", round_a, "B =", round_b
            }
        }
    }
    scan = (scan + 1) % 4
}
END {
    report_error()
    if (scan != SEPARATOR) {
        report_error("DATA ERROR: final scanned line was not a PRIZE")
    }
    print tokens
}
