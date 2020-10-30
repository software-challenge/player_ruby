#!/bin/bash
cd lib
FILENAME='software_challenge_client.rb'

echo "# frozen_string_literal: true
module SoftwareChallengeClient" > $FILENAME
cd software_challenge_client
FILES=$(find . -type f -name "*.rb")
echo -n "$FILES" | tac -s' '
cd ..
for filename in $FILES; do
    if [ $(expr length "$filename") -gt 1 ]; then
        echo "  require './lib/software_challenge_client${filename:1}'" >> $FILENAME;
    fi
done
echo "end" >> $FILENAME