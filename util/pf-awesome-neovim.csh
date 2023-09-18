#!/bin/tcsh -f

# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI 
# License URL: https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html


# Setup pf firewall
pkg update
cp /usr/local/etc/pkg/repos/df-latest.conf.sample /usr/local/etc/pkg/repos/df-latest.conf
set ext_if = `ifconfig -lu | awk '{ print $2 }'`
sed -i .original 's/vio0/'${ext_if}'/g' pf.conf
printf 'pf="YES"\n' >> /etc/rc.conf
printf 'pf_load-"YES"\n' >> /boot/loader.conf
cp pf.conf /etc






# Setup Neovim + Post Reboot
pkg install neovim git

# Lazy.nvim NeoVIM
cp -R ../vendor/lazy /usr/local/share/nvim/runtime
mkdir ~/.config/ && mkdir ~/.config/nvim
cp ../assets/init.lua ~/.config/nvim/

# Set environment and start X
# Capture Error Log: tartx -- -keeptty -nolisten tcp >& $HOME/.xorg.log
# Logout of Awesome: Shift-Windows Keys(Mod)-Q, Ctl-Alt-Del
# "Font Awesome 6 Free" "Font Awesome 6 Free Solid"
sed -i .original 's/vi/nvim/g' ~/.cshrc
pkg install nerd-fonts font-awesome

# Librewolf
# wget https://gitlab.com/librewolf-community/browser/source/-/archive/117.0-1/source-117.0-1.tar -o Librewolf
# tar -zxvf Librewolf
# cd Librewolf && make dir
# 
