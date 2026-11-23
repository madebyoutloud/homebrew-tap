# Outloud Homebrew tap

The formula for Outloud's internal CLI, `outloud`, with its `outloud ai` command. Installing it needs an Outloud account. Install with:

```bash
curl -fsSL https://cli.outloud.dev/install.sh | sh
```

It signs you in and installs the formula when Homebrew is there. In a Brewfile, add `tap "madebyoutloud/tap"` with `brew "madebyoutloud/tap/outloud"`. On a new machine, run the command above once before `brew bundle`, since the formula downloads with the token it saves.

To point a formula at a release, run `scripts/update-formula.sh outloud <version>`.
