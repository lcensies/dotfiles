#!/usr/bin/env bash

git rev-list HEAD | while read sha; do
	git grep -q -e $1 $sha -- $2 && echo $sha
done
