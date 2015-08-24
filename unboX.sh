#!/bin/bash

# COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'
# ICONS
SUCCESS="${GREEN}✓${NC}"
FAILED="${RED}✘"


###############################################################################
clear
printf "${GREEN}OS X Environment Configuration Script${NC}\n\n"


###############################################################################
SUDO_NEEDED=$(sudo -n true 2>&1 | wc -l)
if [[ ${SUDO_NEEDED} -gt 0 ]]; then
	printf "Administration rights are needed for this script\n"
	sudo -v -p "Please enter your password: "
	printf "\n"
fi
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


###############################################################################
printf "Fill up some informations:\n"
printf "\tComputer name: "
read COMPUTER_NAME
printf "\tgit username: "
read GIT_USERNAME
printf "\tgit email: "
read GIT_EMAIL
printf "\n"


###############################################################################
xcpath=$(xcode-select -p)
if [[ ! -d $xcpath ]]; then
	printf "Installing XCode command line tools. Press RETURN when done: "
	xcode-select --install > /dev/null 2>~/unboX.log
	read key
	while [[ $key != "" ]]; do
		read key
	done
	xcpath=$(xcode-select -p)

	if [[ -d $xcpath ]]; then
		printf "${SUCCESS}\n"
	else
		printf "${FAILED} (check log: ~/unboX.log)${NC}\n"
		exit -1
	fi
fi


###############################################################################
printf "Checking for SSH keys: "
if [[ -f ~/.ssh/id_rsa && -f ~/.ssh/id_rsa.pub ]]; then
	printf "${SUCCESS}\n"
else
	printf "${FAILED} (Keys not found)${NC}\n"
	exit -1
fi


###############################################################################
printf "Cloning GIT repository: "
[ -d ~/.unboX ] && rm -rf ~/.unboX
git clone -q git@github.com:rsnts/unboX.git ~/.unboX 2> ~/unboX.log
if [ -d ~/.unboX ]; then
	printf "${SUCCESS}\n"
else
	printf "${FAILED} (check log: ~/unboX.log)${NC}\n"
	exit -1
fi


###############################################################################
printf "Computer name configuration: "
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
printf "${SUCCESS}\n"


###############################################################################
printf "Linking bash configuration: "
ln -sf ~/unboX/bash/profile ~/.profile
touch ~/.hushlogin
printf "${SUCCESS}\n"


###############################################################################
printf "Configuring git: "
ln -sf ~/.unboX/git/gitconfig ~/.gitconfig
ln -sf ~/.unboX/git/gitignore_global ~/.gitignore_global
git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_EMAIL
printf "${SUCCESS}\n"


###############################################################################
printf "Configuring vim: "
mkdir -p ~/.vim
ln -sf ~/.unboX/vim/colors ~/.vim/colors
ln -sf ~/.unboX/vim/syntax ~/.vim/syntax
ln -sf ~/.unboX/vim/vimrc ~/.vimrc
printf "${SUCCESS}\n"


###############################################################################
printf "Setting OS X Preferences & System hacks: "
. /osx/preferences.sh
. /osx/hacks.sh
printf "${SUCCESS}\n"


###############################################################################
printf "\nSoftware installation will now start with homebrew\n"
printf "press any key to start"
read key
clear
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap caskroom/cask
brew tap caskroom/versions
brew tap caskroom/fonts

source ~/.unboX/brew/brew.cfg
brew install ${binaries[@]}
brew cask install --appdir="/Applications" ${apps[@]}
brew cask install ${fonts[@]}


###############################################################################
clear
printf "${GREEN}OS X Environment Configuration Script${NC}\n\n"
printf "${ORANGE}Setup done. Restart now${NC}\n"
