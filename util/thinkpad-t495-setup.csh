#!/bin/tcsh -f

# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI 
# License URL: https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html

# Primary Target: Dragonfly BSD 6.4
# Secondary Target: FreeBSD 13.2

# System Requirements: Laptop with AMD CPU with Integrated GPU, Intel Wireless
# Primary Target: Thinkpad T495(s)

# Terminal Color set
set green = '\033[0;32m'
set yellow = '\033[1;33m'
set blue = '\033[1;34m'
set magenta = '\033[1;35m'
set cyan = '\033[1;36m'
set white = '\033[0;37m'
set end = '\033[0m'

set SCRIPTDIRECTORY = `echo $PWD | rev | cut -d'/' -f2- | rev`
set wirelessdriver = `grep -m1 iwm9260fw_load /boot/loader.conf`
set wlan = `grep -m1 wlans_iwm0 /etc/rc.conf`
set netcheck = `ifconfig -lu | awk '{ print $2 }'`
set pkgcheck = `pkg info wget | grep -m1 Name | awk '{ print $3 }'`
set awesomecheck = `pkg info awesome | grep -m1 Name | awk '{ print $3 }'`

# Change Prompt
# To remove 24h Time delete: %T-
sed -i .original '26s/.*/\tset prompt = "%T-%{\\033[0;32m%}%N%{\\033[0m%}-%{\\033[1;37m%}%C2%{\\033[0m%}-> "/' ${HOME}/.cshrc
sed -i .original '27s/.*//' ${HOME}/.cshrc

if ( $wirelessdriver == 'iwm9260fw_load="YES"' && $pkgcheck == "") then
    printf "\n********************$blue Network 2 $end************************\n"
    printf "Continuing Network Setup\n"
    printf "*******************************************************\n\n"
    goto network2
else if ( $pkgcheck == "wget" && ! -e /usr/local/lib/xorg ) then
    printf "\n*********************$blue Desktop $end*************************\n"
    printf "Starting Desktop Setup\n"
    printf "*******************************************************\n\n"
    goto xorg
else if ( -e /usr/local/lib/xorg ) then
    printf "\n********************$blue Desktop 2 $end************************\n"
    printf "Finalizing Desktop Setup\n"
    printf "*******************************************************\n\n"
    goto xorgfix
else if ( $awesomecheck  == "awesome") then
    printf "\n********************$blue Desktop 3 $end************************\n"
    printf "Installing Desktop Theme\n"
    printf "*******************************************************\n\n"
    goto theme
else
    printf "\n********************$blue Base Mode $end************************\n"
    printf "$yellow--$end     Thinkpad T495 Setup for Dragonfly BSD 6.4 $yellow--$end \n"
    printf "*******************************************************\n\n"
endif

# Setup Network
printf "\n*******************$blue Network Set $end***********************\n"
printf "*******************************************************\n\n"
printf 'if_iwm_load="YES"\n' >> /boot/loader.conf
printf 'iwm9260fw_load="YES"\n' >> /boot/loader.conf
printf 'wlans_iwm0="wlan0"\n' >> /etc/rc.conf
printf 'ifconfig_wlan0="WPA DHCP"\n' >> /etc/rc.conf
cd ..
cp assets/wpa_supplicant.conf /etc
cd -
printf "$blue Enter Wireless Network Name:$end \n"
set ssid = $<
printf "$blue Enter Wireless Network Password:$end \n"
set psk = $<
sed -i .original 's/qhe-ssid/'${ssid}'/g' /etc/wpa_supplicant.conf
sed -i .original 's/qhe-psk/'${psk}'/g' /etc/wpa_supplicant.conf

# Install Basic Firewall
cp /usr/local/etc/pkg/repos/df-latest.conf.sample /usr/local/etc/pkg/repos/df-latest.conf
set ext_if = `ifconfig -lu | awk '{ print $2 }'`
sed -i .original 's/vio0/'${ext_if}'/g' pf.conf
printf 'pf="YES"\n' >> /etc/rc.conf
printf 'pf_load-"YES"\n' >> /boot/loader.conf
cp pf.conf /etc
cat ${SCRIPTDIRECTORY}/assets/denyhosts >> /etc/hosts

