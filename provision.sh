#!/usr/bin/env bash
set -x

SKIP_TAGS_OPTION=""
if [[ -n $SKIP_TAGS ]]; then
  # Do not use var wrapped in quotes "${SKIP_TAGS}", it will cause error because of wrapping it with ''
  SKIP_TAGS_OPTION="--skip-tags ${SKIP_TAGS}"
fi

TAGS_OPTION=""
if [[ -n $TAGS ]]; then
  # Do not use var wrapped in quotes "${TAGS}", it will cause error because of wrapping it with ''
  TAGS_OPTION="--tags ${TAGS}"
fi

if ! command -v brew &> /dev/null
then
  echo "Brew is not installed, installing it now..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v ansible &> /dev/null
then
  echo "Ansible is not installed, installing it now..."
  brew install ansible
fi

ansible-playbook -K \
--connection=local \
--inventory 127.0.0.1, \
${SKIP_TAGS_OPTION} \
${TAGS_OPTION} \
--limit 127.0.0.1 playbooks/provision.yml
