#!/bin/sh

OLDVAR=/opt/nethack/nethack.alt.org/dgldir
OLDPLAYGROUND=/opt/nethack/nethack.alt.org/nh500/var
NEWVAR=/opt/dgamelaunch/var
SHORTNAME=nh500
cp -r "$OLDVAR/inprogress-$SHORTNAME" "$OLDVAR/userdata" "$OLDVAR/dgamelaunch.db" "$NEWVAR/"
rm -rf $NEWVAR/$SHORTNAME/*
cp -r $OLDPLAYGROUND/* "$NEWVAR/$SHORTNAME/"
chown -R games:games "$NEWVAR"

