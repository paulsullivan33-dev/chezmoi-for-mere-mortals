#!/bin/sh
# build-lab.sh — build the chezmoi lab: two fake home directories.
#
# Usage: sh build-lab.sh LABDIR
#
# Creates LABDIR/home-laptop (with specimen dotfiles) and
# LABDIR/home-server (empty). Both are stand-ins for real home
# directories. Every chezmoi command in the guide is run with
# HOME pointed at one of these, so nothing in the lab ever touches
# a real home directory. Read lab-notes.txt before running it.
#
# The script refuses to write into a LABDIR that already exists
# and is not empty. Remove an old lab yourself, by hand, after
# looking at it — the script will not delete anything.

set -eu

if [ $# -ne 1 ]; then
    echo "usage: sh build-lab.sh LABDIR" >&2
    exit 2
fi

lab=$1

if [ -e "$lab" ] && [ -n "$(ls -A "$lab")" ]; then
    echo "build-lab.sh: $lab already exists and is not empty" >&2
    echo "Inspect it, remove it yourself if it is a spent lab," >&2
    echo "then run this script again." >&2
    exit 1
fi

mkdir -p "$lab/home-laptop" "$lab/home-server"

laptop=$lab/home-laptop

cat > "$laptop/.bashrc" <<'EOF'
# Alex's .bashrc -- the shared starting point on every machine.

# History: kept, and shared sensibly between shells.
HISTSIZE=1000
HISTFILESIZE=2000

# Prompt: user@host and the working directory.
PS1='\u@\h:\w\$ '

# Aliases everyone gets.
alias ll='ls -alF'
alias gs='git status'
EOF

cat > "$laptop/.gitconfig" <<'EOF'
[user]
	name = Alex Mercer
	email = alex@example.com
[core]
	editor = vim
[init]
	defaultBranch = main
[alias]
	st = status
	co = checkout
EOF

cat > "$laptop/.vimrc" <<'EOF'
" Alex's .vimrc -- small and portable.
set number
set expandtab
set tabstop=4
set shiftwidth=4
syntax on
EOF

cat > "$laptop/todo.txt" <<'EOF'
Scratch notes -- Alex's own, not configuration.
Milk, eggs, a DisplayPort cable.
EOF

echo "Lab built in $lab:"
echo "  $lab/home-laptop   (specimen dotfiles inside)"
echo "  $lab/home-server   (empty -- the second machine)"
