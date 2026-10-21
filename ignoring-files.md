# Ignoring Files

**Scope:** `.chezmoiignore` — the file that
says *keep this in the repository, and never
apply it, anywhere* — and what ignoring does
and does not do to the file itself, on both
machines.

## The specimen: a file that is not configuration

The lab's fourth specimen has been waiting
for this chapter. `todo.txt` — a scratch note,
two lines of reminders — is not configuration.
But it *accidentally* became the most
instructive file in the lab, twice over.

First, it taught the naming rule from the
other side. Placed in the source directory by
hand, it kept its name:

```
$ ls .local/share/chezmoi
dot_bashrc.tmpl
dot_gitconfig.tmpl
dot_vimrc
todo.txt
```

Only files whose target names begin with a
dot get the `dot_` treatment (chapter 2). A
plain file is stored as itself. chezmoi
manages any file in the home you add — dotfile
or not — and the scope of your setup is
exactly the list you choose.

Second, it is the natural subject for an
ignore rule: a note that is Alex's, that
belongs with the dotfiles in the repository
for safekeeping, and that no machine should
ever have imposed on it — the server has its
own life, and did not ask for the laptop's
reminders.

## .chezmoiignore

The ignore file lives in the root of the
source directory, is committed like everything
else, and lists target paths — one per line,
with patterns allowed, in the spirit of
`.gitignore`:

```
$ cat .local/share/chezmoi/.chezmoiignore
todo.txt
$ chezmoi managed
.bashrc
.gitconfig
.vimrc
```

`managed` is the visible effect: the list of
what chezmoi is responsible for shrinks by
exactly the ignored entries. The file itself
was committed in the same breath — note the
pair of commits, which between them state the
whole policy:

```
16de004 Ignore todo.txt: kept in the repo, no longer managed
b272741 Keep todo.txt in the repo (ignored: never applied)
```

## What ignoring does — three guarantees, all run

**It does not apply.** The server cloned a
repository containing `todo.txt` (it is right
there in its source directory, beside
`dot_vimrc`), applied everything, and never
received the file at home. `ls` of the server
home shows the managed files and
`.vault_token` from chapter 10 — and no
`todo.txt`.

**It does not touch what exists.** On the
laptop, `todo.txt` sat in the home before,
during, and after. Ignoring is not deleting:
chezmoi's hands come off an ignored file
entirely, in both directions, forever. If you
want a file *gone* from a machine, that is a
different act, done by you, and a removed
target file is something chezmoi notices
(chapter 3's `DA`) only while it manages the
file.

**And it cannot be added.** While the rule
stands, even a deliberate `add` is refused:

```
$ chezmoi add ~/todo.txt
chezmoi: warning: ignoring todo.txt
```

(Exit status 0, but the file does not enter
the source state — run `managed` and see.)
Patterns behave the same way: with a temporary
`*.tmp` line added to the lab's ignore file,
a scratch file was refused with the same
warning, and the line was taken back out
afterwards — the refusal is from the *rule*,
not the filename, which is what makes the
file worth keeping curated.

## When to ignore

The uses are judgment calls, and they recur:

- **Travels in the repo, belongs nowhere:**
  notes, drafts, a `.txt` of machine-specific
  lore — this chapter's specimen.
- **Machine-local files a tool insists on
  writing** into a managed directory, whose
  contents are per-machine exhaust rather
  than configuration.
- **A file mid-argument:** two machines
  disagree about a file and you are not ready
  to template the difference. Ignore it on
  the machines where it does harm while you
  think — the honest stopgap, better than a
  daily overwrite war.

Keep the file short and each line defensible.
An ignore entry is a small policy decision
recorded in the repo: *this travels, and is
never imposed.* If you cannot say why a line
is there, it is probably hiding a template
you have not written yet.
