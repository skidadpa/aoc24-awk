#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FPAT="[[:digit:]]+(,[[:digit:]]+)*"
    PATTERNS[1] = "^Register A: [[:digit:]]+$"
    PATTERNS[2] = "^Register B: [[:digit:]]+$"
    PATTERNS[3] = "^Register C: [[:digit:]]+$"
    PATTERNS[4] = "^$"
    PATTERNS[5] = "^Program: [[:digit:]]+(,[[:digit:]]+)*$"
    A = 1
    B = 2
    C = 3
    PROG = 5
    IP = 0
    OPCODE[0] = "adv"
    OPCODE[1] = "bxl"
    OPCODE[2] = "bst"
    OPCODE[3] = "jnz"
    OPCODE[4] = "bxc"
    OPCODE[5] = "out"
    OPCODE[6] = "bdv"
    OPCODE[7] = "cdv"
    COMBO[0] = "0"
    COMBO[1] = "1"
    COMBO[2] = "2"
    COMBO[3] = "3"
    COMBO[4] = "A"
    COMBO[5] = "B"
    COMBO[6] = "C"
    COMBO[7] = "?"
    SEPARATOR = ""
}
function combo(operand) {
    switch (operand) {
    case 0:
    case 1:
    case 2:
    case 3:
        if (DEBUG > 2) {
            printf("(combo:I=%d)", operand)
        }
        return operand
    case 4:
        if (DEBUG > 2) {
            printf("(combo:A=%d)", REGISTER[A])
        }
        return REGISTER[A]
    case 5:
        if (DEBUG > 2) {
            printf("(combo:B=%d)", REGISTER[B])
        }
        return REGISTER[B]
    case 6:
        if (DEBUG > 2) {
            printf("(combo:C=%d)", REGISTER[C])
        }
        return REGISTER[C]
    case 7:
    default:
        report_error("PROGRAM ERROR: illegal combo operand " operand)
    }
}
function compute(   opcode, operand) {
    opcode = MEM[IP++]
    operand = MEM[IP++]
    if (DEBUG > 1) {
        printf("%d: (%s %d)", IP - 2, OPCODE[opcode], operand)
    }
    switch (opcode) {
    case 0: # adv
        if (DEBUG > 2) {
            printf("(A=%d)", REGISTER[A])
        }
        REGISTER[A] = int(REGISTER[A] / (lshift(1, combo(operand))))
        if (DEBUG > 2) {
            printf("->(A=%d)", REGISTER[A])
        }
        break
    case 1: # bxl
        if (DEBUG > 2) {
            printf("(B=%d)", REGISTER[B])
        }
        REGISTER[B] = xor(REGISTER[B], operand)
        if (DEBUG > 2) {
            printf("->(B=%d)", REGISTER[B])
        }
        break
    case 2: # bst
        REGISTER[B] = combo(operand) % 8
        break
    case 3: # jnz
        if (DEBUG > 2) {
            printf("(A=%d)", REGISTER[A])
        }
        if (REGISTER[A] != 0) {
            IP = operand
        }
        break
    case 4: # bxc
        if (DEBUG > 2) {
            printf("(B=%d, C=%d)", REGISTER[B], REGISTER[C])
        }
        REGISTER[B] = xor(REGISTER[B], REGISTER[C])
        if (DEBUG > 2) {
            printf("->(B=%d)", REGISTER[B])
        }
        break
    case 5: # out
        if (DEBUG) {
            printf(" [")
        }
        printf("%s%d", SEPARATOR, (combo(operand) % 8))
        if (DEBUG) {
            printf("]")
        }
        SEPARATOR = ","
        break
    case 6: # bdv
        if (DEBUG > 2) {
            printf("(A=%d)", REGISTER[A])
        }
        REGISTER[B] = int(REGISTER[A] / (2 ^ combo(operand)))
        if (DEBUG > 2) {
            printf("->(B=%d)", REGISTER[B])
        }
        break
    case 7: # cdv
        if (DEBUG > 2) {
            printf("(A=%d)", REGISTER[A])
        }
        REGISTER[C] = int(REGISTER[A] / (2 ^ combo(operand)))
        if (DEBUG > 2) {
            printf("->(C=%d)", REGISTER[C])
        }
        break
    default:
        report_error("PROGRAM ERROR: illegal opcode " opcode)
    }
    if (DEBUG > 1) {
        printf("\n")
    }
}
function explain(opcode, operand) {
    switch (opcode) {
    case 0: # adv
        return "A = A / (1 << " COMBO[operand] ")"
    case 1: # bxl
        return "B = B ^ " operand
    case 2: # bst
        return "B = " COMBO[operand] " % 8"
    case 3: # jnz
        return "if (A != 0) goto " operand
    case 4: # bxc
        return "B = B ^ C"
    case 5: # out
        return "output " COMBO[operand] " % 8"
    case 6: # bdv
        return "B = A / (1 << " COMBO[operand] ")"
    case 7: # cdv
        return "C = A / (1 << " COMBO[operand] ")"
    default:
        return "ILLEGAL OPCODE"
    }
}
($0 !~ PATTERNS[NR]) || (NR > 5) {
    report_error("DATA ERROR: illegal program line " NR ": " $0)
}
(NR <= C) {
    REGISTER[NR] = $1
}
(NR == PROG) {
    if (NF % 1) {
        report_error("DATA ERROR: Program size must be even: " $0)
    }
    PROGRAM = $1
    split(PROGRAM, DATA, ",")
    for (i in DATA) {
        MEM[i-1] = DATA[i]
    }
    delete DATA
    MEM_SIZE = length(MEM)
}
END {
    report_error()
    if (DEBUG) {
        printf("Initially: A=%d, B=%d, C=%d, IP=%d\n", REGISTER[A], REGISTER[B], REGISTER[C], IP)
        printf("Program: %s\n", PROGRAM)
        for (i = 0; i < MEM_SIZE; i += 2) {
            printf(" %d: %s", i, OPCODE[MEM[i]])
            switch (MEM[i]) {
            case 0: # adv
            case 2: # bst
            case 5: # out
            case 6: # bdv
            case 7: # cdv
                printf(" %s", COMBO[MEM[i+1]])
                break
            case 1: # bxl
            case 3: # jnz
                printf(" %s", MEM[i+1])
                break
            case 4: # bxc
                break
            default:
                printf("???")
                break
            }
            printf("\t%s\n", explain(MEM[i], MEM[i+1]))
        }
            
    }
    SUPPORTED_PROGRAM = "2,4,1,1,7,5,0,3,1,4,4,0,5,5,3,0"
    if (PROGRAM == "0,1,5,4,3,0") {
        print "NO SOLUTION"
        exit
    } else if (PROGRAM != SUPPORTED_PROGRAM) {
        report_error("PROGRAM ERROR: only program " SUPPORTED_PROGRAM " supported")
    }
    if (DEBUG > 3) {
        printf("(IP=%d)",IP)
    }
    CANDIDATES[MEM_SIZE][0] = 1
    for (m = MEM_SIZE - 1; m >= 0; --m) {
        target = xor(MEM[m], 5)
        if (DEBUG) {
            printf("computing a[%d], MEM[%d]^5 == %d\n", m, m, target)
        }
        for (c in CANDIDATES[m+1]) {
            for (a = 0; a <= 7; ++a) {
                candidate = lshift(c, 3) + a
                if (DEBUG) {
                    printf("a = %d, candidate = %d\n", a, candidate)
                    printf("(a ^ (candidate / (1 << (a^1)))) % 8 == %d\n", xor(a, int(candidate / lshift(1, xor(a, 1)))) % 8)
                }
                if ((xor(a, int(candidate / lshift(1, xor(a, 1)))) % 8) == target) {
                    CANDIDATES[m][candidate] = 1
                    if (DEBUG) {
                        printf(" Candidate a[%d] = %d, a = %d\n", m, a, candidate)
                    }
                }
            }
        }
    }
    minval = 0
    for (c in CANDIDATES[0]) {
        if (!minval || (c < minval)) {
            minval = c
        }
    }
    if (!minval) {
        report_error("PROCESSING ERROR: no solution found")
    }
    print minval
}
