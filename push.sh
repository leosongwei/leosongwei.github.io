#!/bin/sh

sbcl --load rssgen.lisp
git commit -am "build rss.xml before push"
git push
