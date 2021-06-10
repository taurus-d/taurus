#!/usr/bin/env sh
dmd -unittest -debug -g -betterC -I=$HOME/.dub/packages/localimport-1.3.0/localimport/source -I=$HOME/.dub/packages/sumtype-1.1.2/sumtype/src -I=source -i -run testsbetterc/*
