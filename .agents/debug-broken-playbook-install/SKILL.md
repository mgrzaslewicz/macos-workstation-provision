---
name: debug-broken-playbook-install
description: Diagnose and fix an existing Ansible playbook in this repo whose install step started failing. Use when a playbook task errors out or a previously-working tool's provisioning breaks.
---

# Fixing a broken playbook install

10 of the last 50 commits here are "Fix `<tool>` installation". They almost always trace back to one
of these four causes — check them in order before writing a custom fix.

## 1. The brew formula/cask/tap name changed

`brew search <tool>` / `brew info <tool>` first. Tap-qualified formula names
(`jesseduffield/lazygit/lazygit`) break once a tool gets promoted into homebrew-core — switch to the
bare name (`lazygit`). This was the entire fix for `playbooks/git/lazygit.yml`.

## 2. A hand-rolled GitHub-release download exists where a cask now works

If the playbook has custom `uri`/`get_url`/`unarchive`/`tempfile` tasks scraping the GitHub releases
API, check `brew info --cask <tool>` — if a cask exists, replace the whole block with a single
`homebrew_cask` task. `playbooks/file-commander/mu-commander.yml` went from 79 lines to 3 this way
when the GitHub-API-based install broke. Custom download logic is far more fragile than brew's own
update machinery — don't re-implement it unless no cask/formula exists.

## 3. The task fails only because the tool is already installed via another path

`vagrant`, `zoom`, and `docker` all legitimately error when brew tries to (re-)install something
already present as a manual install, a bundled VM, or an admin-managed package. If that's the failure,
add `ignore_errors: true` with a comment stating *why* — don't add it reflexively, since it will also
swallow real, unrelated failures.

## 4. A shell task needs to change system-owned state

Tasks that call `chsh`, write under `/opt`, or otherwise need root will fail with a permission error
under the non-privileged Ansible user. Add `become: true` to the task rather than wrapping `sudo`
inside the shell string (see `playbooks/zsh/zsh.yml`).

## Verify

Reproduce with `TAGS=<tool> ./provision.sh` end-to-end — brew/cask state on your existing dev machine
can mask a failure that only shows up on a clean install.
