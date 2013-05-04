#!/bin/sh

# mode: 0 - both, 1 - tab, 2 - title
mode=2
title=$1
echo "\033]$mode;$title\007\c"