printf "\n**********************$green Success $end************************\n"
printf "Reboot and re-run script to continue \n"
printf "*******************************************************\n\n"
exit 0


network2:
printf "\n*********************$blue Checking $end************************\n"
printf "*******************************************************\n\n"
sleep 5
if ( $netcheck == "wlan0" ) then
    printf "\n**********************$green Success $end************************\n"
    printf "Network Connected\n"
    printf "*******************************************************\n\n"
else
    printf "**********************$magenta Error $end**************************\n"
    printf "Check password, router WPA2/3, Reboot\n"
    printf "*******************************************************\n\n"
    exit 1
endif


printf "\n*******************$blue Fix pkg bug $end***********************\n"
printf "Answer y[yes] to all \n"
printf "*******************************************************\n\n"
pkg update
sleep 2
printf "\n******************$blue Reseting Repo $end**********************\n"
printf "*******************************************************\n\n"
sleep 2
cp /usr/local/etc/pkg/repos/df-latest.conf.sample /usr/local/etc/pkg/repos/df-latest.conf
sleep 2
printf "\n******************$blue Repo Reset $end*************************\n"
printf "*******************************************************\n\n"
sleep 2
pkg update -f
sleep 2
pkg update openssl
sleep 2
pkg install wget curl
sleep 2
set pkgcheck = `pkg info wget | grep -m1 Name | awk '{ print $3 }'`
if ( $pkgcheck == "wget" ) then
    printf "\n***********************$green Success $end**************************\n"
    printf "Package system fixed\n"
    printf "Reboot and re-run script to continue \n"
    printf "*******************************************************\n\n"
else
    printf "**********************$magenta Error $end**************************\n"
    printf "Possible Network Problem or Pkg Conflict, re-run script\n"
    printf "*******************************************************\n\n"
endif
exit


# Setup Awesome Window Manager for AMD Thinkpads
xorg:

# Sound
printf "\n*******************$blue Sounds Set $end************************\n"
printf "*******************************************************\n\n"
printf 'snd_hda_load="YES"\n' >> /boot/loader.conf
printf "\n**********************$green Success $end************************\n"
printf "Sound Enabled\n"
printf "*******************************************************\n\n"


## TODO: Fix Power Meter, Set wallpaper
printf "\n*******************$blue Desktop Set $end************************\n"
printf "*******************************************************\n\n"
pw groupmod video wheel -m ${USER}

# Setup XDG environment
setenv XDG_RUNTIME_DIR /var/run/${USER}-runtime
# setenv XDG_CONFIG_HOME ${HOME}/.config 
# setenv XDG_DATA_HOME ${HOME}/.local/share 
# setenv XDG_STATE_HOME ${HOME}/.local/state
# setenv XDG_CACHE_HOME ${HOME}/.cache
# setenv XDG_DATA_DIRS /usr/local/share/:/usr/share/
# setenv XDG_CONFIG_DIRS /etc/xdg
# setenv XKB_DEFAULT_RULES xorg

printf 'setenv XDG_RUNTIME_DIR /var/run/${USER}-runtime\n' >> ~/.cshrc
printf 'setenv XDG_CONFIG_HOME ${HOME}/.config\n' >> ~/.cshrc
printf 'setenv XDG_DATA_HOME ${HOME}/.local/share\n' >> ~/.cshrc
printf 'setenv XDG_STATE_HOME ${HOME}/.local/state\n' >> ~./cshrc
printf 'setenv XDG_CACHE_HOME ${HOME}/.cache\n' >> ~/.cshrc
printf 'setenv XDG_DATA_DIRS /usr/local/share/:/usr/share/\n' >> ~/.cshrc
printf 'setenv XDG_CONFIG_DIRS /etc/xdg\n' >> ~/.cshrc
printf 'setenv XKB_DEFAULT_RULES xorg\n' >> ~/.cshrc

mkdir $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR
cp ${SCRIPTDIRECTORY}/assets/.xinitrc ~
touch ~/.Xauthority
chmod 700 ~/.Xauthority
printf 'xhost si:localuser:'${USER}'' >> ~/.Xauthority


