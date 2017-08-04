#!/bin/bash
gpg --export-secret-subkeys --export-options export-reset-subkey-passwd -a xxxxx |vagrant ssh -c 'HOME=/root sudo gpg --import'
