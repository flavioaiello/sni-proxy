#!/bin/sh

awk -v listeners="${LISTENERS}" 'BEGIN {
    split (listeners, sections, " ");
    for (section in sections) {
        split (sections[section], listener, ";")
        print "listener " listener[2] " {\n   proto " listener[1] "\n}"
    }
}' >> /etc/sniproxy.conf

awk -v rules="${RULES}" 'BEGIN {
    split (rules, sections, " ");
    print "table {"
    for (section in sections) {
        split (sections[section], rule, ";")
        print "   " rule[1] " " rule[2]
    }
    print "}"
}' >> /etc/sniproxy.conf

echo "*** Show sniproxy configuration ***"
cat /etc/sniproxy.conf

echo "*** Startup $0 suceeded now starting service using eval to expand CMD variables ***"
exec su-exec sniproxy $(eval echo "$@")
