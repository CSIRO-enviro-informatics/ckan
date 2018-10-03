#!/bin/bash
fusermount -u ../../local_code/ckan_src || true
fusermount -u ../../local_code/ckan_entrypoint || true
fusermount -u ../../local_code/ckan_config || true
mkdir -p ../../local_code/ckan_config
mkdir -p ../../local_code/ckan_src
mkdir -p ../../local_code/ckan_entrypoint
ssh-keygen -f ~/.ssh/known_hosts -R "[localhost]:9222" > /dev/null 2>&1 || true
sshfs -o ControlMaster=auto -o StrictHostKeyChecking=no -p 9222 root@localhost:/ckan_src  ../../local_code/ckan_src
sshfs -o ControlMaster=auto -o StrictHostKeyChecking=no -p 9222 root@localhost:/ckan_entrypoint ../../local_code/ckan_entrypoint
sshfs -o ControlMaster=auto -o StrictHostKeyChecking=no -p 9222 root@localhost:/ckan_config ../../local_code/ckan_config
