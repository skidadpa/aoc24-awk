#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
function extend_region(crop, x, y) {
    if (((x SUBSEP y) in REGION) || (MAP[x,y] != crop)) {
        return
    }
    REGION[x,y] = num_regions
    extend_region(crop, x-1, y)
    extend_region(crop, x, y-1)
    extend_region(crop, x+1, y)
    extend_region(crop, x, y+1)
}
function mark_region_from(x, y) {
    if ((x SUBSEP y) in REGION) {
        return
    }
    ++num_regions
    extend_region(MAP[x,y], x, y)
}
BEGIN {
    DEBUG = 0
    FS = ""
    num_regions = 0
}
$0 !~ /^[[:upper:]]+$/ {
    report_error("DATA ERROR: " $0)
}
{
    for (i = 1; i <= NF; ++i) {
        MAP[i,NR] = $i
    }
    width = NF
    height = NR
}
END {
    report_error()
    for (y = 1; y <= height; ++y) {
        for (x = 1; x <= width; ++x) {
            mark_region_from(x, y)
            ++AREA[REGION[x,y]]
            if (MAP[x-1,y] != MAP[x,y]) {
                ++PERIMETER[REGION[x,y]]
            }
            if (MAP[x,y-1] != MAP[x,y]) {
                ++PERIMETER[REGION[x,y]]
            }
            if (MAP[x+1,y] != MAP[x,y]) {
                ++PERIMETER[REGION[x,y]]
            }
            if (MAP[x,y+1] != MAP[x,y]) {
                ++PERIMETER[REGION[x,y]]
            }
        }
    }
    for (region in AREA) {
        price += AREA[region] * PERIMETER[region]
    }
    print price
}
