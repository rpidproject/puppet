#!/bin/bash
gpg --export-secret-subkeys --export-options export-reset-subkey-passwd -a AD9793634FC0755D |vagrant ssh -c 'HOME=/root sudo gpg --import'
