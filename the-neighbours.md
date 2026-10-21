# The Neighbours

**Scope:** the other honest ways to keep
dotfiles in step — a bare git repository with
symlinks by hand, GNU Stow, yadm,
home-manager, and Ansible — and what each
trades away, so chezmoi's shape is a choice
rather than a default.

An honesty note before the tour: none of the
tools in this chapter was installed in the
lab. They are placed from their documented
designs, not measured against chezmoi on the
same specimens — `criteria.md` records them
as documented-only, and this chapter argues
from *mechanism*, which ages better than
benchmarks would anyway.

## A git repository and your own hands

The zero-tool option, and the one every other
option automates: a git repository (often a
**bare** one, so the work tree is your home
directory itself), and you copying or
symlinking files between the repository and
their homes. **You are the apply engine.** The
virtues are real: nothing to install, nothing
between you and the files, git's history for
free. The costs arrive exactly where this
guide spent its chapters: no record of what
was last written (no chapter 3 guard), no
rendering per machine (no chapter 6), no
checked answer to "am I in step" (no
`verify`). For two machines and three files
it is entirely respectable. The failure mode
is success: file eleven, machine three, and a
copy made the wrong way on a tired evening.

## GNU Stow

Stow manages **symlink farms**: files live in
package directories mirroring their targets,
and Stow links them into place, and unlinks
them on request. Its elegance is that a
managed file *is* the repository file — no
copying, no state, edit either end. Its
limits are the mirror image of its elegance:
no templates and no per-machine rendering
(the usual workaround is one package per
machine, drifting in parallel), no memory of
what it last did, and no answer for files
that must exist as real files rather than
links. For a single machine, or several
near-identical ones, Stow's simplicity is a
genuine argument. The moment one file must
say `nano` here and `vim` there, you are
building chapter 6 by hand.

## yadm

yadm is chezmoi's closest cousin: a wrapper
around a bare git repository in your home,
with **alternate** files selected by class,
OS, or hostname (`file##os.Linux` and
friends), plus built-in encryption (GPG or
OpenSSL) and optional bootstrapping. Where
chezmoi renders one template with data, yadm
picks among whole sibling files — coarser,
and for mostly-identical files, heavier; for
files that differ wholesale, arguably more
honest. Its git *is* the interface, which git
fluent users count as purity and others as
exposure. The real choice between the two is
taste in mechanism — rendering versus
selection — and either serves a setup well.
This guide teaches the rendering one.

## home-manager (Nix)

home-manager generates your configuration
from a declarative Nix program: files,
packages, services, all derived from one
evaluated description, reproducible to the
hash. It is not a dotfiles manager with
extras; it is a different universe, in which
"what is my `.bashrc`" has the same answer
kind as "what is my system." The power is
unmatched and the price is the universe
itself: a language to learn, an evaluation
model to inhabit, and debugging that happens
in Nix before it happens in your files. If
your machines already live there, nothing in
this guide should pull you out. If they
don't, chezmoi's bet — plain files, one
small tool, git underneath — is the
deliberately smaller commitment.

## Ansible

Ansible configures machines from playbooks:
packages, users, services, files — the whole
host, idempotently, over SSH, at fleet scale.
Dotfiles are a rounding error in its world,
handled by its template and copy modules
perfectly competently. Reach for it when the
*units* are machines you administer in
numbers and the config is the institution's;
it answers "make these fifty hosts so," not
"keep *my* files in step on the boxes I
own." It also inverts the direction of trust:
an admin workstation pushes state outward,
where chezmoi has each machine pull and
apply its own. Different jobs. Both honest.

## Placing chezmoi

| Approach | Mechanism | Per-machine differences | Memory of last write |
| --- | --- | --- | --- |
| git by hand | you copy or link | by hand | none |
| GNU Stow | symlink farm | per-package copies | none |
| yadm | git + file selection | alternate whole files | git's alone |
| chezmoi | render + apply | templates with data | yes — status, diff, verify |
| home-manager | declarative generation | in the Nix program | the store itself |
| Ansible | push over SSH | variables and templates | the playbook's facts |

chezmoi's wager is the middle row: that
configuration files deserve a *record* (a
source state with history), a *rendering*
step (so one record can be several correct
answers), and a *checked apply* (so a machine
can prove it is in step) — and that all three
fit in one binary that stands on ordinary
git. The rest of the guide exists to show
that wager being kept. If your needs are
smaller, Stow is waiting with its head held
high; if they are larger, so is Nix.
