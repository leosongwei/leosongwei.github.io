#!/bin/sh

sbcl --load rssgen.lisp
git commit -am "build rss.xml and readme.md before push"
git push
