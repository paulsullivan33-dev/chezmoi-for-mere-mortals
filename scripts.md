# Scripts

**Scope:** `run_once_` scripts — files in the
source state that are *run* instead of copied:
when they run, how chezmoi remembers that
they have, and the discipline that a file
which executes on every machine demands.

## A file that runs

Some setup is not a file to place but a thing
to do, once: create a directory a tool expects,
stamp a first-run marker, register something
with the system. chezmoi's answer is a naming
prefix. Write a file into the source directory
called

```
run_once_10-stamp.sh
```

and it is not copied to `~/10-stamp.sh`. At
apply time it is **executed** — the `run_once_`
prefix is the instruction, the `10-` orders it
among its fellow scripts (scripts run in name
order, and 10 leaves room at both ends), and
the rest of the name is yours. A script is
*authored* in the source state rather than
captured from the home like a dotfile; there
is no target file it corresponds to. The lab's
specimen ships as `examples/run_once_10-stamp.sh`,
fifteen lines whose whole job is to leave
countable evidence:

```sh
#!/bin/sh
# run_once_10-stamp.sh -- a specimen first-run script.
... (eight comment lines explaining itself)
echo "run_once_10-stamp: first-run setup ran on this machine"
echo "setup ran" >> "$HOME/.setup-stamp"
```

## Once means once

Status announced the script before it ran —
` R` in the forward column, a thing apply
would *do* rather than write (chapter 3's
table). Apply, with `--verbose`, shows the
script itself as a diff, then runs it — its
output line appears right there in the apply:

```
$ chezmoi status
 R 10-stamp.sh
$ chezmoi apply --verbose
diff --git a/10-stamp.sh b/10-stamp.sh
new file mode 100755
...
run_once_10-stamp: first-run setup ran on this machine
$ cat ~/.setup-stamp
setup ran
```

And the second apply is the actual lesson:

```
$ chezmoi apply
$ wc -l ~/.setup-stamp
1 /home/.../home-laptop/.setup-stamp
```

chezmoi remembers scripts it has run, keyed
by their **contents** — a hash of the script
text, kept in chezmoi's own state on that
machine. Change the script, and the new
content has never run: it runs once more, on
every machine, at its next apply. Leave it
alone, and a hundred applies run it zero
times. The stamp file proves the mechanism
rather than trusting the promise: one line on
the laptop after two applies, and one line on
the server, whose first `update` after the
commit ran it there without ceremony:

```
$ wc -l ~/.setup-stamp
1 /home/.../home-server/.setup-stamp
```

Two honest details from the capture. The
script ran on the laptop *before* it was
committed — chezmoi reads the source working
tree as it stands — and the commit is what
let it travel to the server afterwards:

```
$ chezmoi git -- commit -m "Add a run_once_ first-run script"
[main adc064a] Add a run_once_ first-run script
 create mode 100755 run_once_10-stamp.sh
```

(Messages in this guide are sometimes
re-punctuated in print; the captures keep the
originals.) And the executable bit came along
as `100755`: a script file in the source state
must be executable, as anywhere else.

## The discipline, stated plainly

A `run_once_` script is a small program that
will execute, **with your full privileges, on
every machine that applies your source
state**, the first time it sees it and again
every time its contents change. Hold that
sentence in mind and the rules write
themselves:

- **Scripts must be safe to run, and safe to
  half-run.** An apply can be interrupted;
  a script killed halfway runs again from
  the top next time. Write each step to be
  **idempotent** — harmless if its effect
  already exists (check before creating,
  append only what's missing). The specimen's
  stamp is honest evidence either way,
  because it *records* runs instead of
  assuming.
- **Scripts must not ask questions.** There
  may be no terminal, no you, no second
  chance: chapter 3's prompt failed closed
  over exactly that absence. A script that
  reads input mid-apply will hang or die;
  a script that needs a secret should get it
  the chapter 10 way, not by asking.
- **Small, and few.** Every script is a
  liability carried by every machine. The
  catalogue in the lab is one.

Three relatives exist and are named here so
the names are not strangers — none was run in
the lab, and `criteria.md` records them as
documented-only: **`run_`** scripts, which run
at *every* apply (for checks and refreshes,
at your own risk of noise); **`run_onchange_`**
scripts, which re-run when a tracked file's
contents change — the usual trick is a
template comment carrying the hash of the
file the script installs — and the position
markers **`run_before_`** and **`run_after_`**,
which place a script before or after the file
writes of its apply. Most setups live their
whole lives on `run_once_` alone; reach for
the others with the documentation open.
