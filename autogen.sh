#!/bin/sh

echo "Generating configuration files..."
echo

autoupdate
autoreconf -i
autoheader
