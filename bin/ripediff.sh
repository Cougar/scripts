#!/bin/sh
#
# ripediff.sh
#
# Copyright (C) 2010 Cougar <cougar@random.ee>
#
# STDIN  - "Notification of RIPE Database changes" mail
# STDOUT - unified diff between old and new database entry
#

F1=$(mktemp ${TMPDIR:-/tmp}/ripediff-1.XXXXXXXXXX) || exit 1
F2=$(mktemp ${TMPDIR:-/tmp}/ripediff-2.XXXXXXXXXX) || exit 1

cat \
| sed 's/^      \(from\|to\)/                  \1/' \
| awk '
	BEGIN {
		fn = "";
	}
	/^OBJECT BELOW MODIFIED:/ {
		fn = "'$F1'";
	}
	/^REPLACED BY:/ {
		fn = "'$F2'";
	}
	/./ {
		nl = 0;
	}
	/^$/ {
		if (nl == 2) {
			exit;
		}
		nl++;
	}
	{
		if (fn != "") {
			printf("%s\n", $0) >> fn;
		}
	}
'

diff -u $F1 $F2 | less

rm $F1 $F2
