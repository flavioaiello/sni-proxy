#!/bin/sh

cp /etc/sniproxy.tmpl /etc/sniproxy.conf

awk -v listeners="${LISTENERS}" 'BEGIN {
    split (listeners, sections, " ");
    for (section in sections) {
        split (sections[section], listener, ";")
        print "listener " listener[2] " {\n   proto " listener[1] "\n   table " listener[1] "\n}\n"
    }
}' >> /etc/sniproxy.conf

awk -v rules="${RULES_HTTP}" 'BEGIN {
    split (rules, sections, " ");
    print "table http {"
    for (section in sections) {
        split (sections[section], rule, ";")
        print "   " rule[1] " " rule[2]
    }
    print "}\n"
}' >> /etc/sniproxy.conf

awk -v rules="${RULES_TLS}" 'BEGIN {
    split (rules, sections, " ");
    print "table tls {"
    for (section in sections) {
        split (sections[section], rule, ";")
        print "   " rule[1] " " rule[2]
    }
    print "}\n"
}' >> /etc/sniproxy.conf

echo "*** Show sniproxy configuration ***"
cat /etc/sniproxy.conf

echo "*** Startup $0 suceeded now starting service using eval to expand CMD variables ***"
exec su-exec sniproxy $(eval echo "$@")
