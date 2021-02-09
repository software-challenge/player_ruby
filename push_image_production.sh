#!/bin/bash

server=flut
docker build . -t sc-ruby
docker tag sc-ruby localhost:5000/sc-ruby
ssh -M -S ssh-ctrl-socket -fnNT -L 5000:localhost:5000 $server
ssh -S ssh-ctrl-socket -O check $server || exit 1
docker login localhost:5000 || exit 1
docker push localhost:5000/sc-ruby
ssh -S ssh-ctrl-socket -O exit $server
ssh $server 'sudo docker pull localhost:5000/sc-ruby'
ssh $server 'sudo docker tag localhost:5000/sc-ruby sc-ruby'
