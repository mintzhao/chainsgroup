#!/usr/bin/env bash

set -x;

docker images | grep none | xargs docker rmi -f
docker build -t flarum . && docker save flarum -o flarum.tar
chmod 777 flarum.tar
