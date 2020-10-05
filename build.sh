#!/bin/bash

sbcl --load rssgen.lisp

git add README.md
git add rss.xml
git add tags.md

