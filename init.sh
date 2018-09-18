#! /bin/bash

DIR=$(dirname $(realpath ./switch-version.sh))

pushd $DIR

echo "Attempting git refresh"
git pull

if [ -L /usr/local/bin/switch-version ]; then
	echo "Deleting previous switch-version"
	sudo rm /usr/local/bin/switch-version
fi

sudo ln -s $DIR/switch-version.sh /usr/local/bin/switch-version

popd
