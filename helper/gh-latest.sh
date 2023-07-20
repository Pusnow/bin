#!/bin/sh
gh api "repos/$1/$2/releases/latest" -q .tag_name
