#!/bin/sh

# This shell script automates the process of releasing a new gem version when
# running ruby in a docker container.

set -x # echo commands as they are executed
sudo chown -R root.root "$HOME/.ssh"
docker run -it --rm -v "$PWD":/usr/src/app -v "$HOME/.gitconfig":/root/.gitconfig -v "$HOME/.ssh":/root/.ssh -v "$HOME/.gem/credentials":/root/.gem/credentials -w /usr/src/app ruby:latest sh -c "bundle install --path vendor/bundle && bundle exec rake release"
sudo chown -R $USER.$USER "$HOME/.ssh"
