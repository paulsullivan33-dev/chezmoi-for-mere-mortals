# The Config File

**Scope:** `~/.config/chezmoi/chezmoi.toml` —
the settings and data that belong to one
machine and therefore never enter the
repository — and `chezmoi data`, the complete
picture of what a template can see.

## One file, deliberately unshared

Until now chezmoi has run on defaults — init
did not even create a config file. The file
appears the moment there is something for one
machine to say about itself:

```
$ chezmoi doctor
RESULT    CHECK          MESSAGE
ok        config-file    found ~/.config/chezmoi/chezmoi.toml, last modified ...
```

It lives at `~/.config/chezmoi/chezmoi.toml`,
in TOML, and the most important fact about it
is its address: **the config file is not in
the source directory, so it is never
committed, never cloned, never applied.** Each
machine writes its own. That separation is
what makes the per-machine system honest:
the repository holds what is shared (the
files, the templates, the questions), and the
config holds what is not (the answers).

Alex's laptop config, complete, in the state
the secrets chapter leaves it in:

```toml
# Alex's laptop: machine-specific answers and settings.
# This file lives on this machine only; it is never in the repo.
encryption = "age"

[data]
machine = "laptop"
email = "alex@example.com"
editor = "vim"

[age]
identity = "~/chezmoi-age-key.txt"
recipient = "age14lyekj4m7gtz..."
```

And the server's — the same `[data]` questions
with the server's answers, and an `[age]`
section that chapter 10 explains (`identity`
only: this machine can open secrets, and
needs no ability to create them):

```toml
[data]
machine = "server"
email = "alex@homelab.example"
editor = "nano"

[age]
identity = "~/chezmoi-age-key.txt"
```

(The full text of both files ships in
`examples/`; the recipient string above is
abbreviated in print because it is long, not
because it is secret — public keys are public,
and chapter 10 goes into which half of a key
pair is which.)

Other settings live here too, when you need
them: the `[edit]` command to use instead of
`$EDITOR`, diff and merge tool choices, the
`[git]` auto-commit switches some people run
(chapter 5's manual commits are this guide's
recommendation for learners). chezmoi's
reference lists them all; a young config
should hold little, and every line should be
able to say why it is there.

## chezmoi data: everything a template can see

Where do `.email` and `.machine` come from,
exactly — and what else could a template ask?
`chezmoi data` prints the answer: every value
available to templates on this machine, as
JSON. The lab capture is 313 lines; the
beginning, trimmed with the trim declared, is
the part that teaches:

```
$ chezmoi data
{
  "age": { ... },
  "chezmoi": {
    "arch": "amd64",
    "args": [...],
    "cacheDir": ".../lab/home-laptop/.cache/chezmoi",
    ...
    "fqdnHostname": "htch-runtime",
    "group": "...",
    "homedir": ".../lab/home-laptop",
    "hostname": "htch-runtime",
    ...
    "username": "..."
  },
  "chezmoiTemplateFuncs": {
    ...
  },
  "editor": "vim",
  "email": "alex@example.com",
  "encryption": "age",
  "machine": "laptop",
  ...
}
```

Three kinds of value share that listing:

- **Your data** — the `[data]` keys
  (`machine`, `email`, `editor`), at the top
  level, because templates ask for `.email`,
  not `.data.email`.
- **chezmoi's facts** under `.chezmoi` — the
  machine's hostname, architecture, OS, home
  directory, and more. These need no config
  at all: `{{ .chezmoi.hostname }}` works on
  any machine, which is how most real setups
  branch (a condition on hostname needs no
  hand-set `machine` value at all — the lab
  uses `[data]` throughout for one stated
  reason: the lab's two fake homes share one
  physical machine, so both report the same
  `hostname` in the capture above. On real
  hardware the built-in fact differs by
  itself, and the guide's templates would
  work unchanged keyed on it.)
- **The template functions** under
  `.chezmoiTemplateFuncs` — the toolbox
  (string functions, and the password-manager
  and secret functions chapter 10 discusses).
  They are listed so you can confirm what your
  build offers; the guide uses none of them.

And now the second half of chapter 6 pays
out. On the server — same repository, its own
config, `editor = nano` and a homelab email —
one apply renders the shared templates with
the server's answers:

```
$ diff ~/.gitconfig ../home-laptop/.gitconfig
4c4
< 	email = alex@homelab.example
---
> 	email = alex@example.com
7c7
< 	editor = nano
---
> 	editor = vim
$ grep -c "proj" ~/.bashrc
0
```

Two files, two right answers, one repository —
and the difference between the machines sits
exactly where it belongs: in two small config
files that never leave home. When a value
should differ, put the question in a template
and the answer in a config. When a file
should not travel at all, the next chapter
has the sterner tool.
