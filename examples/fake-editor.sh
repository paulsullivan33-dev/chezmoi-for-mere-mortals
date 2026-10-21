#!/bin/sh
# fake-editor.sh -- stands in for a real editor in the lab.
#
# chezmoi edit hands an editor the path of a working copy of the
# source file. A person would type; this script does the smallest
# honest equivalent: it appends one comment line to the file it is
# given, and stops. Set EDITOR to this script's path and
# `chezmoi edit` becomes scriptable, and capturable.

printf '\n" appended by the editor during chezmoi edit\n' >> "$1"
