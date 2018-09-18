#! /bin/bash

APP_NAME=$(basename $0)

APPS=( "packer" )

log(){

DATE=$(date +%F\ %T)

if [ $# -eq 1 ]; then
	echo "$DATE $APP_NAME INFO - $1"
else
	echo "$DATE $APP_NAME $1 - $2"
fi

}

containsElement () {
# Usage:
# if containsElement "packer" "${APPS[@]}"; then
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

help() {

log "Applications available for switching are:"
for APP in "${APPS[@]}"
do
	echo $APP
done
}

error() {
if [ "$1" == "NotEnoughArgs" ]; then
	log ERROR "$1: $2"
	help
elif [ $# -eq 2 ]; then
	log ERROR "$1: $2"
else
	log ERROR "$1"
fi

exit 1
}

versions_packer() {

CURRENT_VERSION="$(packer --version 2>/dev/null)"
CURRENTLY_INSTALLED=$?

if [ $CURRENTLY_INSTALLED -eq 0 ]; then
	log "Currently installed packer version is: $CURRENT_VERSION"
else
	log "packer is not currently installed"
fi

LATEST_VERSION="$(wget https://releases.hashicorp.com/packer/ -O /dev/stdout 2>/dev/null | grep packer | cut -d '/' -f3 | sort -n | tail -1)"
LATEST_VERSION_AVAILABLE=$?

if [ $LATEST_VERSION_AVAILABLE -eq 0 ]; then
        log "Latest packer version is: $LATEST_VERSION"
else
        error "packer is not currently available for switching -- releases.hashicorp.com may be down"
fi

}

versions() {

APP="$1"

if [ "$APP" == "packer" ]; then
        versions_packer
	exit 0
else
        error "NotImplementedYet" "Switch functionality for $APP not yet available"
fi

}

setup() {
APP="$1"
log "Setting up $APP_NAME"
sudo mkdir -p "/var/lib/$APP_NAME/$APP/"
}

switch_packer(){
VERSION="$1"
log "Switching packer to version $VERSION"
setup packer

DESIRED_INSTALL_LOCATION="/usr/local/bin/packer"

log "**INTERACTIVE** Which OS? Options are:
macOS
FreeBSD
Linux
OpenBSD
Solaris
Windows
"
read WHICH_OS

log "**INTERACTIVE** What OS type? Options are:
32-bit
64-bit
Arm
Arm64
Ppc64le
"
read WHICH_BITS

if [ "$WHICH_OS" == "macOS" ] && [ "$WHICH_BITS" == "64-bit" ]; then
	OS="darwin"
	BITS="amd64"
	log "Installing packer $VERSION for $OS $BITS"
else
	error "OS $WHICH_OS with type $WHICH_BITS is not currently supported for packer"
fi

log "Checking if packer is currently installed"
CURRENT_INSTALL_LOCATION="$(which packer)"
CURRENTLY_INSTALLED=$?

if [ $CURRENTLY_INSTALLED -eq 0 ]; then
	log "packer is currently installed at: $CURRENT_INSTALL_LOCATION"
	CURRENT_VERSION="$(packer --version 2>/dev/null)"
	log "moving current packer to an archive location in /var/lib/$APP_NAME/packer"
	sudo mkdir -p "/var/lib/$APP_NAME/packer/archive/$OS/$BITS/$CURRENT_VERSION/"
        if [ -f "/var/lib/$APP_NAME/packer/archive/$OS/$BITS/$CURRENT_VERSION/packer" ]; then
		sudo mv "$CURRENT_INSTALL_LOCATION" "/var/lib/$APP_NAME/packer/archive/$OS/$BITS/$CURRENT_VERSION/packer.$(date +%F\ %T | sed "s/[- :]//g")"
	else
		sudo mv "$CURRENT_INSTALL_LOCATION" "/var/lib/$APP_NAME/packer/archive/$OS/$BITS/$CURRENT_VERSION/packer"
	fi
	log "Resetting bash path hash to confirm uninstall"
	hash -r
else
        log "packer is not currently installed"
fi

log "Checking if packer version $VERSION is available in cache"
if [ -f "/var/lib/$APP_NAME/packer/cache/$OS/$BITS/$VERSION/packer" ]; then
	log "packer is available in cache. running symlinking to confirm"
	sudo ln -s "/var/lib/$APP_NAME/packer/cache/$OS/$BITS/$VERSION/packer" "$DESIRED_INSTALL_LOCATION"
else
	log "packer is not available in cache. downloading"
	sudo mkdir -p "/var/lib/$APP_NAME/packer/cache/$OS/$BITS/$VERSION/"
	pushd "/var/lib/$APP_NAME/packer/cache/$OS/$BITS/$VERSION/"
	sudo wget "https://releases.hashicorp.com/packer/${VERSION}/packer_${VERSION}_${OS}_${BITS}.zip"
	sudo unzip packer_${VERSION}_${OS}_${BITS}.zip
	sudo ln -s "/var/lib/$APP_NAME/packer/cache/$OS/$BITS/$VERSION/packer" "$DESIRED_INSTALL_LOCATION"
	popd
fi

log "Checking if packer was installed as expected"

CURRENT_VERSION="$(packer --version 2>/dev/null)"
CURRENTLY_INSTALLED=$?

if [ $CURRENTLY_INSTALLED -eq 0 ]; then
        log "Currently installed packer version is: $CURRENT_VERSION"
else
        error "packer was not installed as expected - $APP_NAME has failed"
fi

if [ "$CURRENT_VERSION" == "$VERSION" ]; then
        log "packer version $VERSION installed as expected"
else
	error "packer was not installed as expected - $APP_NAME has failed"
fi

}

switch() {

APP="$1"
VERSION="$2"

if [ "$APP" == "packer" ]; then
        switch_packer "$VERSION"
else
        error "NotImplementedYet" "Switch functionality for $APP not yet available"
fi

}

if [ $# -eq 0 ]; then
	error "NotEnoughArgs" "Please provide the application you wish to switch to."
elif [ $# -eq 1 ]; then
	versions "$1"
elif [ $# -eq 2 ]; then
	switch "$1" "$2"
fi

# TO-DO
# Ability to switch between versions of terraform
# https://releases.hashicorp.com/terraform/0.7.5/

# Ability to install switch-version from GitHub (housed by volleymaster)
# Automatic placement of switch-version into PATH
# Easy upgrading

# Ability to save configurations like OS and OS-type (e.g. Linux 64 bit) locally & dynamically
# Ability to deliver configurations like OS and OS-type via arguments

# Support for things like "What's the latest version?" "What's the current version?" "What applications are in scope?"
# switch-version --help

# Support for quitting the app if the current version is same as requested version?!?