#!/bin/sh
gh api "repos/$1/$2/git/refs/tags" -q .[-1].ref.[10:]
