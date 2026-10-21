# Writing Criteria

Every guide in this repo is written to the same
standard. If you're adding or editing a guide —
human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language,
   never dumbed-down concepts. Explain jargon on
   first use; collect terms in the glossary.
2. **No hype.** No marketing adjectives, no
   "revolutionary," no promises about what
   something will do for the reader.
3. **Honest about limits.** Say what the thing
   *can't* do. State uncertainty instead of
   smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults,
   and specs are either measured or qualified with
   "depends on your setup." If it wasn't tested,
   say so.
5. **Checkable.** Commands are meant to be run,
   with "Check:" blocks showing what success looks
   like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out
   Windows/Mac/Linux differences. Don't assume a
   GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get
   stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and
   points elsewhere for the rest. No guide
   pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after
   examples, symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide,
specifically. The build machine ran Ubuntu
24.04.5 LTS with **chezmoi v2.73.3** (the
official release binary, commit
63093ac0e26e803817ced0e2184cb57c4f273388) and
**age v1.3.2** — the only tools this guide
teaches — plus git 2.43.0 underneath, as
`chezmoi doctor` reported it. Every quoted
output in the chapters is a capture from
those tools, run against the lab. Working
transcripts are kept with the guide
(`chezmoi-lab/transcripts/`, 29 files).

**The lab.** Two fake home directories built
by `examples/build-lab.sh`, described in
`examples/lab-notes.txt`: `home-laptop`,
starting with four specimen files (.bashrc,
.gitconfig, .vimrc, todo.txt), and
`home-server`, starting empty. One invented
person, Alex Mercer, with example addresses
on both machines. **The safety rule, which
the build kept without exception: every
chezmoi command ran with `HOME` set to one
of the fake homes. No command was ever run
against the build machine's real home, and no
apply ever touched a real configuration
file.** The lab's git history runs thirteen
commits from the first `add` to the tmux
recipe, and every chapter's state follows
from the one before.

**Verified by running, per chapter:**

- *Ch. 1:* `chezmoi --version` (v2.73.3) and
  `age --version` (v1.3.2), as printed.
- *Ch. 2:* `init` with no argument — source
  directory created already git-initialised,
  no config file created (the `ls .config`
  failure is in the capture); `add` of three
  dotfiles and the `dot_` naming in the
  source listing; the stored file byte-equal
  to the original; `managed` (3 files);
  `status` and `diff` both silent, exit 0.
- *Ch. 3:* the server's pre-apply `status`
  (three ` A` lines) and full `diff`;
  `apply --dry-run --verbose` printing all
  three diffs and writing nothing (proven by
  the listing after); `apply --verbose`;
  the three applied files byte-identical to
  the laptop's (three empty `diff` runs);
  status silent after. The changed-file
  prompt and its TTY failure are chapter
  11's capture, quoted there and here.
- *Ch. 4:* `init` with a repository argument
  cloning the laptop's source directory
  (a local path; see Documented-only for the
  network form); `update` pulling three
  commits in one fast-forward (git's own
  report quoted) and applying them.
- *Ch. 5:* all three directions — a target
  edit showing `MM` in status and appearing
  as a deletion in `diff`, cleared by
  `re-add`; `chezmoi edit --apply` with a
  stand-in editor script (shipped in
  `examples/`), including the "returned in
  less than 1s" warning; a direct source
  edit showing ` M`, applied, and proven
  by `grep` on the target.
- *Ch. 6:* `add --template` renaming the
  source file with a 100% git rename;
  value substitution from `[data]`; the
  rendered laptop file identical to its
  pre-template contents on the values the
  laptop already had; the conditional block
  rendering on the laptop and the `-}}`
  whitespace trim visible in the result.
- *Ch. 7:* the config files (both machines'
  full text ships in `examples/`); `chezmoi
  data` — 313 lines of JSON, your keys at
  the top level, `.chezmoi.hostname` present
  (see lab artefacts below); the server's
  apply rendering the same templates to a
  `.gitconfig` differing from the laptop's
  in exactly two lines (email, editor),
  and a `.bashrc` differing only by the two
  laptop-only lines, `grep -c proj` = 0.
- *Ch. 8:* `todo.txt` stored under its own
  name (no `dot_` for non-dotfiles);
  `.chezmoiignore` dropping it from
  `managed`; the file committed to the
  repository, present in the server's clone,
  absent from the server's home; the
  laptop's existing copy untouched;
  `chezmoi add` of the ignored file refused
  with `warning: ignoring todo.txt`, exit
  0; the same refusal under a temporary
  `*.tmp` pattern, reverted afterwards and
  never committed.
- *Ch. 9:* `run_once_10-stamp.sh` shown in
  status as ` R 10-stamp.sh`; apply
  --verbose displaying the script and then
  its output; the stamp file at exactly one
  line after two applies on the laptop and
  after the server's first `update` there;
  the commit landing as mode 100755.
