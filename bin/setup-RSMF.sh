#!/usr/bin/env bash
#
# Install RSMF from GitHub and setup local symlinks into /etc, /usr/lib, etc.
#
# TODO: make this script smarter by checking if RSMF is already installed and
#       doing a git pull to upgrade instead.
# TODO: only create jsonnet symlink if jsonnet is not already present

export RSMF_SRC_REPO_URL=https://github.com/shah/rdbms-schema-migration-framework
export RSMF_HOME="${RSMF_HOME:-/opt/rdbms-schema-migration-framework}"

sudo apt install make git jq

sudo mkdir -p $RSMF_HOME
sudo git clone $RSMF_SRC_REPO_URL $RSMF_HOME
sudo chmod +x $RSMF_HOME/bin/*
sudo ln -s $RSMF_HOME/bin/rsmf-init /usr/bin/rsmf-init
sudo ln -s $RSMF_HOME/bin/rsmf-make /usr/bin/rsmf-make
sudo ln -s $RSMF_HOME/bin/jsonnet-v0.11.2 /usr/bin/jsonnet

cd $RSMF_HOME/lib/$RSMF_COMPONENT_NAME
make check-dependencies