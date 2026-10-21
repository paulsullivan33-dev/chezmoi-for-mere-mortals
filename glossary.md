# Glossary

**Scope:** the guide's working vocabulary in
one place — chezmoi's own terms first, then
the supporting cast, each with the chapter
that puts it to work.

**source state** — The master copies of your
configuration files, held in the source
directory in chezmoi's naming (chapter 2).
The record; everything else is a rendering
of it.

**source directory** — Where the source state
lives: `~/.local/share/chezmoi` by default,
and a git repository from the moment `init`
creates it. `chezmoi source-path` answers
for any machine.

**target state** — What the files in a home
directory should contain *on this machine*,
computed from the source state: templates
rendered with this machine's data, encrypted
files decrypted with this machine's key.

**destination directory** — The home being
managed — the place targets are written.
In the lab, always a fake one (chapter 1's
safety rule).

**apply** — The act, and the command
(`chezmoi apply`), of making the destination
match the target state: writing what differs
and leaving the rest alone (chapter 3).

**add / re-add** — Recording a file's current
contents into the source state. `add` for a
file newly managed, `re-add` to pull a
target-side edit back into the record
(chapters 2, 5).

**update** — `chezmoi update`: pull the source
repository, then apply. The receiving half of
every change (chapter 4).

**drift** — Any difference between a target
and the record that nobody decided. `status`
is drift made visible, two letters at a time
(chapters 3, 5).

**managed** — Under chezmoi's care: in the
source state and not ignored. `chezmoi
managed` lists the set; everything you own is
managed or not, with no third state (chapter
2, and the exception that proves it in
chapter 8).

**dot_ naming** — The source state's spelling:
a leading dot becomes `dot_` (`dot_bashrc`),
plain names stay plain, and meaning rides in
affixes — `.tmpl` for a template, `encrypted_`
and `.age` for a sealed file, `run_once_` for
a script (chapter 2's table).

**template** — A source file (`.tmpl`) rendered
at apply time: text passes through, `{{ }}`
actions evaluate against the applying
machine's data, and one file becomes several
correct files (chapter 6).

**data** — The values templates can see on a
machine: your `[data]` keys from the config
file, chezmoi's built-in facts under
`.chezmoi`, and the template functions.
`chezmoi data` prints all of it (chapter 7).

**config file** — `~/.config/chezmoi/chezmoi.toml`:
one machine's settings and answers, including
its `[data]` and `[age]` sections. Deliberately
*not* in the repository; it never travels
(chapter 7).

**.chezmoiignore** — A committed file in the
source root naming targets chezmoi will not
apply, anywhere — kept in the repository,
never imposed, and un-addable while listed
(chapter 8).

**run_once_ script** — A source file executed
at apply instead of copied, once per machine
per distinct content (chezmoi remembers a
hash), in name order among its fellows
(chapter 9).

**age** — The encryption tool chezmoi uses
here: a **recipient** (public key, `age1...`)
seals files, an **identity** (the secret key
file) opens them. Ciphertext travels in the
repository; the identity never does (chapter
10).

**chezmoi doctor** — The built-in health
report: version, config, source tree, tools
found and missing, each row `ok`, `info`,
`warning`, or `error` (chapter 13).

**verify** — `chezmoi verify`: the yes/no
question — exit 0 if and only if every target
matches the source state's rendering for this
machine (chapter 11).

**bare repository** — A git repository without
a working tree, used by the by-hand and yadm
approaches so the home directory itself can
serve as the tree (chapter 12).
