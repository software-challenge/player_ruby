#!/bin/bash
# This creates a entrypoint for the gem named 'software_challenge_client.rb'
# which includes all ruby files under lib. Making sure that everthing is
# included after some files were added or removed (in the process of updating
# the gem for a new game).
shopt -s globstar || exit 1
cd lib || exit 1
FILENAME='software_challenge_client.rb'

echo "# frozen_string_literal: true
module SoftwareChallengeClient" > $FILENAME
for file in software_challenge_client/**/*.rb; do
    echo "  require '${file}'"
done >> $FILENAME;
echo "end" >> $FILENAME
