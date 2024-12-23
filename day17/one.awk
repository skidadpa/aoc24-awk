#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FPAT="[[:digit:]]+"
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
    for (i = 1; i < NF; ++i) {
        MEM[i-1] = $i
    }
    MEM_SIZE = NF
}
END {
    report_error()
    if (DEBUG) {
        printf("Initially: A=%d, B=%d, C=%d, IP=%d\n", REGISTER[A], REGISTER[B], REGISTER[C], IP)
    }
    if (DEBUG > 3) {
        printf("(IP=%d)",IP)
    }
    while (IP < MEM_SIZE) {
        if (DEBUG) {
            printf(".")
        }
        compute()
        if (DEBUG > 3) {
            printf("(IP=%d)",IP)
        }
    }
    printf("\n")
}
