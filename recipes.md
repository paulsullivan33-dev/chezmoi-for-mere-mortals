# Recipes

**Scope:** the jobs that recur, as short
sequences — each one assembled from moves the
earlier chapters ran and captured, in the
order you will actually do them.

## Bring a new file under management

The whole loop, laptop to server, for
`.tmux.conf` — written, added, committed,
delivered:

```
$ chezmoi add ~/.tmux.conf
$ chezmoi status
$ chezmoi git -- commit -m "Add .tmux.conf"
[main f003fd9] Add .tmux.conf
 create mode 100644 dot_tmux.conf
```

On the other machine, `chezmoi update`, and
the file is simply there. Two habits inside
the small loop: `status` *before* the commit
(the source state should hold nothing you did
not mean), and a commit message written for
the person on the receiving machine — who is
usually you, later, squinting at a pull.

## Restore a file that was deleted or clobbered

On the server, `~/.vimrc` was deleted outright
(the everyday accident: a tidy-up, a bad
script, a borrowed shell). The sequence:

```
$ chezmoi status
DA .vimrc
$ chezmoi apply --force ~/.vimrc
$ chezmoi verify
```

`DA` is the diagnosis (chapter 3): gone here,
still in the record. Note the `--force`:
plain `apply` meets chapter 3's prompt,
because a deletion *is* a change since
chezmoi last wrote the file, and it cannot
tell tidy-up from sabotage. Here you know —
you deleted it, or found it deleted, and the
recorded state is what you want back. Say so
for that one file. Then let `verify` close
the incident.

## Prove a machine is in step

Don't eyeball it — ask, in a way a script
could ask:

```
$ chezmoi verify
$ echo $?
0
```

`verify` exits 0 when every managed target
matches the source state's rendering for this
machine, and 1 when anything differs —
edited, deleted, unapplied, it does not
care which. Run it after any repair, and
consider it in a login script or a periodic
check if drift keeps surprising you: it is
the one chezmoi command whose whole job is a
yes/no answer.

## Read a template without applying it

Before an apply you are unsure about — a
template edited in a hurry, a machine whose
data you half-remember:

```
$ chezmoi cat ~/.gitconfig
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
```

`cat` prints the file as *this* machine would
render it — the laptop's answers above; run
on the server, the same command prints the
server's email and editor, as chapter 7's
diff showed the apply doing — and changes
nothing: no write, no state change.
It is the rehearsal pair at the scale of one
file, and the fastest template debugger there
is — when a rendering surprises you, `cat`
on the spot beats applying and repenting.

## Rehearse a first apply on any new machine

The joining sequence, whole, from chapter 4
— the one place the guide insists on full
ceremony, because a first apply writes into
a home that was getting along without you:

```
$ chezmoi init <repository>
$ chezmoi status
$ chezmoi diff
$ chezmoi apply --dry-run --verbose
$ chezmoi apply
$ chezmoi verify
```

Read the diff. Every line of it. A first
apply is the one apply where "it would
overwrite that?" is a question you can still
ask cheaply — existing files that differ
from the record will meet chapter 3's prompt,
and the rehearsal is where you decide, file
by file, whether the record or the machine
is right, before anything is written. From
the second apply onward, the short loop —
`update`, glance at `status`, done — is
ceremony enough.
