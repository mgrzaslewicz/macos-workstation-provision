---
name: add-homebrew-playbook
description: Add a new CLI or GUI tool to this Ansible-based macOS provisioning repo. Use when asked to "add", "install" or "provision" a new tool/app.
---

# Adding a new tool playbook

23 of the last 50 commits in this repo are "Add `<tool>`" — same shape every time. Follow this
recipe instead of improvising it.

## 1. Create `playbooks/<category>/<tool>.yml`

Pick the existing category folder that fits (`various`, `macos`, `java`, `media`,
`file-commander`, `communicator`, ...), or make a new one if the tool starts a new category.

Minimal template (see `playbooks/various/zoxide.yml`, `playbooks/various/lsd.yml`):

```yaml
- name: Install <tool>, <short description>
  hosts: all
  gather_facts: False
  tags: <tool>
  tasks:
    - name: Install <tool>
      homebrew:
        name: <formula-name>
```

- Use the `homebrew` module for CLI formulae, `homebrew_cask` for GUI apps.
- Confirm the actual name with `brew search <tool>` / `brew info <tool>` — don't guess. Tap-qualified
  names (e.g. `jesseduffield/lazygit/lazygit`) break when the formula gets promoted to homebrew-core;
  prefer the bare name if `brew info <tool>` resolves it.
- Only add extra tasks (zsh integration, symlinks, config files) if the tool needs them post-install.

## 2. Wire it into `playbooks/provision.yml`

Add `- import_playbook: <category>/<tool>.yml` in the matching section, next to sibling tools.
Removing a tool later is just the inverse: delete the file and its import line.

## 3. Before committing, check for the non-interactive-provisioning trap

Some cask installers (anything requesting camera/input-monitoring/accessibility permissions, or an
admin password) pop a GUI authorization prompt that hangs or fails under `ansible-playbook`'s
non-interactive execution. This has bitten `karabiner` and `elgato-camera-hub` — both were added
then reverted for this exact reason.

Run `TAGS=<tool> ./provision.sh` end-to-end on a real machine before committing. If it prompts for a
password/authorization mid-install, don't fight it — revert the playbook and add the tool to the
README as a manual install step instead.
