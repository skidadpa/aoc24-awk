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
function path_found(   PATH_FORWARD, VISITED_FORWARD, PATH_BACKWARD, VISITED_BACKWARD,  i, p, c, left, right, up, down) {
    split("", PATH_FORWARD)
    split("", VISITED_FORWARD)
    split("", PATH_BACKWARD)
    split("", VISITED_BACKWARD)
    PATH_FORWARD[0][0,0] = 0
    VISITED_FORWARD[0,0] = 0
    PATH_BACKWARD[0][GRID_MAX,GRID_MAX] = 1
    VISITED_BACKWARD[GRID_MAX,GRID_MAX] = 1
    for (i = 0; i < MAX_PATH; ++i) {
        for (p in PATH_FORWARD[i]) {
            if (p in VISITED_BACKWARD) {
                return 1
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
                return 1
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
        if (length(PATH_FORWARD[i]) + length(PATH_BACKWARD[i]) == 0) {
            return 0
        }
    }
    return 0
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
    INITIAL_BYTE_COUNT = (NR < 30) ? 12 : 1024
    for (i = 0; i <= GRID_MAX; ++i) {
        ++CORRUPTED[-1,i]
        ++CORRUPTED[GRID_MAX+1,i]
        ++CORRUPTED[i,-1]
        ++CORRUPTED[i,GRID_MAX+1]
    }
    GRID_MAX = (NR < 30) ? 6 : 70
    MAX_PATH = GRID_MAX * GRID_MAX
    for (i = 1; i <= INITIAL_BYTE_COUNT; ++i) {
        ++CORRUPTED[BYTES[i]]
    }
    if (DEBUG) {
        print_map()
    }
    if (!path_found()) {
        report_error("PROCESSING ERROR: path already corrupted after " INITIAL_BYTE_COUNT " nanoseconds")
    }
    for (i = INITIAL_BYTE_COUNT+1; i <= NR; ++i) {
        ++CORRUPTED[BYTES[i]]
        if (!path_found()) {
            split(BYTES[i], c, SUBSEP)
            print c[1] "," c[2]
            exit
        }
    }
    print "PATH NOT BLOCKED BY ALL " NR " BYTES"
}
