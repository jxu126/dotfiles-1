#!/bin/bash

#get the directly of where this script is run, and consequently where the files are located
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

cd $SCRIPTPATH

#warn if they already have one of the .bak files that exists
if [[  -e ~/.tmux.conf.bak || -e ~/.tmux.reset.conf.bak \
    || -e ~/.tmux.colors.conf.bak || -e ~/.tmux.system.conf.bak \
    || -e ~/.zshrc.bak || -e ~/.vimrc.local.bak \
    || -e ~/.dircolors.bak ]]; then
    echo "Warning! one or more *.bak files exist in your home directory that may get overwritten!"
    read -p "Continue? [y/n]" yn
    while true; do
        case $yn in
            [Yy]* )
                break
                ;;
            [Nn]* )
                exit
                ;;
            * )
                read -p "Please answer yes or no. [y/n]" yn
                ;;
        esac
    done
fi

#init and update if we haven't already
echo Updating submodules...
git submodule init
git submodule update

function backupIfNotSymlink() {
    if [[ -L $1 ]]; then
        rm -v $1
    elif [[ -e $1 ]]; then
        mv -v -f $1 $1.bak
    fi
}

#remove symlinks if they exist or backup file
backupIfNotSymlink ~/.tmux.conf
backupIfNotSymlink ~/.tmux.reset.conf
backupIfNotSymlink ~/.tmux.colors.conf
backupIfNotSymlink ~/.tmux.system.conf
backupIfNotSymlink ~/.zshrc
backupIfNotSymlink ~/.zshrc.system
backupIfNotSymlink ~/.vimrc.local
backupIfNotSymlink ~/.dircolors

#make the new symlinks
ln -v -s $SCRIPTPATH/tmux.conf ~/.tmux.conf
ln -v -s $SCRIPTPATH/tmux.reset.conf ~/.tmux.reset.conf
ln -v -s $SCRIPTPATH/tmux-colors-solarized/tmuxcolors-256.conf ~/.tmux.colors.conf
#TODO: replace with .vimrc shouldn't depend upon spf13
ln -v -s $SCRIPTPATH/vimrc ~/.vimrc.local
ln -v -s $SCRIPTPATH/zshrc ~/.zshrc
ln -v -s $SCRIPTPATH/dircolors-solarized/dircolors.ansi-dark ~/.dircolors

#these two files depend upon system type
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    ln -v -s $SCRIPTPATH/tmux.linux.conf ~/.tmux.system.conf
    ln -v -s $SCRIPTPATH/zshrc.linux ~/.zshrc.system
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ln -v -s $SCRIPTPATH/tmux.mac.conf ~/.tmux.system.conf
    ln -v -s $SCRIPTPATH/zshrc.mac ~/.zshrc.system
fi

#create the local changes files if they don't exist
touch ~/.tmux.local.conf
touch ~/.zshrc.local
