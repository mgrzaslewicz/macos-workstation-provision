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

ansible-playbook -K \
--connection=local \
--inventory 127.0.0.1, \
${SKIP_TAGS_OPTION} \
${TAGS_OPTION} \
--limit 127.0.0.1 playbooks/provision.yml
