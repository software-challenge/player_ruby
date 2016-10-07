#!/bin/sh
set -x # echo commands as they are executed
docker run -it --rm -p 8808:8808 -v "$PWD":/usr/src/app -w /usr/src/app ruby:latest /bin/bash
