#!/bin/tsch -f

# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI 
# License URL: https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html

# Primary Target: Dragonfly BSD 6.4
# Secondary Target: FreeBSD 13.2

# System Requirements: Laptop with AMD CPU with Integrated GPU, Intel Wireless

# Terminal Color set
set green = '\033[0;32m'
set yellow = '\033[1;33m'
set blue = '\033[1;34m'
set magenta = '\033[1;35m'
set cyan = '\033[1;36m'
set white = '\033[0;37m'
set red = '\033[1;31m'
set end = '\033[0m'

# Environment variables
set SCRIPTDIRECTORY = `echo $PWD | rev | cut -d'/' -f1- | rev`
set SUDO_USER_HOME = `echo $PWD | rev | cut -d'/' -f2- | rev`
set SUDO_USER = `echo $PWD | rev | cut -d'/' -f2 | rev`

printf "\n******************$blue Theme Install $end**********************\n"
printf "*******************************************************\n\n"

# Setup AwesomeWM 
pkg install -y awesome elementary-terminal ohmyzsh claws-mail abiword hs-pandoc gnupg neofetch gmake
cp /usr/local/share/ohmyzsh/templates/zshrc.zsh-template $SUDO_USER_HOME/.zshrc
wget -P $SUDO_USER_HOME https://luarocks.org/releases/luarocks-3.9.2.tar.gz
cd $SUDO_USER_HOME
tar zxpf luarocks-3.9.2.tar.gz -C $SUDO_USER_HOME
cd $SUDO_USER_HOME/luarocks-3.9.2
./configure
cd -
make -C $SUDO_USER_HOME/luarocks-3.9.2 -f $SUDO_USER_HOME/luarocks-3.9.2/Makefile
sleep 3
make install -C $SUDO_USER_HOME/luarocks-3.9.2
sleep 3
cp -fR ${SCRIPTDIRECTORY}/assets/awesome $SUDO_USER_HOME/.config
cp -fR ${SCRIPTDIRECTORY}/assets/fonts.conf /usr/local/etc/X11/xorg.conf.d/
cp -fR ${SCRIPTDIRECTORY}/assets/40-trackpoint.conf /usr/local/etc/X11/xorg.conf.d/
cp -fR ${SCRIPTDIRECTORY}/util/dfs.sh $SUDO_USER_HOME


# Setup NeoVIM
pkg install -y neovim git nerd-fonts font-awesome ripgrep fd-find lazygit unzip gzip fzy
git clone --depth 1 https://github.com/AstroNvim/AstroNvim $SUDO_USER_HOME/.config/nvim
rm -rf $SUDO_USER_HOME/.local/share/nvim/lazy/nvim-treesitter
rm $SUDO_USER_HOME/.local/share/nvim/lazy/nvim-treesitter.cloning
git clone https://github.com/nvim-treesitter/nvim-treesitter.git $SUDO_USER_HOME/.local/share/nvim/lazy/nvim-treesitter
sed -i .original 's/mvim/nvim/g' $SUDO_USER_HOME/.zshrc
sed -i .original 's/fzf/fzy/g' $SUDO_USER_HOME/.config/nvim/lua/plugins/telescope.lua
sed -i .original2 's/make/cmake/g' $SUDO_USER_HOME/.config/nvim/lua/plugins/telescope.lua

# Setup z shell function & alias to preview Markdown files in Firefox and run Dragonfly Status Script
pkg install -y npm rust firefox libuv libnghttp2
npm install -g markdown-toc
printf 'PATH=$PATH:${SUDO_USER_HOME}/.cargo/bin; export PATH\n' >> $SUDO_USER_HOME/.profile
cargo install fzyr
printf 'alias dfs="~/dfs.sh"\n' >> $SUDO_USER_HOME/.zshrc
printf 'alias fd="fd -H"\n' >> $SUDO_USER_HOME/.zshrc 
printf 'alias rg="rg --no-messages"\n' >> $SUDO_USER_HOME/.zshrc
cat ${SCRIPTDIRECTORY}/assets/mdp.zsh >> $SUDO_USER_HOME/.zshrc
cp ${SCRIPTDIRECTORY}/assets/qhe-markdown.html /usr/local/share/pandoc/data/templates/
printf "\nexport LANG=en_US.UTF-8\n" >> $SUDO_USER_HOME/.zshrc
printf "export charset=UTF-8\n" >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_RUNTIME_DIR=/var/run/$USER-runtime\n' >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_CONFIG_HOME=$HOME/.config\n' >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_DATA_HOME=$HOME/.local/share\n' >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_STATE_HOME=$HOME/.local/state\n' >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_CACHE_HOME=$HOME/.cache\n' >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_DATA_DIRS=/usr/local/share/:/usr/share/\n' >> $SUDO_USER_HOME/.zshrc
printf 'export XDG_CONFIG_DIRS=/etc/xdg\n' >> $SUDO_USER_HOME/.zshrc
printf "export XKB_DEFAULT_RULES=xorg\n" >> $SUDO_USER_HOME/.zshrc
chsh -s zsh $SUDO_USER



# Clean Up
printf "\n*****************$green  Cleaning Up  $end***********************\n"
printf "Pkg system check, clean, audit\n"
printf "*******************************************************\n\n"
rm -rf $SUDO_USER_HOME/luarocks-3.9.2.tar.gz
rm -rf $SUDO_USER_HOME/luarocks-3.9.2

# Set ownership and perms
chown $SUDO_USER $SUDO_USER_HOME/.xinitrc
chown $SUDO_USER $SUDO_USER_HOME/.zshrc
chown $SUDO_USER $SUDO_USER_HOME/dfs.sh
chown $SUDO_USER /usr/local/share/pandoc/data/templates
chown -R $SUDO_USER $SUDO_USER_HOME/.config
chown $SUDO_USER /var/run/${SUDO_USER}-runtime
chown -R $SUDO_USER $SUDO_USER_HOME/harden-dragonflybsd
chown -R $SUDO_USER $SUDO_USER_HOME/.local
chmod 750 $SUDO_USER_HOME/.xinitrc
chmod -R 740 $SUDO_USER_HOME/harden-dragonflybsd
chmod 750 $SUDO_USER_HOME/dfs.sh
/usr/bin/gsettings set io.elementary.terminal.settings font 'Monoid Nerd Font 12'


# Pkg system clean
pkg clean
pkg check -Bda


# End
printf "\n***************$green  Setup complete  $end**********************\n"
printf "Reboot, startx, and enjoy!\n"
printf "*******************************************************\n\n"

