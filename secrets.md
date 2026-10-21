# Secrets

**Scope:** the rule that outranks convenience —
a dotfiles repository is copied to every
machine and usually to a git host, so anything
in it in plain text must be treated as
published — and the honest options: keep
secrets out, or keep them in encrypted, with
the age round trip run end to end.

## First, the risk, without decoration

Dotfiles collect secrets the way pockets
collect lint. An API token pasted into a
config "temporarily." A password in a shell
history helper. A private key committed
because the directory felt private. Under
chezmoi the stakes are higher than under a
quiet directory on one machine, because the
repository is *designed* to travel: cloned to
every machine you own, pushed to a host,
backed up with everything else. A plaintext
secret in it is not stored; it is
**distributed**.

So the first question for any file is not
"how do I sync this" but "may this travel at
all." Three answers are respectable:

1. **It never enters the repository.** The
   file stays unmanaged, or managed-but-
   ignored (chapter 8), or exists on each
   machine as a local file a template
   *expects* but does not contain. Most
   secrets belong here: they are few, they
   change rarely, and typing one per machine
   is not the burden it feels like.
2. **A template asks for it at apply time**
   from a password manager — chezmoi has
   template functions for 1Password,
   Bitwarden, pass, and a dozen more.
   `chezmoi doctor` looked for all their
   command-line tools in the lab and found
   none, so this route is named, placed, and
   recorded in `criteria.md` as
   documented-only: real, supported, unrun
   here.
3. **It travels encrypted.** The repository
   holds ciphertext; each machine that may
   open it holds a key the repository never
   sees. This is the route the lab runs,
   below — because some files genuinely must
   exist on several machines (a token a tool
   reads on each), and for those, encryption
   is the difference between a repository
   that may be stolen and one that may not
   be read.

## age, and the two halves of a key

chezmoi encrypts with **age** (or GPG; age is
the modern, simpler tool, and the one run
here). `age-keygen` makes a key pair:

```
$ age-keygen -o ~/chezmoi-age-key.txt
Public key: age14lyekj4m7gtz...
```

The pair's halves have opposite jobs and
opposite handling:

- The **recipient** (the public key,
  `age1...`) encrypts. It is safe to publish —
  it appears in configs and could appear in
  the repository itself.
- The **identity** (the key file, containing
  an `AGE-SECRET-KEY-...` line) decrypts. It
  is a secret in the full sense: it never
  enters the repository, never enters a
  config's *contents* beyond being pointed
  to, and is carried to each machine by a
  channel that is not the dotfiles repo —
  the lab kept it outside both fake homes
  entirely. **Lose the identity and the
  encrypted files are gone** — not locked
  pending support, gone; that is what the
  mathematics means. Keep a copy somewhere
  that survives a dead disk, somewhere that
  is not the repository.

## The round trip, failures included

Alex's specimen is `~/.vault_token`, a small
file with an invented token. The failures
come first, because they are the teaching:

```
$ chezmoi add --encrypt ~/.vault_token
chezmoi: encryption not configured
```

Exit 1, nothing added: with no encryption
configured, chezmoi refuses rather than
guessing. The fix is the config file saying
two things — which backend, and this
machine's key material (chapter 7's file):

```toml
encryption = "age"

[age]
identity = "~/chezmoi-age-key.txt"
recipient = "age14lyekj4m7gtz..."
```

With `[age]` present but the top-level
`encryption = "age"` missing, the add
*succeeds with a warning* — the lab captured
it on purpose:

```
$ chezmoi add --encrypt ~/.vault_token
chezmoi: warning: 'encryption' not set, using age configuration. Check if 'encryption' is correctly set as the top-level key.
```

Adding the line silences it; warnings that
explain themselves deserve obedience. What
the add leaves in the source state:

```
$ ls .local/share/chezmoi
dot_bashrc.tmpl
dot_gitconfig.tmpl
dot_vimrc
encrypted_dot_vault_token.age
run_once_10-stamp.sh
todo.txt
$ head -2 .local/share/chezmoi/encrypted_dot_vault_token.age
-----BEGIN AGE ENCRYPTED FILE-----
YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBYdjJRQjNJVmxGQlg2Kzlp
```

The naming is chapter 2's table completed:
`encrypted_` prefix, `dot_` for the dot,
`.age` suffix. The content is ciphertext
under an age header — commit it, push it,
lose the laptop it sits on: what travels is
a sealed envelope.

Now the server, which has the ciphertext and
(no config yet) no key:

```
$ chezmoi update
...
 chezmoi: .vault_token.age: encryption not configured
$ ls ~/.vault_token
ls: cannot access '.../.vault_token': No such file or directory
```

The pull succeeded; the apply inside the
update failed on the encrypted file, exit 1,
and **nothing was written** — a smaller echo
of chapter 3's rule: chezmoi would rather
stop than improvise about secrets. Give the
server an `[age]` section with the identity
and nothing else — no recipient, since the
server must *open* secrets, and creating new
ones is the laptop's job — plus the same
`encryption = "age"` line, and:

```
$ chezmoi apply
$ chezmoi status
```

(silent), and the file on the server reads
exactly what the laptop sealed:

```
token = lab-fake-token-1234
```

That is the round trip: born on one machine,
sealed, carried by an ordinary commit through
an ordinary repository, refused where no key
was held, opened where one was. The
repository did its whole job without ever
being trusted.

## Standing rules for secrets

- **Plaintext secrets never enter the repo.**
  Not "temporarily," not in a comment, not in
  a commit you plan to squash away later —
  git history remembers, and chapter 2's
  history-as-record cuts both ways. If one
  ever does get in, the secret is compromised:
  rotate it; rewriting history is theatre.
- **The identity lives outside the repo**,
  on each machine that needs it, with a
  backup that is also outside the repo.
- **Encrypt the file, not the repository.**
  Ordinary dotfiles stay readable, diffable,
  and reviewable; only the files that must
  be sealed pay the opacity cost. (Editing an
  encrypted file goes through `chezmoi edit`,
  chapter 5, which decrypts for the editor
  and re-seals on the way out.)
- **A new machine gets the key by hand.**
  That small friction is the security model,
  working as intended.
