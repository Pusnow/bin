#!/bin/sh
gh api "repos/$1/$2/commits" -q ".[0].sha"
