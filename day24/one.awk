#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ": "
    split("", WAITING_A)
    split("", WAITING_B)
}
(FS == ": ") {
    if (NF == 0) {
        FS = " "
    } else if ($0 ~ /^[[:lower:]][[:digit:]]{2}: [01]$/) {
        if (DEBUG > 4) {
            print "Gate", $1, "starts with value", $2
        }
        VALUES[$1] = $2
        if (substr($1,1,1) == "x") {
            INPUTX[substr($1,2)] = $1
        } else if (substr($1,1,1) == "y") {
            INPUTY[substr($1,2)] = $1
        }
    } else {
        report_error("DATA ERROR: not an initialization sequence: " $0)
    }
    next
}
$0 !~ /^[[:lower:][:digit:]]{3} ((AND)|(OR)|(XOR)) [[:lower:][:digit:]]{3} -> [[:lower:][:digit:]]{3}$/ {
    report_error("DATA ERROR: not a gate sequence: " $0)
}
{
    GATE[$5] = $2
    A[$5] = $1
    B[$5] = $3
    ready = 1
    if (!($1 in VALUES)) {
        ready = 0
        WAITING_A[$1][$5] = 1
    }
    if (!($3 in VALUES)) {
        ready = 0
        WAITING_B[$3][$5] = 1
    }
    if (ready) {
        READY[0][$5] = 1
    }
    if (substr($5,1,1) == "z") {
        OUTPUT[substr($5,2)] = $5
    }
}
END {
    report_error()
    for (step = 0; step < NR; ++step) {
        if (DEBUG > 2) {
            print "AT STEP:", step
            printf("%d gates ready to trigger", length(READY[step]))
            if (DEBUG > 3) {
                printf(":")
                for (gate in READY[step]) {
                    printf(" %s", gate)
                }
            }
            printf("\n")
            printf("%d left inputs needed", length(WAITING_A))
            if (DEBUG > 3) {
                printf(":")
                for (gate in WAITING_A) {
                    printf(" %s", gate)
                }
            }
            printf("\n")
            printf("%d right inputs needed", length(WAITING_B))
            if (DEBUG > 3) {
                printf(":")
                for (gate in WAITING_B) {
                    printf(" %s", gate)
                }
            }
            printf("\n")
        }
        for (gate in READY[step]) {
            switch (GATE[gate]) {
            case "AND":
                VALUES[gate] = and(VALUES[A[gate]],VALUES[B[gate]])
                break
            case "OR":
                VALUES[gate] = or(VALUES[A[gate]],VALUES[B[gate]])
                break
            case "XOR":
                VALUES[gate] = xor(VALUES[A[gate]],VALUES[B[gate]])
                break
            default:
                report_error("PROCESSING ERROR: unknown gate type " GATE[gate])
            }
            if (DEBUG > 4) {
                print "computed", gate
            }
            for (activated in WAITING_A[gate]) {
                if (B[activated] in VALUES) {
                    READY[step+1][activated] = 1
                }
            }
            for (activated in WAITING_B[gate]) {
                if (A[activated] in VALUES) {
                    READY[step+1][activated] = 1
                }
            }
            delete WAITING_A[gate]
            delete WAITING_B[gate]
        }
        if (length(READY[step+1]) < 1) {
            break
        }
    }
    if ((length(WAITING_A) > 0) || (length(WAITING_B) > 0)) {
        report_error("PROCESSING ERROR: some gates could not be processed")
    }
    z = 0
    for (i in OUTPUT) {
        if (DEBUG > 1) {
            print OUTPUT[i], VALUES[OUTPUT[i]]
        }
        z += lshift(VALUES[OUTPUT[i]], i)
    }
    if (DEBUG) {
        x = 0
        for (i in INPUTX) {
            if (DEBUG > 1) {
                print INPUTX[i], VALUES[INPUTX[i]]
            }
            x += lshift(VALUES[INPUTX[i]], i)
        }
        y = 0
        for (i in INPUTY) {
            if (DEBUG > 1) {
                print INPUTY[i], VALUES[INPUTY[i]]
            }
            y += lshift(VALUES[INPUTY[i]], i)
        }
        printf("%d (%x) + %d (%x) = %d (%x)\n", x, x, y, y, z, z)
    }
    print z
}
