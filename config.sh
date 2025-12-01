#!/usr/bin/env bash

# CONSTANTS
declare -r DIR_USER_HOME=$(eval echo ~$USER)
declare -r DIR_USER_CONFIG=$DIR_USER_HOME/.config
declare -r DIR_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
declare -r ZSH_CUSTOM=$DIR_USER_HOME/.oh-my-zsh/custom

# default option values
OPTION_DEBUG=false

# check if debug is enabled
for parameter in "$@"
do
  case $parameter in

    -d | --debug)
      printf 'debug has been enabled\n'
      OPTION_DEBUG=true
      ;;

    *)
      printf "option '$parameter' is unknown\n"
      exit 1
      ;;
  esac
done

# ask for sudo permission
sudo -v
if [[ "$(sudo id -u)" -ne 0 ]]; then
  printf 'This script must be run with sudo\n'
fi

# stow all config files
cd $DIR_SCRIPT/dotfiles
stow --target $DIR_USER_HOME *
cd $DIR_SCRIPT

# zsh als Standardshell
sudo chsh -s $(which zsh) $USER

# Fonts runterladen
yay -S --noconfirm ttf-meslo-nerd-font-powerlevel10k

# oh-my-zsh installieren
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) -y"

# oh-my-zsh plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# oh-my-zsh themes
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
