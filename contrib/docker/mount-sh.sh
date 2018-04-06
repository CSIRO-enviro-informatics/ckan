#!/bin/bash
fusermount -u ../../local_code/ckan_src || true 
fusermount -u ../../local_code/ckan_entrypoint || true
fusermount -u ../../local_code/ckan_config || true
mkdir -p ../../local_code/ckan_config
mkdir -p ../../local_code/ckan_src
mkdir -p ../../local_code/ckan_entrypoint
sshfs root@localhost:/ckan_src -p 9222 ../../local_code/ckan_src
sshfs root@localhost:/ckan_entrypoint -p 9222 ../../local_code/ckan_entrypoint
sshfs root@localhost:/ckan_config -p 9222 ../../local_code/ckan_config
