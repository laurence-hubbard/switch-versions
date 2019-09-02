# switch-versions
Quick switching between different versions of binary sourced applications

## Applications supported:
* packer (specific OS types only for now)
* jq (specific OS types and versions only for now)
* terraform (coming soon)

## Prerequisites
* realpath (`brew install coreutils` on Mac)

## How to run:
* git clone https://github.com/laurence-hubbard/switch-versions.git
* cd switch-versions/
* ./init.sh
* switch-version

### Example: packer
* switch-version packer
* See what latest version is and what current version is (e.g. 0.11.0 and 1.3.1)
* switch-version packer 1.3.1
* Specify OS and OS type, recommendations are made for this.
* Done!

## You can check where a binary is installed using `where`:
https://gist.github.com/laurence-hubbard/13ccb68c5b7225159e03bb85ffd52323

## switch-versions TODO
* Enable non-interactive OS and OS type selections
* Dynamic selection of jq versions
* Support for removing invalid binaries that are in scope PATH but not executable
* Additional OS and OS type support
* Generic functions and easy addition of new applications
