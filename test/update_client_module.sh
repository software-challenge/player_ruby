#!/bin/bash
# This creates a entrypoint for the gem named 'software_challenge_client.rb'
# which includes all ruby files under lib. Making sure that everthing is
# included after some files were added or removed (in the process of updating
# the gem for a new game).
shopt -s globstar || exit 1
FILENAME='software_challenge_client.rb'

if [ $(pwd | grep -o '[^/]*$') != test ] 
then
    echo "Please execute me in the test folder"
    exit 1
fi

printf "# frozen_string_literal: true\n
module SoftwareChallengeClient\n" > $FILENAME
for file in ../lib/software_challenge_client/**/*.rb; do
    echo "  require '${file:1}'"
done >> $FILENAME;
echo "end" >> $FILENAME
