#!/bin/bash
gpg --export-secret-subkeys --export-options export-reset-subkey-passwd -a 2530753C |vagrant ssh -c 'HOME=/root sudo gpg --import'
