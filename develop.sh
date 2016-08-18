#!/bin/sh
set -x # echo commands as they are executed
docker run -it --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:latest /bin/bash
