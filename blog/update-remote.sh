#!/bin/bash

cd /workspaces/web/blog
hexo clean 
hexo g 
scp -P 410 -r ./public root@47.122.22.22:/data/creeper5820/