#!/bin/bash

if [ $1 ]
then
	COMMIT_MSG=$1
else
	COMMIT_MSG="build rss.xml and readme.md before push"
fi

sbcl --load rssgen.lisp
git commit -am "$COMMIT_MSG"
git push
