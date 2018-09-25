# switch-versions
Quick switching between different versions of binary sourced applications

## Applications support is initially intended for:
* packer
* terraform

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
