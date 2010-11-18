#!/bin/sh
#
# ripediff.sh
#
# Copyright (C) 2010 Cougar <cougar@random.ee>
#
# STDIN  - "Notification of RIPE Database changes" mail
# STDOUT - unified diff between old and new database entry
#
# For Alpine (Pine) go to (M)ain Menu >> (S)etup >> (C)onfig and under
# "Display Filters" add:
#
# _BEGINNING("OBJECT BELOW MODIFIED:")_ /path/where/installed/ripediff.sh
#

F0=$(mktemp ${TMPDIR:-/tmp}/ripediff-0.XXXXXXXXXX) || exit 1
F1=$(mktemp ${TMPDIR:-/tmp}/ripediff-1.XXXXXXXXXX) || exit 1
F2=$(mktemp ${TMPDIR:-/tmp}/ripediff-2.XXXXXXXXXX) || exit 1

tee $F0 \
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

diff -u $F1 $F2

echo
echo "---------- ORIGINAL MESSAGE ----------"
echo

cat $F0

rm $F0 $F1 $F2
