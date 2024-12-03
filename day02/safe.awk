#!/usr/bin/env gawk -f
BEGIN {
    DEBUG = 0
}
$0 ~ /^SAFE \( [0-9]+ \):[0-9 ]*$/ {
    skipping = 4 + $3
    separator = ""
    if (DEBUG) {
        printf("SAFE: ")
    }
    for (i = 5; i <= NF; ++i) {
        if (i != skipping) {
            printf("%s%d", separator, $i)
            separator = " "
        }
    }
    printf("\n")
}
$0 ~ /^UNSAFE:[0-9 ]*$/ {
    separator = ""
    if (DEBUG) {
        printf("UNSAFE: ")
    }
    for (i = 2; i <= NF; ++i) {
        printf("%s%d", separator, $i)
        separator = " "
    }
    printf("\n")
}
