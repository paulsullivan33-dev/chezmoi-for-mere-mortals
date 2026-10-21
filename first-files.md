# First Files

**Scope:** `init` on an empty setup, `add` and
the source state's naming — `dot_` for a
leading dot, suffixes and prefixes that mean
things — and the first commit, in the
repository chezmoi makes for you.

## Init: the source directory appears

Run `chezmoi init` with no argument, in a
terminal whose `HOME` is the laptop lab home.
It prints nothing. What it has done is quiet
and specific: it has created the **source
directory** — `~/.local/share/chezmoi` — and,
because the source state belongs under version
control, it has already run `git init` in it.

Check: the lab laptop before init held only
Alex's four specimens; afterwards, exactly one
new thing exists:

```
$ chezmoi init
$ find .local -maxdepth 3
.local
.local/share
.local/share/chezmoi
.local/share/chezmoi/.git
```

Notice what init did **not** do: there is no
config file yet (no `~/.config/chezmoi` at
all), and no file in the home has been read,
moved, or managed. chezmoi works from defaults
until there is something to say, and chapter 7
is about the file you write when there is.
`chezmoi source-path` answers where the source
state lives, on any machine, at any time —
make a habit of it; in the lab it is also your
proof that `HOME` is pointing at a fake.

## Add: recording a file

`chezmoi add` copies a file's current contents
into the source state. The original stays
exactly where it was; nothing about the home
changes. Add the laptop's three real dotfiles:

```
$ chezmoi add ~/.bashrc ~/.gitconfig ~/.vimrc
$ ls -la .local/share/chezmoi
drwxrws--- 1 root nogroup  98 Oct 21 22:01 .git
-rw-rw---- 1 root nogroup 283 Oct 21 22:01 dot_bashrc
-rw-rw---- 1 root nogroup 139 Oct 21 22:01 dot_gitconfig
-rw-rw---- 1 root nogroup 105 Oct 21 22:01 dot_vimrc
```

The stored names are the first piece of the
source state's language, and it is a small
language worth learning properly:

| Target name | Source name | The rule |
| --- | --- | --- |
| `.bashrc` | `dot_bashrc` | a leading dot becomes `dot_` |
| `todo.txt` | `todo.txt` | no dot, no change |
| `.gitconfig` (template) | `dot_gitconfig.tmpl` | `.tmpl` marks a template |
| `.vault_token` (encrypted) | `encrypted_dot_vault_token.age` | `encrypted_` prefix, `.age` suffix |
| (a script) | `run_once_10-stamp.sh` | `run_once_` prefix means *run*, chapter 9 |

The `dot_` rule exists so the source state is
pleasant to keep in a repository: no hidden
files, everything visible in an ordinary
listing. Files without a leading dot keep
their names — the lab learns this the direct
way in chapter 8, when `todo.txt` joins the
repository under its own name. The other rows
arrive in their chapters; the table is complete
for this guide, and chezmoi's full naming
grammar (there are attributes for permissions,
symlinks, and more) is in its reference
documentation when you need it.

And the stored content, for a plain add, is
the file itself, byte for byte:

```
$ cat .local/share/chezmoi/dot_bashrc
# Alex's .bashrc -- the shared starting point on every machine.
...
```

`todo.txt` was not added. It sits in the home,
present and unmanaged — the two states every
file you own is always in. `chezmoi managed`
lists the managed side:

```
$ chezmoi managed
.bashrc
.gitconfig
.vimrc
```

## Silence means in step

Two commands report any difference between
the source state and the home, and chapter 3
gives them a full treatment. Meet them now,
in their resting state: right after an `add`,
there is nothing to report, and both say so
by saying nothing at all.

```
$ chezmoi status
$ chezmoi diff
```

(Both printed nothing and exited 0.) Learn to
love that silence, and to distrust any summary
of this tool that calls it boring: the entire
point of the record is that "nothing to
report" is a *checked* fact, not a hope.

## The first commit

The source directory is a git repository
because chezmoi made it one, and `chezmoi git
--` runs any git command inside it, from
wherever you are standing:

```
$ chezmoi git -- config user.name "Alex Mercer"
$ chezmoi git -- add dot_bashrc dot_gitconfig dot_vimrc
$ chezmoi git -- commit -m "Alex's dotfiles, first state"
[main (root-commit) 285d9f8] Alex's dotfiles, first state
 3 files changed, 28 insertions(+)
```

Commit early and in small steps, with messages
that say what changed and why. This is not
ceremony. The repository is the record, its
history is the only "undo" the system has
(chapter 13 uses it to recover from a broken
template), and on the second machine
(chapter 4) the history is literally what
travels.
