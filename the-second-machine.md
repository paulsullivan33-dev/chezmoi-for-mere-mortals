# The Second Machine

**Scope:** `init` with a repository — the
second machine clones the source state, and
its first apply brings an empty home into
step — and `update`, the pull-then-apply verb
that carries every later change.

## Init, with something to clone

On a machine that already has a home full of
files, `chezmoi init` made an empty source
directory. On a machine joining an existing
setup, init takes an argument: the repository
to clone *into* the source directory.

```
$ chezmoi init /home/.../lab/home-laptop/.local/share/chezmoi
Cloning into '/home/.../lab/home-server/.local/share/chezmoi'...
done.
```

The lab's repository is a path on the same
disk — the laptop's source directory itself —
because the lab has no network and needs none
to teach the truth: `git clone` treats a local
path and a hosted URL the same way, and so
does chezmoi. In a real setup the argument is
a repository on a git host:

```
$ chezmoi init git@github.com:you/dotfiles.git
```

—the clone, and everything after it, is
identical. One honest difference of topology:
in the lab the server's clone points *at the
laptop*, because there are only two machines
and one disk. At home, both machines clone the
same hosted repository; the laptop pushes its
commits there, the server pulls from there,
and neither machine's disk is special. Keep
that picture; the commands in this guide never
change.

The clone is the whole bootstrap. The server's
source directory now holds the record —
`dot_bashrc`, `dot_gitconfig`, `dot_vimrc` —
and its home holds nothing at all. Bringing
the two together is chapter 3's sequence,
unabbreviated: `chezmoi status` (three ` A`
lines), `chezmoi diff` (every line an
addition), a `--dry-run --verbose` that writes
nothing, and `chezmoi apply`, after which the
server's dotfiles match the laptop's byte for
byte. If you have read chapter 3, you have
already seen this machine arrive. That is the
point: the second machine is not a new topic.
It is the rehearsal pair, at full size.

## update: pull, then apply

From now on, changes are made somewhere and
wanted everywhere. The carrier is ordinary git
— commits on the machine that made the change
— and the receiving verb is:

```
$ chezmoi update
```

`update` does the two things you would do by
hand, in order: it pulls the source repository
(`git pull`, with git's own fast-forward
report shown verbatim), then applies. The
lab's server took three waiting commits in one
update — an alias, a vim note, a history size:

```
$ chezmoi update
From /home/.../lab/home-laptop/.local/share/chezmoi
   285d9f8..b873dee  main       -> origin/main
Updating 285d9f8..b873dee
Fast-forward
 dot_bashrc | 3 ++-
 dot_vimrc  | 2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)
$ grep HISTSIZE ~/.bashrc
HISTSIZE=5000
```

Read that rhythm once and you know the tool's
whole social contract: **change, commit,
update, applied.** Nothing syncs behind your
back; nothing arrives uncommitted; and because
the carrier is git, a change you dislike is a
commit you can inspect, revert, or argue with
— on the machine that received it, using the
history it received with it.

Two cautions, both learned by everyone once:

- **`update` applies what it pulls.** The
  rehearsal pair still exists — pull first by
  hand (`chezmoi git -- pull`) and read
  `status`/`diff` before applying, when a
  change deserves a look. Chapter 11 turns
  this into a standing recipe.
- **A pull can fail like any pull.** Diverged
  histories happen when two machines commit
  changes to the same file from stale states.
  git reports it in its own words, inside the
  source directory, and chapter 5's discipline
  — small commits, update before you edit —
  is what keeps it rare. chezmoi does not hide
  git from you; it stands on it.