# Install Xorg Desktop
printf 'kern.evdev.rcpt_mask=6\n' >> /etc/sysctl.conf
printf 'dbus_enable="YES"\n' >> /etc/rc.conf
printf 'hald_enable="YES"\n' >> /etc/rc.conf
printf 'kld_list="radeonkms"\n' >> /etc/rc.conf
pkg install -y xorg xf86-video-ati
set pkgcheck = `pkg info xorg | grep -m1 Name | awk '{ print $3 }'`
if ( $pkgcheck == "xorg" ) then
    printf "\n**********************$green Success $end************************\n"
    printf "Reboot and re-run script to continue \n"
    printf "*******************************************************\n\n"
else   
    printf "**********************$magenta Error $end**************************\n"
    printf "Possible Network Problem or Pkg Error, Reboot, re-run\n"
    printf "*******************************************************\n\n"
endif
sleep 2
exit 0


# Fix Xorg install keyboard device settings overwrite, setup tooling
# Themes in /usr/local/share/awesome/themes
xorgfix:
mkdir -p ~/.config/awesome
printf "\n*******************$blue Desktop Fix $end***********************\n"
printf "*******************************************************\n\n"
pkg install awesome xf86-input-libinput xf86-video-amdgpu elementary-terminal
cp /usr/local/etc/xdg/awesome/rc.lua ~/.config/awesome


set pkgcheck = `pkg info awesome | grep -m1 Name | awk '{ print $3 }'`
if ( $pkgcheck == "awesome" ) then
    printf "\n***************$green Desktop Complete $end**********************\n"
    printf "Reboot and re-run script to continue\n"
    printf "*******************************************************\n\n"
else
    printf "**********************$magenta Error $end**************************\n"
    printf "Possible Network Problem or Pkg Error, Reboot, re-run\n"
    printf "*******************************************************\n\n"
endif
exit 0


theme:
printf "\n******************$blue Theme Install $end***********************\n"
printf "*******************************************************\n\n"

# Setup AwesomeWM 
pkg install -y elementary-terminal gmake ohmyzsh claws-mail abiword hs-pandoc gnupg
cp /usr/local/share/ohmyzsh/templates/zshrc.zsh-template ~/.zshrc
chsh -s zsh
gsettings set io.elementary.terminal.settings font 'Monoid Nerd Font 12'
wget https://luarocks.org/releases/luarocks-3.9.2.tar.gz
tar zxpf luarocks-3.9.2.tar.gz
cd luarocks-3.9.2
./configure && make && sudo make install
cp -fR ${SCRIPTDIRECTORY}/assets/awesome ~./config
cp -fR ${SCRIPTDIRECTORY}/assets/fonts.conf /usr/local/etc/X11/xorg.conf.d/
cp -fR ${SCRIPTDIRECTORY}/assets/40-trackpoint.conf /usr/local/etc/X11/xorg.conf.d/
sed -i .original 's/^default.*/& \n\t:charset=UTF-8:\\/' /etc/login.conf
sed -i .original 's/^default.*/& \n\t:lang=en_US.UTF-8:\/' /etc/login.conf

# Setup NeoVIM
cd
pkg install -y neovim git nerd-fonts font-awesome ripgrep fdfind lazygit unzip gzip
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
cd
sed -i .original 's/mvim/nvim/g' ~/.zshrc

# Setup z shell alias to preview Markdown files in Firefox
pkg install -y npm-node18-9.5.0
npm install -g markdown-toc
cat ${SCRIPTDIRECTORY}/assets/mdp.zsh >> ~./zshrc
cp ${SCRIPTDIRECTORY}/assets/qhe-markdown.html /usr/local/share/pandoc/data/templates/


# Fix LazyVim
cd ~/.local/share/nvim/lazy/nvim/nvim-treesiter
git config --system core.longpaths true
git restore --source=HEAD :/
git pull
cd

# Clean Up
printf "\n*****************$green  Cleaning Up  $end***********************\n"
printf "Pkg system check, clean, audit\n"
printf "*******************************************************\n\n"
pkg check -Bda
pkg autoremove
pkg clean
pkg audit -Fr


# End
printf "\n***************$green  Setup complete  $end**********************\n"
printf "Reboot, startx, and enjoy!\n"
printf "*******************************************************\n\n"


