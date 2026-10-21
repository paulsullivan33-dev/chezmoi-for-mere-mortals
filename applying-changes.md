# Applying Changes

**Scope:** the rehearsal pair — `status` to
know *that* something differs, `diff` to know
*what* — the two status letters and how to
read them, the dry run, `apply` itself, and
the prompt that stops apply from overwriting
work it cannot account for.

## status: two letters per file

`chezmoi status` prints one line for every
entry that differs between the states, and
nothing for the rest. Each line carries two
status letters. Read them like this:

- **The left letter looks backward**: how the
  target compares with what chezmoi last
  wrote there. A file edited (or deleted)
  behind chezmoi's back shows up here.
- **The right letter looks forward**: how the
  target compares with the source state now —
  in other words, what `apply` would do.

The letters themselves are `A` (add), `M`
(modify), `D` (the target is gone or to be
removed), `R` (a script to run), and a space
where that comparison holds nothing. Every
combination in this guide was met in the lab,
in these situations:

| Code | Met when | What apply would do |
| --- | --- | --- |
| ` A` | the server, before its first apply | write the file |
| ` M` | a source file edited, target untouched | rewrite the target |
| `MM` | a target file edited by hand | overwrite the edit (chapter 5) |
| `DA` | a target file deleted outright | write it again (below) |
| ` R` | a `run_once_` script not yet run | run it (chapter 9) |

Check: the server stand-in, cloned (chapter 4
tells that story) but not yet applied. Status
promises three additions, and `diff` shows
them as ordinary unified diffs against
nothing:

```
$ chezmoi status
 A .bashrc
 A .gitconfig
 A .vimrc
$ chezmoi diff
diff --git a/.bashrc b/.bashrc
new file mode 100660
--- /dev/null
+++ b/.bashrc
@@ -0,0 +1,12 @@
+# Alex's .bashrc -- the shared starting point on every machine.
+...
```

**Direction matters, and it is the one thing
to get right about `diff`:** it shows the
change *apply would make* — from the target's
present contents to the source state's. Lines
with `-` are in your home now and would go;
lines with `+` are in the record and would
arrive. Read backwards — as if the diff
described your edit — you will misunderstand
exactly the cases that matter; chapter 5 shows
a hand-made edit appearing as a deletion,
which is the same fact seen from the honest
side: unrecorded, it is scheduled for removal.

## The dry run, and apply

`chezmoi apply --dry-run --verbose` performs
the whole rehearsal and writes nothing:
verbose makes it print each change as it
"makes" it. On the fresh server, the dry run
printed all three files' diffs — and the home
afterwards held exactly what it held before:
`.local`, the mark of init, and nothing else:

```
$ chezmoi apply --dry-run --verbose
diff --git a/.bashrc b/.bashrc
...
$ ls -la
drwxrws--- 1 root nogroup 12 Oct 21 22:02 .
drwxrws--- 1 root nogroup 10 Oct 21 22:02 .local
```

Then, for real:

```
$ chezmoi apply --verbose
...
$ diff ~/.bashrc ../home-laptop/.bashrc
$ diff ~/.gitconfig ../home-laptop/.gitconfig
$ diff ~/.vimrc ../home-laptop/.vimrc
$ chezmoi status
```

Three empty diffs against the laptop's files,
and status silent: the second machine is in
step, byte for byte. (`--verbose` prints the
same diffs as it applies them; without it,
apply is silent when it succeeds — silence,
again, is the resting state of this tool.)

One more rehearsal instrument: `chezmoi cat
FILE` prints exactly what apply would write
for one file — for a template, the rendering
with *this* machine's data — and touches
nothing. From chapter 6 on it becomes the
quickest way to see a template think.

## The prompt: changed since I wrote it

Apply is not blindly obedient, and the day it
stops you is the day it earns its keep. If a
target file has changed since chezmoi last
wrote it — edited in a way the source state
knows nothing about, or deleted outright —
plain `apply` will not quietly proceed. It
asks:

```
$ chezmoi apply
.vimrc has changed since chezmoi last wrote it?
```

In the lab's non-interactive capture that
question could not be answered, and apply
stopped with an error about opening a TTY —
the safe outcome: **unexplained change means
no change**. You have three honest answers:

1. **The change is wanted.** Record it first
   (`chezmoi re-add`, chapter 5) — then there
   is nothing left to argue about.
2. **The change is expendable.** Say so,
   explicitly, for that file and that run:
   `chezmoi apply --force ~/.vimrc`. The file
   is restored to the recorded state (the
   recipes chapter runs exactly this).
   `--force` is the right tool in scripts and
   scheduled jobs for the same reason it is
   the wrong habit at a keyboard: it answers
   every question "yes, overwrite" before the
   question is asked.
3. **You don't know what the change is.** Stop.
   `chezmoi diff` shows it; decide with your
   eyes open.

The deleted-file case is the common one — a
clobbered or tidied-away dotfile — and the
guard reads it the same way: status showed
`DA` (deleted here; the source would add it
back), and only the prompt stands between the
accident and the repair. That is not chezmoi
being fussy. It is the same rule that saves
you when the "accident" was last night's
careful edit that you forgot to record.
