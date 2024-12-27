#!/usr/bin/env gawk -f
function report_error(e) { if (_exit_code) exit _exit_code
                           if (e) { print e; exit _exit_code=1 } }
BEGIN {
    DEBUG = 0
    FS = "-"
}
$0 !~ /^[[:lower:]][[:lower:]]-[[:lower:]][[:lower:]]$/ {
    report_error("DATA ERROR: " $0)
}
{
    if ($1 != $2) {
        PATH[$1][$2] = PATH[$2][$1] = 1
    }
}
END {
    report_error()
    count = 0
    for (node in PATH) {
        SIZE[1][node] = 1
    }
    for (i = 1; i < NR; ++i) {
        for (p in SIZE[i]) {
            if (DEBUG) {
                print "finding paths from", p
            }
            check = split(p, nodes, ",")
            if (check != i) {
                report_error("PROCESSING ERROR: " p " is not of size " i)
            }
            last_node = nodes[i]
            for (node in PATH[last_node]) {
                if (DEBUG > 1) {
                    print "checking paths to", node
                }
                if (node > last_node) {
                    connected = 1
                    for (n = 1; n < i; ++n) {
                        if (!(nodes[n] in PATH[node])) {
                            if (DEBUG > 2) {
                                print "...not connected to", n
                            }
                            connected = 0
                            break
                        }
                    }
                    if (connected) {
                        if (DEBUG > 2) {
                            print "..adding path", p "," node
                        }
                        SIZE[i+1][p "," node] = 1
                    } else if (DEBUG > 2) {
                        print "...not fully connected"
                    }
                } else if (DEBUG > 2) {
                    print "...wrong order"
                }
            }
        }
        if (!((i+1) in SIZE)) {
            break
        }
    }
    for (path in SIZE[i]) {
        print path
    }
}
