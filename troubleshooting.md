# Troubleshooting

**Scope:** the failures this setup actually
produces — every entry below happened in the
lab and is quoted from its capture — each with
its cause and its honest fix, and `chezmoi
doctor`, the report to run before all of them.

## First: doctor

When anything is off, run this before
theorizing:

```
$ chezmoi doctor
RESULT    CHECK                       MESSAGE
ok        version                     v2.73.3, commit 63093ac0...
ok        config-file                 found ~/.config/chezmoi/chezmoi.toml, last modified ...
ok        source-dir                  ~/.local/share/chezmoi is a git working tree (clean)
...
error     hardlink                    failed creating hardlink from ~/.local/share/chezmoi to /tmp: ... invalid cross-device link
warning   umask                       007
...
ok        age-command                 found .../age, version 1.3.2
info      1password-command           op not found in $PATH
```

Read it as a checklist with four voices: `ok`
(passed), `info` (a fact — "not set," "not
found" — that is only a problem if you wanted
the thing), `warning` (worth a look), `error`
(the exit status follows it: doctor exited 1
in the lab on the hardlink row alone). Two of
the lab's rows deserve translation, because
both are the *environment* speaking, not
chezmoi failing:

- **`error hardlink ... invalid cross-device
  link`** — doctor tests whether it can
  hardlink between the source directory and
  the temp directory; the lab's two lived on
  different filesystems, so the test cannot
  pass there. On one ordinary disk this row
  is `ok`. An error whose message names its
  own cause is information, not damage.
- **`warning umask 007`** — the build machine
  ran with an unusually strict umask, which
  is also why the lab's listings show `660`
  permissions throughout. chezmoi respects
  your umask; doctor is telling you yours,
  in case your files' permissions surprise
  you later.

Doctor is also the roll-call of helpers: git,
the editor, the merge tool, age and gpg, and
every password-manager CLI chezmoi knows —
each `found` with a version, or `info ... not
found`. When chapter 10's password-manager
route matters to you, doctor is where you
confirm the tool it would call is really
there.

## "has changed since chezmoi last wrote it?"

```
$ chezmoi apply
.vimrc has changed since chezmoi last wrote it?
chezmoi: .vimrc: could not open a new TTY: open /dev/tty: no such device or address
```

**Cause:** a target file differs from what
chezmoi last wrote — edited by hand and never
re-added (chapter 5), deleted outright
(`DA` in status), or written by something
else. Apply refuses to guess which state is
yours. In the lab's scripted capture there
was no terminal to answer with, so the
question itself failed — in a cron job or
pipeline, the same refusal is what you want.

**Fix:** decide, then say so. Wanted change:
`chezmoi re-add FILE`. Expendable: `chezmoi
apply --force FILE`. Unknown: `chezmoi diff`
and read it. The one wrong answer is making
`--force` your default so the question stops
being asked.

## "encryption not configured" — two flavours

```
chezmoi: encryption not configured
chezmoi: .vault_token.age: encryption not configured
```

The first meets `add --encrypt` on a machine
with no encryption configured at all; the
second meets `apply` (or the apply inside
`update`) on a machine holding encrypted
files but no key setup. **Cause:** the config
file lacks some part of chapter 10's recipe.
**Fix:** `encryption = "age"` at the top
level, and an `[age]` section — `identity`
to open files, plus `recipient` to create
them. The related warning, `'encryption' not
set, using age configuration`, means the
`[age]` section exists but the top-level line
doesn't: chezmoi is coping, and telling you
to finish the job.

## The template that does not parse

An editing slip — an unclosed `{{` — appended
to the lab's gitconfig template:

```
$ chezmoi apply
chezmoi: .gitconfig: template: dot_gitconfig.tmpl:13: unclosed action started at dot_gitconfig.tmpl:12
```

Exit 1, and the important part is what did
*not* happen: the target file kept its
previous contents. A template is rendered
before it is written, so a rendering error
stops that file cold. **Fix:** the message
names the template and both line numbers
(where the action opened, where the parser
gave up); repair the source file — or, when
the edit itself was the mistake, let the
repository do what repositories are for:

```
$ chezmoi git -- checkout -- dot_gitconfig.tmpl
$ chezmoi apply
$ chezmoi status
```

Clean. This is the concrete dividend of
chapter 2's commit discipline: the last good
state of any file is one command away,
because you committed it when it was good.
Preview with `chezmoi cat` (chapter 11)
after any template surgery and you will meet
this error at rehearsal instead of at apply.

## The editor that "returned in less than 1s"

`chezmoi edit` warns when the editor exits
almost immediately. **Cause:** almost never a
fast editor — it is a *launcher*: a GUI editor
that forwards the file to a running instance
and returns, or a wrapper script that forgets
to wait. chezmoi concludes (usually rightly)
that no editing happened and says so rather
than applying an unchanged file in silence.
**Fix:** point `EDITOR` — or `[edit] command`
in the config — at the editor's wait-for-me
form (most GUI editors have a `--wait` flag
for exactly this). The lab met the warning
with a one-line stand-in editor and it was
still the correct warning to give.

## A change didn't arrive on the other machine

Work the chain, in order — each link was
demonstrated somewhere in this guide:

1. **Was it committed?** `chezmoi git -- log
   --oneline` on the sending machine. Uncommitted
   work does not travel; the script chapter's
   one exception (a working-tree apply at home)
   does not cross machines.
2. **Was it pulled?** `update` on the receiver,
   or `chezmoi git -- pull` if you are driving
   by hand. A pull conflict speaks git; read it
   in the source directory.
3. **Is it ignored?** `chezmoi managed` is the
   truth about what applies. Chapter 8's file
   sits in every clone and in no home, on
   purpose.
4. **Does it render empty here?** A template
   conditional can legitimately produce
   nothing — or a file whose whole content is
   conditional — on this machine's data.
   `chezmoi cat` shows the rendering; chapter
   7's `chezmoi data` shows the answers it
   rendered from.

And if all four pass and the file is still
wrong: `chezmoi diff`, read slowly, with
chapter 3's direction rule in hand. The diff
has never once in this guide been the liar in
the room.
