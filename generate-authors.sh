#!/bin/bash
# Thanks to the docker project!
# https://github.com/docker/docker/blob/2c224e4fc09518d33780d818cf74026f6aa32744/hack/generate-authors.sh
set -e

# change to the directory where the script is located, this should be the project root
pushd "$(dirname "$(readlink -f "$BASH_SOURCE")")/"

# see also ".mailmap" for how email addresses and names are deduplicated

{
	cat <<-'EOH'
	# This file lists all individuals having contributed content to the repository.
	# For how it is generated, see `generate-authors.sh`.
	EOH
	echo
	git log --format='%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf
} > AUTHORS
popd
