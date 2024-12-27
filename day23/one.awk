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
    for (n1 in PATH) {
        for (n2 in PATH[n1]) if (n2 > n1) {
            for (n3 in PATH[n2]) if (n3 > n2) {
                if (n3 in PATH[n1]) {
                    if ((substr(n1,1,1) == "t") || (substr(n2,1,1) == "t") || (substr(n3,1,1) == "t")) {
                        ++count
                        if (DEBUG) {
                            print n1, n2, n3
                        }
                    }
                }
            }
        }
    }
    print count
}
