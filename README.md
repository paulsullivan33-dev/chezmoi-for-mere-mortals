# Chezmoi for Mere Mortals

You have two computers — three, counting the little server
under the desk — and on each of them a slightly different
`.bashrc`, a `.gitconfig` with an old email address, vim
settings you fixed on one machine and never carried to the
others. Dotfiles drift. Everyone who works on more than one
machine has a story about copying a file the wrong way and
overwriting the good version with the stale one.

**chezmoi** is the tool that ends the drift. You keep one
**source state** — a directory of configuration files,
usually a git repository — and chezmoi works out what each
machine's files should be and makes them so. Where machines
genuinely differ, **templates** render the shared file with
per-machine answers. Where a file must not travel at all,
an ignore list keeps it home. And where a file is secret,
chezmoi can store it in the repository encrypted, so the
repository alone is useless to anyone who steals it.

This guide builds the whole thing on a lab: two fake home
directories, a laptop and a server, belonging to one invented
person — `examples/build-lab.sh` builds it, and
`examples/lab-notes.txt` explains it, including the one
safety rule the whole lab stands on: **every command is run
with `HOME` pointed at a fake home, never a real one.** Read
that note before you run anything. The commands in this
guide are written for your real setup, but they were all
captured against the fakes, and chezmoi pointed at a real
home directory will manage that home — faithfully, and
without asking twice.

A note on how this guide was verified. chezmoi **2.73.3**
(the official release binary) and age **1.3.2** were run
against the lab, and every behaviour the chapters teach was
captured: the init, the adds, the applies, the templates
rendering differently on the two "machines," the encrypted
round trip — including the failures, of which there were
several instructive ones. The working captures are kept in
`chezmoi-lab/transcripts/`, and `criteria.md` keeps the
ledger of what is verified and what is documented-only.

## What this guide covers

- [**What chezmoi is**](what-chezmoi-is.md) —
  the drift problem; source state and target
  state; what chezmoi refuses to be; the lab
  and its safety rule
- [**First files**](first-files.md) — `init`,
  `add`, and the source state's naming: `dot_`
  for a leading dot, plain names kept, and
  silence as the sign of a setup in step
- [**Applying changes**](applying-changes.md) —
  `status` and `diff`, the rehearsal pair;
  what the two status letters mean; dry runs;
  `apply` itself, and the prompt that guards
  files changed behind chezmoi's back
- [**The second machine**](the-second-machine.md) —
  `init` with a repository, the first apply on
  an empty home, and `update` — pull, then
  apply — as the everyday verb
- [**The edit loop**](the-edit-loop.md) —
  three ways a file changes: edited in place
  and pulled back with `re-add`, edited in
  the source through `chezmoi edit`, and
  edited in the source directly — and why
  the source state is the record
- [**Templates**](templates.md) — one file,
  several renderings: `add --template`, data
  values, a conditional that gives one
  machine an alias the other never sees
- [**The config file**](the-config-file.md) —
  `chezmoi.toml`, the file that is *not* in
  the repository: `[data]`, and `chezmoi data`,
  everything a template can see
- [**Ignoring files**](ignoring-files.md) —
  `.chezmoiignore`: in the repository but
  never applied, un-addable while ignored,
  and left strictly alone where it sits
- [**Scripts**](scripts.md) — `run_once_`
  scripts: run instead of copied, once per
  machine until their contents change, with
  the risks stated plainly
- [**Secrets**](secrets.md) — what never
  enters a dotfiles repository in plain
  text, the honest options, and encryption
  with age, run end to end: ciphertext in
  the repo, a server that cannot open it,
  and the key that changes that
- [**Recipes**](recipes.md) — the loop for a
  new file, restoring a clobbered file,
  proving a machine is in step, and
  rehearsing before you commit to a change
- [**The neighbours**](the-neighbours.md) —
  a bare git repository and symlinks by
  hand, GNU Stow, yadm, home-manager, and
  Ansible: what each trades away
- [**Troubleshooting**](troubleshooting.md) —
  the changed-file prompt, the encryption
  errors in their two flavours, a broken
  template, the editor that returned too
  quickly, and reading `chezmoi doctor`
- [**Glossary**](glossary.md) — the terms,
  collected in one place

## What it doesn't cover

chezmoi's external files (`.chezmoiexternal`, which downloads
archives at apply time), its password-manager template
functions (1Password, Bitwarden, and friends), and its
Windows-specific machinery get honest paragraphs where they
belong, not chapters: they could not be run in this lab, and
`criteria.md` records them as documented-only. Merging with
`chezmoi merge` when both states changed is named in the
edit loop chapter; a full three-way-merge tutorial is a
guide of its own. And chezmoi will not back up your home
directory or sync your documents — chapter 1 is explicit
about what it is not.

## How to use this guide

Read chapter 1, build the lab as it directs, and set `HOME`
to a fake home in every terminal you use for it — then keep
that discipline to the last chapter. Work through the
chapters in order: each one leaves the lab in the state the
next begins from, exactly as if you were setting up real
machines, because underneath the fake names, you are. When
you turn to your own machines, the same order works — with
one addition this guide repeats until it is dull: rehearse
every first apply with `status`, `diff`, and a dry run,
because on a real home the rehearsal is the difference
between a tool that serves you and a surprise.
