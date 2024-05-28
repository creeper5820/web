#!/bin/bash

cd /workspaces/web/blog
hexo clean 
hexo g 
scp -r public root@10.31.2.44:/data/creeper5820/