#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function print_map(   x, y) {
    for (y = 0; y <= GRID_MAX; ++y) {
        for (x = 0; x <= GRID_MAX; ++x) {
            if ((x SUBSEP y) in CORRUPTED) {
                printf("#")
            } else {
                printf(".")
            }
        }
        printf("\n")
    }
}
BEGIN {
    DEBUG = 0
    FS=","
}
$0 !~ /^[[:digit:]]+,[[:digit:]]+$/ {
    report_error("DATA ERROR: unrecognized line " $0)
}
{
    BYTES[NR] = ($1 SUBSEP $2)
}
END {
    report_error()
    GRID_MAX = (NR < 30) ? 6 : 70
    BYTE_COUNT = (NR < 30) ? 12 : 1024
    for (i = 1; i <= BYTE_COUNT; ++i) {
        ++CORRUPTED[BYTES[i]]
    }
    for (i = 0; i <= GRID_MAX; ++i) {
        ++CORRUPTED[-1,i]
        ++CORRUPTED[GRID_MAX+1,i]
        ++CORRUPTED[i,-1]
        ++CORRUPTED[i,GRID_MAX+1]
    }
    GRID_MAX = (NR < 30) ? 6 : 70
    if (DEBUG) {
        print_map()
    }
    PATH_FORWARD[0][0,0] = 0
    VISITED_FORWARD[0,0] = 0
    PATH_BACKWARD[0][GRID_MAX,GRID_MAX] = 1
    VISITED_BACKWARD[GRID_MAX,GRID_MAX] = 1
    MAX_PATH = 10000
    for (i = 0; i < MAX_PATH; ++i) {
        for (p in PATH_FORWARD[i]) {
            if (p in VISITED_BACKWARD) {
                print VISITED_FORWARD[p] + VISITED_BACKWARD[p]
                exit
            }
            split(p, c, SUBSEP)
            left = ((c[1]-1) SUBSEP c[2])
            right = ((c[1]+1) SUBSEP c[2])
            up = (c[1] SUBSEP (c[2]-1))
            down = (c[1] SUBSEP (c[2]+1))
            if (!(left in CORRUPTED) && !(left in VISITED_FORWARD)) {
                PATH_FORWARD[i+1][left] = i+1
                VISITED_FORWARD[left] = i+1
            }
            if (!(right in CORRUPTED) && !(right in VISITED_FORWARD)) {
                PATH_FORWARD[i+1][right] = i+1
                VISITED_FORWARD[right] = i+1
            }
            if (!(up in CORRUPTED) && !(up in VISITED_FORWARD)) {
                PATH_FORWARD[i+1][up] = i+1
                VISITED_FORWARD[up] = i+1
            }
            if (!(down in CORRUPTED) && !(down in VISITED_FORWARD)) {
                PATH_FORWARD[i+1][down] = i+1
                VISITED_FORWARD[down] = i+1
            }
        }
        for (p in PATH_BACKWARD[i]) {
            if (p in VISITED_FORWARD) {
                print VISITED_FORWARD[p] + VISITED_BACKWARD[p]
                exit
            }
            split(p, c, SUBSEP)
            left = ((c[1]-1) SUBSEP c[2])
            right = ((c[1]+1) SUBSEP c[2])
            up = (c[1] SUBSEP (c[2]-1))
            down = (c[1] SUBSEP (c[2]+1))
            if (!(left in CORRUPTED) && !(left in VISITED_BACKWARD)) {
                PATH_BACKWARD[i+1][left] = i+1
                VISITED_BACKWARD[left] = i+1
            }
            if (!(right in CORRUPTED) && !(right in VISITED_BACKWARD)) {
                PATH_BACKWARD[i+1][right] = i+1
                VISITED_BACKWARD[right] = i+1
            }
            if (!(up in CORRUPTED) && !(up in VISITED_BACKWARD)) {
                PATH_BACKWARD[i+1][up] = i+1
                VISITED_BACKWARD[up] = i+1
            }
            if (!(down in CORRUPTED) && !(down in VISITED_BACKWARD)) {
                PATH_BACKWARD[i+1][down] = i+1
                VISITED_BACKWARD[down] = i+1
            }
        }
    }
    print "NO PATH FOUND LESS THAN", 2*MAX_PATH, "STEPS"
}
