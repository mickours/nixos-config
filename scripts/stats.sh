#/usr/bin/env bash

set -e

SITE="jeme.libr.fr"
echo Updating site statistics for $SITE
zcat --force /var/log/nginx/access.log* | grep $SITE  > /tmp/access.log
goaccess --log-format=COMBINED -o /data/public/beatrice/website/stats.html /tmp/access.log
echo Site stats for $SITE sucessfully updated \\o/ !
