# What Chezmoi Is

**Scope:** the problem chezmoi solves, the two
states everything else is built from, what
chezmoi is not, and the lab — two fake home
directories, one safety rule, and your version.

## The drift problem

Configuration files — the dotfiles, named for
the dot that hides them — are how your shell,
your editor, and your tools remember what you
taught them. On one machine they look after
themselves. On two, they begin to part company
the first time you fix something on one and
forget to carry it to the other. On three, you
no longer know which copy is the good one, and
copying files by hand — the natural remedy —
eventually overwrites a good version with a
stale one. Everyone with a laptop, a desktop,
and a small server has done this. The failure
is not carelessness; it is the absence of a
record. Nothing says which state is *the* state.

## One source state, many target states

chezmoi's answer is to keep a record. You keep
a **source state**: a directory holding the
master copies of your configuration files,
written in a naming scheme chapter 2 decodes.
The source state usually lives in a git
repository, and the repository is how it
travels. On each machine, chezmoi reads the
source state, works out the **target state** —
what the files in your home directory should
actually contain, on *this* machine — and
**applies** it: writes the files that differ,
and leaves the rest alone.

Three consequences follow, and the whole guide
is built on them:

- **The source state is the record.** A file
  in your home is a rendering. When the two
  disagree, the interesting question is never
  "which is newer" but "which change was
  meant" — chapters 3 and 5 are about asking
  that question before you answer it.
- **Machines may differ on purpose.** Some of
  the source state is **templates**, rendered
  with facts and values belonging to the
  machine doing the applying. One repository,
  several correct answers — chapter 6.
- **The repository is the only traveller.**
  Anything not in it stays home; anything in
  it must be fit to travel — including,
  carefully, secrets. Chapters 8 and 10 are
  the two halves of that rule.

## What chezmoi is not

Precision here saves grief later. chezmoi is
**not a backup tool**: it keeps the files you
tell it about, in their current state, and its
history is only as deep as your git commits.
It is **not a sync daemon**: nothing happens
until you run it, which is a feature — every
change crosses your desk. It is **not a
package manager or a provisioner**: it can run
scripts (chapter 9, with warnings), but it
does not know what a package is. And it does
not manage your documents, your photos, or
anything outside the files you add. It does
one thing — configuration files, kept in step
across machines — and this guide holds it to
that.

## The lab: two homes, one rule

The guide's lab is two directories pretending
to be two machines, built by
`examples/build-lab.sh` (read
`examples/lab-notes.txt` with it):

| Lab name | Stands for | Starts as |
| --- | --- | --- |
| `home-laptop` | Alex's laptop | four specimen dotfiles |
| `home-server` | Alex's home server | empty |

Alex Mercer is invented; so are the addresses,
and so is the token the secrets chapter
encrypts. The specimens are deliberately
ordinary: a `.bashrc`, a `.gitconfig`, a
`.vimrc`, and one file — `todo.txt` — that is
not configuration at all, which turns out to
be a job in itself.

**The safety rule.** Every command in the lab
runs with the `HOME` environment variable set
to one of the fake homes:

```
$ export HOME=$PWD/lab/home-laptop
```

chezmoi believes `HOME` completely. `init`
puts the source directory under it, `apply`
writes into it, and no command in this guide
was ever run against the build machine's real
home. Follow the lab the same way: set `HOME`
in every terminal you use for it, and check
that `chezmoi source-path` names a path inside
your lab before you apply anything. On your
own machines there is no fake home and no
need for one — the rule exists because the
lab borrows a machine that has other work.

Check: the tools, on the build machine. The
guide teaches chezmoi itself; age appears in
chapter 10, where it earns its place:

```
$ chezmoi --version
chezmoi version v2.73.3, commit 63093ac0e26e803817ced0e2184cb57c4f273388, built at 2026-10-20T15:09:45Z, built by goreleaser
$ age --version
v1.3.2
```

chezmoi is a single static binary for Linux,
macOS, and Windows, and the usual package
managers carry it; the lab used the official
release, put on the `PATH` of the fake-home
shells. Whichever way yours arrives, `chezmoi
doctor` (chapter 13) will tell you what it
found — run it once now, so its all-clear is
familiar before you ever need its warnings.
