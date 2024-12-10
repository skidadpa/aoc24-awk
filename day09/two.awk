#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    PROCINFO["sorted_in"] = "@ind_num_asc"
    FS = ""
    checksum = 0
    pos = 0
    num_blocks = 0
}
{
    for (i = 1; i <= NF; ++i) {
        if (i % 2) {
            BLK_POS[num_blocks] = pos
            BLK_SIZE[num_blocks++] = $i
        } else {
            FREE[pos] = $i
        }
        pos += $i
    }

    if (DEBUG) {
        print "Initially:"
        for (b = 0; b < num_blocks; ++b) {
            print b ":", BLK_POS[b], "-", BLK_POS[b] + BLK_SIZE[b] - 1
        }
        print "free:"
        for (f in FREE) {
            print f, "-", f + FREE[f] - 1
        }
    }

    if (DEBUG > 1) {
        print "Compacting..."
    }
    for (b = num_blocks - 1; b >= 0; --b) {
        if (DEBUG > 1) {
            print b ":", BLK_POS[b], "-", BLK_POS[b] + BLK_SIZE[b] - 1
        }
        end_target_zone = BLK_POS[b]
        size = BLK_SIZE[b]
        for (f in FREE) {
            if (DEBUG > 2) {
                print "testing", f, "-", f + FREE[f] - 1
            }
            if (0 + f >= end_target_zone) {
                if (DEBUG > 2) {
                    print "left target zone:", f, ">=", end_target_zone
                }
                break
            }
            if (FREE[f] >= size) {
                if (DEBUG > 1) {
                    print "moving to", f, "-", f + BLK_SIZE[b] - 1
                }
                BLK_POS[b] = f
                if (FREE[f] > size) {
                    FREE[f + size] = FREE[f] - size
                }
                delete FREE[f]
                break
            }
        }
    }

    if (DEBUG) {
        print "After compaction:"
        for (b = 0; b < num_blocks; ++b) {
            print b ":", BLK_POS[b], "-", BLK_POS[b] + BLK_SIZE[b] - 1
        }
        print "free:"
        for (f in FREE) {
            print f, "-", f + FREE[f] - 1
        }
    }

    for (b = 1; b < num_blocks; ++b) {
        for (i = 0; i < BLK_SIZE[b]; ++i) {
            checksum += b * (BLK_POS[b] + i)
        }
    }
}
END {
    report_error()
    print checksum
}
