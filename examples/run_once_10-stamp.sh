#!/bin/sh
# run_once_10-stamp.sh -- a specimen first-run script.
#
# A file in the source state whose name begins run_once_ is not
# copied anywhere: chezmoi RUNS it, once, on each machine. It
# remembers the run (a hash of the contents, in chezmoi's own
# state), so the script runs again only when its contents change.
# The number is just part of the name -- scripts run in name
# order, and 10 leaves room at both ends.
#
# This one leaves evidence you can count: one line in
# ~/.setup-stamp per actual run, plus a line said out loud.

echo "run_once_10-stamp: first-run setup ran on this machine"
echo "setup ran" >> "$HOME/.setup-stamp"
