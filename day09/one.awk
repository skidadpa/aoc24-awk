#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = ""
    checksum = 0
    pos = 0
    block = 0
    used = 0
    free = 0
}
{
    for (i = 1; i <= NF; ++i) {
        if (i % 2) {
            for (j = 1; j <= $i; ++j) {
                USED[used++] = pos
                DISK[pos++] = block
            }
            ++block
        } else {
            for (j = 1; j <= $i; ++j) {
                FREE[free++] = pos
                DISK[pos++] = "."
            }
        }
    }
    u = used - 1
    for (f = 0; f < free && FREE[f] < used; ++f) {
        DISK[FREE[f]] = DISK[USED[u]]
        DISK[USED[u--]] = "."
    }
    for (i = 0; i < used; ++i) {
        checksum += i * DISK[i]
    }
}
END {
    report_error()
    print checksum
}