- *Ch. 10:* the age round trip in full —
  `age-keygen`; `add --encrypt` with no
  configuration failing `encryption not
  configured`, exit 1; with `[age]` but no
  top-level `encryption`, succeeding with
  the `'encryption' not set` warning;
  warning gone once the line was added; the
  sealed source file and its `BEGIN AGE
  ENCRYPTED FILE` header; the server's
  `update` pulling the ciphertext and its
  apply failing `encryption not configured`,
  exit 1, with no target file written; the
  server configured with an identity only
  (decrypt-only) and the apply succeeding,
  the file's contents matching the laptop's
  original, status silent.
- *Ch. 11:* the new-file loop end to end
  (`.tmux.conf` added, committed, delivered
  by `update`); `verify` exit 0 in step and
  exit 1 out of step; the deleted `.vimrc`
  (`DA`), the prompt, `apply --force`
  restoring it, `verify` back to 0;
  `chezmoi cat` printing one file's
  rendering for the local machine's data.
- *Ch. 13:* `chezmoi doctor` in full (exit
  1 on the hardlink row only); the broken
  template — an unclosed action appended
  to `dot_gitconfig.tmpl` — failing apply
  with the parser's message and both line
  numbers, the target file unchanged, and
  recovery by `git checkout` of the
  committed template, after which apply
  and status are clean.

**Capture hygiene (declared trims):**
transcript command echoes flatten shell
quoting (the capture helper echoes commands
after the shell has expanded them, and a few
`sh -c`/`sed` echoes lose their inner
quotes); the *outputs* are exact. Chapters
show commands in the natural `~/…` form and
quote outputs from the captures, shortened
only where a `...` or a sentence in the text
says so: long diffs in chapters 3 and 9, the
313-line `chezmoi data` dump in chapter 7
(quoted head only, count stated), the
recipient string in chapters 7 and 10
(abbreviated with `...`; public keys are
public, but the string is long). Two
artefacts of the lab itself are declared
where they occur: both fake homes sit on one
physical machine, so both report its real
hostname (`htch-runtime`) to `chezmoi data`
— which is why the per-machine differences
are driven from `[data]`, as chapters 6 and
7 state; and the build machine's umask of
007 (mode 660 files, group `nogroup`, setgid
directories) shows in listings and in
doctor's `warning umask 007`, as chapter 13
explains — weather, not chezmoi behaviour.
The secrets chapter's one displayed redaction
belongs to the build environment's output
layer (the transcript shows
`token=<redacted>`); the file's content is
the invented string the lab created it with,
and chapter 10 states it as file content,
not as a quoted capture. Two capture phases
were each retaken once after slips (a wrong
working directory, and a guessed
`dot_todo.txt` source name before chapter
8's lesson was learned from the tool); the
lab's git history is append-only and was
never rewritten to hide either.

**Documented-only (not run), and why:**

- *Windows and macOS behaviour:* the lab is
  one Linux machine. chezmoi is a single
  static binary on all three; differences
  (path spellings, the Windows-specific
  attributes) are described from its
  documentation, never quoted as runs.
- *Password-manager template functions*
  (1Password, Bitwarden, pass, and the
  rest): none of their CLIs exists on the
  build machine — doctor's `info ... not
  found` rows are the evidence quoted in
  chapter 10. Named and placed, not run.
- *`.chezmoiexternal`* (files and archives
  fetched at apply time): not used; the
  lab has no network fixtures. Named in
  the README's scope, not taught.
- *`run_`, `run_onchange_`, `run_before_`,
  `run_after_` scripts:* only `run_once_`
  was run; the relatives are named in
  chapter 9 from the documentation.
- *`chezmoi merge`* (three-way, when both
  states changed): named in chapter 5;
  doctor confirms a merge tool was found,
  but no divergent-edit merge was staged,
  so no behaviour is quoted.
- *Network bootstrap:* the server cloned a
  local path. Cloning a hosted repository
  over SSH/HTTPS is the same command with
  a URL argument; chapter 4 says exactly
  that and no more.
- *The GPG encryption backend:* present on
  the build machine (doctor found gpg
  2.4.4) but unused; age is the verified
  backend.
- *chezmoi's built-in age* (`useBuiltin`):
  the lab used the external age binaries
  on both machines.
- *Init-time config generation* from a
  `.chezmoi.toml.tmpl` in the repository:
  real, and the usual way fleets ship it;
  the lab wrote its two config files by
  hand so their contents could be quoted
  entire.
- *The neighbours* (chapter 12): none was
  installed. Stow, yadm, home-manager,
  Ansible, and the by-hand method are
  placed from their documented mechanisms;
  the chapter argues from design, quotes
  no output, and invents no benchmark.

Specimen discipline, for the record: Alex
Mercer is invented; the email addresses are
example addresses; the token is an invented
string whose only virtue is being findable
again; the age identity (the secret half of
the key pair) lived outside both fake homes
for the whole build and is not part of this
guide — only the public recipient is quoted.
No real person's name, machine, address, or
organisation appears anywhere in the lab.
Every deletion in the guide happened inside
a fake home.
