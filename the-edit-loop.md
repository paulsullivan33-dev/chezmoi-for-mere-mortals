# The Edit Loop

**Scope:** the three directions a managed file
can change — target edited and pulled back
with `re-add`, source edited through
`chezmoi edit`, source edited directly — and
the habit that makes all three safe: the
source state is the record, and every change
ends in a commit.

## Direction one: you edited the file itself

This is the direction life actually takes. A
shell is open, the file is there, and the
alias gets added to the file — not to anyone's
source state:

```
$ echo "alias gd='git diff'" >> ~/.bashrc
$ chezmoi status
MM .bashrc
```

`MM`: the backward letter reports the target
no longer matches what chezmoi last wrote;
the forward letter reports that apply would
change it — and `diff` shows what that means,
without sentimentality:

```
$ chezmoi diff
@@ -10,4 +10,3 @@
 # Aliases everyone gets.
 alias ll='ls -alF'
 alias gs='git status'
-alias gd='git diff'
```

Read with chapter 3's direction rule, the
meaning is exact: your new alias exists only
in the target, so as far as the record is
concerned it is scheduled for deletion. The
fix is to record it. **`chezmoi re-add`**
re-reads the target file into the source
state:

```
$ chezmoi re-add ~/.bashrc
$ chezmoi status
$ chezmoi git -- commit -m "Add gd alias (re-added from the laptop)"
```

Status silent, change committed, drift gone.
`re-add` is `add` with memory: same copy into
the source, for a file already managed. The
choice it embodies is the whole chapter in
miniature — when target and source disagree,
*decide* which one is right, and use the
command that says so. Apply overwrites the
target with the record; re-add rewrites the
record from the target. Both are honourable.
Guessing is not.

## Direction two: chezmoi edit

**`chezmoi edit FILE`** opens the *source*
file in your editor — for templates and
encrypted files, a decrypted, rendered-for-
editing copy — and with `--apply`, applies
the result when the editor closes. It is the
loop with the fewest steps for a deliberate
change, and the lab ran it with a stand-in
editor (a script that appends one line, kept
as `examples/fake-editor.sh`) so the run could
be captured:

```
$ chezmoi edit --apply ~/.vimrc
chezmoi: warning: .../fake-editor.sh .../dot_vimrc: returned in less than 1s
$ tail -3 ~/.vimrc
syntax on

" appended by the editor during chezmoi edit
```

The note is in both the source and the target,
ready to commit. And the warning is real and
worth understanding: chezmoi watches the
editor's behaviour, and an editor that returns
in under a second is probably one that did
nothing — a GUI editor that handed the file to
an already-running instance and exited, a
launcher script that forgot to wait. With a
real editor you will not see it; if you do,
your edit likely never happened (chapter 13
returns to this). Set `EDITOR` to the editor
you mean; a per-machine `edit.command` in the
config file (chapter 7) refines it further.

## Direction three: edit the source, apply

The source state is plain files in a plain
directory. Nothing stops you editing them with
anything at all — `chezmoi cd` drops you in
that directory, or walk in directly — and for
some work (a search-and-replace across files,
your usual editor already open there) it is
the natural route:

```
$ sed -i 's/^HISTSIZE=1000/HISTSIZE=5000/' .local/share/chezmoi/dot_bashrc
$ chezmoi status
 M .bashrc
$ chezmoi apply
$ grep HISTSIZE ~/.bashrc
HISTSIZE=5000
```

The ` M` pair is the signature: the target is
untouched since chezmoi wrote it (left space),
and the source has moved (right `M`). Commit
the source change, and the loop is closed;
the server's next `update` carried this very
change, together with the other two
directions' work, in chapter 4's capture.

## The standing habits

Three directions, one discipline:

- **Update before you edit.** A change built
  on a stale source state is a merge waiting
  to happen. `chezmoi update` at the start of
  a session costs seconds.
- **Commit every change, small.** The commit
  is the unit of travel and of undo. "Various
  tweaks" is neither.
- **Rehearse when it matters.** `status` and
  `diff` before `apply`, on any machine where
  the change is news to you. The pair costs
  nothing and has, in this guide alone, caught
  an edit that would have deleted an alias and
  a deletion that looked like damage.

A word on the fourth direction, the one this
guide names but does not teach: both sides
changed the same file, differently, and a
real decision is needed. chezmoi has a `merge`
command that opens a three-way merge with the
last-applied state as the ancestor. It is the
right tool on the day, and the habits above
are what keep that day rare; a merge tutorial
is beyond this guide's scope, and the
doctor's report (chapter 13) confirms
`vimdiff` was found on the lab machine for
when it comes.
