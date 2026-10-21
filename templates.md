# Templates

**Scope:** making a file a template, and what
a template can see — values that come from
each machine, so one file in the repository
renders as several correct files: an email
and editor that differ, and an alias only one
machine ever gets.

## Why templates exist

Most of a dotfile is the same everywhere —
that sameness is why chezmoi exists. But
*some* lines are per-machine facts: the email
you commit under at a desk versus on a home
server, the editor installed there, an alias
for a directory only one machine has. Without
templates you choose between duplicating the
file per machine (and watching the copies
drift — the original disease, one level up)
and forcing one machine's answers on all.
Templates are the third option: the file in
the repository contains the question, and
each machine supplies its answer.

## Making a template

Any managed file becomes a template by
re-adding it with `--template`. The source
file gains a `.tmpl` suffix and — this is the
part that makes the operation safe to try —
**its content is not changed at all**:

```
$ chezmoi add --template ~/.gitconfig
$ ls .local/share/chezmoi
dot_bashrc
dot_gitconfig.tmpl
dot_vimrc
$ chezmoi git -- commit -m "Gitconfig becomes a template (email, editor)"
 rename dot_gitconfig => dot_gitconfig.tmpl (100%)
```

A template is written in Go's template
language: text passes through untouched, and
actions inside `{{ }}` are evaluated when the
file is rendered — which happens at `apply`
(and `cat`), on the applying machine, with
that machine's data. Alex edits two lines of
the template:

```
$ cat .local/share/chezmoi/dot_gitconfig.tmpl
[user]
	name = Alex Mercer
	email = {{ .email }}
[core]
	editor = {{ .editor }}
...
```

`.email` and `.editor` are **data values** —
where they live and how they differ per
machine is chapter 7's subject; for now, the
shape of the deal: the config file on each
machine (never in the repository) carries a
`[data]` section, and names defined there are
yours to use in any template. On the laptop,
where the data says `alex@example.com` and
`vim` — the very values the file already had —
the apply is a non-event:

```
$ chezmoi apply
$ grep -E 'email|editor' ~/.gitconfig
	email = alex@example.com
	editor = vim
```

That non-event is the correct first template
experience: convert, template, and prove the
rendering identical on the machine you
started from, *before* letting it differ
anywhere. `chezmoi cat ~/.gitconfig` shows
the rendering without even that much churn.

## A conditional: the alias one machine gets

Values substitute; templates also decide.
`.bashrc` becomes a template the same way,
with a block that exists only where the data
says the machine is the laptop:

```
{{ if eq .machine "laptop" -}}

# Laptop only: the projects directory shortcut.
alias proj='cd ~/projects'
{{ end -}}
```

`{{ if ... }}` tests a value (here, equality
with a string) and the block renders only
when it holds; `{{ end }}` closes it. On the
laptop:

```
$ chezmoi apply
$ tail -4 ~/.bashrc
alias gs='git status'
alias gd='git diff'
# Laptop only: the projects directory shortcut.
alias proj='cd ~/projects'
```

Two things to notice in that rendering. First,
no trace of the machinery — a rendered file is
just a file; nothing in the target says it was
ever a template. Second, a small disappearance:
the blank line before `# Laptop only`, visible
in the template, is gone. The `-` inside
`{{ if ... -}}` is whitespace control: it eats
the whitespace that follows the action, so
template-only lines leave no empty lines
behind. Harmless here, and the knob you will
reach for the first time a stray blank line
(or a missing one) shows up in a rendering.
The server's rendering of the same template —
no alias, no comment, no scar — is chapter
7's other exhibit, where the data that drives
all of this gets its own hearing.

Templates can do much more — loops, functions,
reading other files, asking password managers
for values — and most dotfiles need none of
it. The two moves in this chapter, *substitute
a value* and *include a block on a condition*,
carry the ordinary per-machine differences of
an ordinary setup. Chapter 13 covers the
failure you will actually meet: the template
that does not parse, and why it harms nothing
when it doesn't.
