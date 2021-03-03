#!/bin/bash

which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    echo "homebrew not installed"
    echo "consider:"
    echo 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    exit 1
fi
# Ask for the administrator password upfront
sudo -v
# Make sure we’re using the latest Homebrew.
brew update
# Upgrade any already-installed formulae.
brew upgrade
apps=(
    git
    "gnu-sed --with-default-names"
	tmux
	wget
	zsh
    vim
    coreutils
    micro
)
for app in "${apps[@]}"; do
    echo brew install "$app"
    brew install "$app"
done
# Remove outdated versions from the cellar.
brew cleanup

ZSH=$HOME/.oh-my-zsh
echo " -- oh my zsh -- "
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ssh-keyscan github.com >> /tmp/githubKey
echo "$(ssh-keygen -lf /tmp/githubKey)"  >> ~/.ssh/known_hosts
# zsh-autosugesstions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
#0i0 theme
rm -rf ~/.oh-my-zsh/themes
git clone git@github.com:0i0/0i0.zsh-theme.git ~/.oh-my-zsh/themes

cd "$(dirname "${BASH_SOURCE}")"
git init
git remote add origin git@github.com:0i0/dotfiles.git
git fetch --all
git reset --hard origin/master
git pull --recurse-submodules origin master
git submodule update --init --recursive

echo "linking"
# Symlink dotfiles
for file in $(ls -A); do
if [ "$file" != ".git" ] && \
   [ "$file" != "setup.sh" ] && \
   [ "$file" != "remote-setup.sh" ] && \
   [ "$file" != "README.md" ] && \
   [ "$file" != "images" ]; then
    rm ${HOME}/${file} 2 & >/dev/null
    ln -sf $PWD/$file $HOME/
fi
done

# symlink .config dir
/usr/local/opt/coreutils/libexec/gnubin/cp -as $PWD/.config/ $HOME

# alacritty
git clone git@github.com:0i0/0i0-alacritty.git ~/.0i0-alacritty
cd ~/.0i0-alacritty
./install.sh
cd ..

git clone git@github.com:0i0/banana-blueberry-themes.git ~/.banana-blueberry-themes
cd ~/.banana-blueberry-themes
ln -sf $PWD/micro/bananablueberry.micro $HOME/.config/micro/colorschemes/bananablueberry.micro

grep -Fq "export SHELL=zsh" $HOME/.bashrc && echo "zsh already default" || cat >> $HOME/.bashrc << EndOfMessage
if [[ \$- == *i* ]]; then
    export SHELL=zsh
    zsh -l
fi
EndOfMessage

chsh -s /bin/zsh $USER