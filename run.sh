#!/bin/sh

# Always name current branch here. To check if version == your_current_branch, run
# git branch
version=check_setting

curl --silent --location https://github.com/modc08/nectar-shell/archive/$version.tar.gz | tar xzvf -

cd nectar-shell-*

./setup.sh

# should not reach this point

/sbin/poweroff
