#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function multiline(node, indent,   s, i) {
    s = node ":"
    for (i = 1; i <= indent; ++i) {
        s = s " "
    }
    s = s "(" GATES[node]
    if (A[node] in GATES) {
        s = s "\n" multiline(A[node], indent + 1)
    } else {
        s = s " " A[node]
    }
    s = s ","
    if (B[node] in GATES) {
        s = s "\n" multiline(B[node], indent + 1)
    } else {
        s = s B[node]
    }
    s = s ")"
    return s
}
function prefix(node,   s) {
    s = "(" GATES[node] " "
    if (A[node] in GATES) {
        s = s prefix(A[node])
    } else {
        s = s A[node]
    }
    s = s ","
    if (B[node] in GATES) {
        s = s prefix(B[node])
    } else {
        s = s B[node]
    }
    s = s ")"
    return s
}
function names(node,   s) {
    s = "(" node " "
    if (A[node] in GATES) {
        s = s names(A[node])
    } else {
        s = s A[node]
    }
    s = s ","
    if (B[node] in GATES) {
        s = s names(B[node])
    } else {
        s = s B[node]
    }
    s = s ")"
    return s
}
BEGIN {
    DEBUG = 0
    FS = ": "
    split("", WAITING_A)
    split("", WAITING_B)
    SYMBOL["AND"] = "&"
    SYMBOL["OR"] = "|"
    SYMBOL["XOR"] = "^"
}
#
# RIPPLE CARRY ADDER STAGES (stage 0 differs from all others):
#
# z00 = x00 XOR y00
# c01 = x00 AND y00
#        
# x00 __._| |\
#       | | | \__________ z01
# y00 _.__| | /
#      || | |/
#      ||         ___
#      |\________|   \
#      |         |    |__ c01
#      \_________|    |
#                |___/
#
# z02 = (x01 XOR y01) XOR c01
# c02 = (x01 AND y01) OR ((x01 XOR y01) AND c01)
#
# r01 = x01 XOR y01
# s01 = x01 AND y01
# t01 = r01 AND c01
# z02 = r01 XOR c01
# c02 = s01 OR t01
#        
# x01 __._| |\
#       | | | \_.____| |\
# y01 _.__| | / |r01 | | \__________ z01
#      || | |/  |   _| | /
#      ||       |  / | |/
#      ||       |  |
#      ||       |  |  ___
#      |\____________|   \
#      |        |  | |    |_
#      \_____________|    | \s01
#               |  | |___/   \_|\
#               |  |           | \__ c02
#               |  |  ___     _| /
#                \___|   \   / |/
#                  | |    |_/t01
# c01 _____________|_|    |
#                    |___/
# ...
#
# c45 ______________________________ z45
#
(FS == ": ") {
    if (NF == 0) {
        FS = " "
    } else if ($0 ~ /^[[:lower:]][[:digit:]]{2}: [01]$/) {
        if (DEBUG > 4) {
            print "Gate", $1, "starts with value", $2
        }
        VALUES[$1] = $2
        if (substr($1,1,1) == "x") {
            INPUTX[0 + substr($1,2)] = $1
            ++INPUTS[$1]
        } else if (substr($1,1,1) == "y") {
            INPUTY[0 + substr($1,2)] = $1
            ++INPUTS[$1]
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
    GATES[$5] = $2
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
        OUTPUT[0 + substr($5,2)] = $5
        OUTPUTS[$5] = 1
    }
    if (match($0, /^[xy]([[:digit:]]{2}) ([[:upper:]]{3}) [xy]([[:digit:]]{2})/, INS)) {
        if (INS[1] != INS[3]) {
            report_error("PROGRAM ERROR: misconnected inputs not supported: " $0)
        }
        stage = 0 + INS[1]
        if (stage == 0) {
            if (INS[2] == "AND") {
                if ((stage + 1) in C) {
                    report_error("PROGRAM ERROR: second stage 0 carry out: " $0)
                }
                C[stage + 1] = $5
                CARRIES[$5] = stage
            } else if ($5 != OUTPUT[stage]) {
                report_error("PROGRAM ERROR: complex stage 0 not supported: " $0)
            }
        } else {
            switch (INS[2]) {
            case "XOR":
                if (stage in R) {
                    report_error("PROGRAM ERROR: second stage " stage " R gate: " $0)
                }
                R[stage] = $5
                XY_XORS[$5] = stage
                break
            case "AND":
                if (stage in S) {
                    report_error("PROGRAM ERROR: second stage " stage " S gate: " $0)
                }
                S[stage] = $5
                XY_ANDS[$5] = stage
                break
            default:
                report_error("PROGRAM ERROR: complex stage " stage " not supported: " $0)
            }
        }
    }
    GATE_TYPES[$2][$5] = 1
}
END {
    report_error()
    first_output = OUTPUT[0]
    final_output = OUTPUT[length(OUTPUT)-1]
    for (gate in OUTPUTS) {
        if ((GATES[gate] != "XOR") && (gate != final_output)) {
            ++CROSSED[gate]
        }
    }
    for (gate in GATES) {
        switch (GATES[gate]) {
        case "XOR":
            if ((gate in OUTPUTS) && (gate != first_output)) {
                if ((A[gate] in INPUTS) || (B[gate] in INPUTS)) {
                    ++CROSSED[gate]
                }
                if (A[gate] in XY_ANDS) {
                    ++CROSSED[A[gate]]
                }
                if (B[gate] in XY_ANDS) {
                    ++CROSSED[B[gate]]
                }
            } else if (!(A[gate] in INPUTS)) {
                ++CROSSED[gate]
            }
            break
        case "OR":
            if (gate != final_output) {
                if (GATES[A[gate]] != "AND") {
                    ++CROSSED[A[gate]]
                }
                if (GATES[B[gate]] != "AND") {
                    ++CROSSED[B[gate]]
                }
            }
            break
        }
    }
    for (step = 0; step < NR; ++step) {
        if (DEBUG > 5) {
            print "AT STEP:", step
            printf("%d gates ready to trigger", length(READY[step]))
            if (DEBUG > 6) {
                printf(":")
                for (gate in READY[step]) {
                    printf(" %s", gate)
                }
            }
            printf("\n")
            printf("%d left inputs needed", length(WAITING_A))
            if (DEBUG > 6) {
                printf(":")
                for (gate in WAITING_A) {
                    printf(" %s", gate)
                }
            }
            printf("\n")
            printf("%d right inputs needed", length(WAITING_B))
            if (DEBUG > 6) {
                printf(":")
                for (gate in WAITING_B) {
                    printf(" %s", gate)
                }
            }
            printf("\n")
        }
        for (gate in READY[step]) {
            switch (GATES[gate]) {
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
                report_error("PROCESSING ERROR: unknown gate type " GATES[gate])
            }
            if (DEBUG > 7) {
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
    if (DEBUG > 3) {
        for (i in OUTPUT) {
            printf("\n")
            print multiline(OUTPUT[i], 1)
        }
    } else if (DEBUG > 1) {
        if (DEBUG > 2) {
            for (i in OUTPUT) {
                print OUTPUT[i], "=", infix(OUTPUT[i])
            }
        }
        for (i in OUTPUT) {
            print OUTPUT[i], "=", prefix(OUTPUT[i])
        }
        for (i in OUTPUT) {
            print OUTPUT[i], "=", names(OUTPUT[i])
        }
    }
    if ((length(WAITING_A) > 0) || (length(WAITING_B) > 0)) {
        report_error("PROCESSING ERROR: some gates could not be processed")
    }
    z = 0
    for (i in OUTPUT) {
        if (DEBUG > 4) {
            print OUTPUT[i], VALUES[OUTPUT[i]]
        }
        z += lshift(VALUES[OUTPUT[i]], i)
    }
    if (DEBUG) {
        x = 0
        for (i in INPUTX) {
            if (DEBUG > 4) {
                print INPUTX[i], VALUES[INPUTX[i]]
            }
            x += lshift(VALUES[INPUTX[i]], i)
        }
        y = 0
        for (i in INPUTY) {
            if (DEBUG > 4) {
                print INPUTY[i], VALUES[INPUTY[i]]
            }
            y += lshift(VALUES[INPUTY[i]], i)
        }
        printf("  0x%012x    %d\n", x, x)
        printf("+ 0x%012x  + %d\n", y, y)
        printf("  ==============    ==============\n")
        printf("  0x%012x    %d\n", z, z)
        if (x + y == z) {
            printf("        OK                OK\n")
        } else {
            printf("    should be:        should be:\n")
            printf("  0x%012x    %d\n", x+y, x+y)
        }
    }
    PROCINFO["sorted_in"] = "@ind_str_asc"
    separator = ""
    for (c in CROSSED) {
        printf("%s%s", separator, c)
        separator = ","
    }
    printf("\n")
}
