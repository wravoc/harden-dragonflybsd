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

# Environment variables
set SCRIPTDIRECTORY = `echo $PWD | rev | cut -d'/' -f1- | rev`
set SUDO_USER_HOME = `echo $PWD | rev | cut -d'/' -f2- | rev`
set SUDO_USER = `echo $PWD | rev | cut -d'/' -f2 | rev`

# Driver checks
set wirelessdriver = `grep -m1 iwm9260fw_load /boot/loader.conf`
set wlan = `grep -m1 wlans_iwm0 /etc/rc.conf`

# Networking checks
set ifconfig_check = `ifconfig -lu | awk '{ print $2 }'`
set router_check = `ifconfig wlan0 | grep status | awk '{ print $2 }'`
if ( $ifconfig_check == "wlan0"  &&  $router_check == "associated" ) then
    set netcheck = "up"
else
    set netcheck = "down"
endif


# Change Prompt
# To remove 24h Time delete: %T-
sed -i .original '26s/.*/\tset prompt = "%T-%{\\033[0;32m%}%N%{\\033[0m%}-%{\\033[1;37m%}%C2%{\\033[0m%}-> "/' ${HOME}/.cshrc
sed -i .original '27s/.*//' ${HOME}/.cshrc


# Get the install stages
if ( $wirelessdriver == 'iwm9260fw_load="YES"' && ! -e /usr/local/bin/wget ) then
    printf "\n**********************$blue Network 2 $end**********************\n"
    printf "Continuing Network Setup\n"
    printf "*******************************************************\n\n"
    goto network2
else if ( -e /usr/local/bin/wget && ! -d /usr/local/lib/xorg ) then
    printf "\n*********************$blue Desktop $end*************************\n"
    printf "Starting Desktop Setup\n"
    printf "$magenta Ctrl-C to CANCEL if running as root! $end\n"
    printf "*******************************************************\n\n"
    goto xorg
else if ( -d /usr/local/lib/xorg  && ! -e /usr/local/libexec/libinput ) then
    printf "\n********************$blue Desktop 2 $end************************\n"
    printf "Finalizing Desktop Setup\n"
    printf "*******************************************************\n\n"
    goto xorgfix
else if ( -e /usr/local/libexec/libinput ) then
    printf "\n********************$blue Desktop 3 $end************************\n"
    printf "Installing Desktop Theme\n"
    printf "*******************************************************\n\n"
    goto theme
else
    printf "\n********************$blue Base Mode $end************************\n"
    printf "$yellow--$end     Thinkpad T495 Setup for Dragonfly BSD 6.4     $yellow--$end \n"
    printf "*******************************************************\n\n"
endif

# Setup Network
printf "\n*******************$blue Network Set $end***********************\n"
printf "*******************************************************\n\n"
# Sound drivers must be loaded first, Dragonfly bug
printf 'snd_hda_load="YES"\n' >> /boot/loader.conf
printf 'if_iwm_load="YES"\n' >> /boot/loader.conf
printf 'iwm9260fw_load="YES"\n' >> /boot/loader.conf
printf 'wlans_iwm0="wlan0"\n' >> /etc/rc.conf
printf 'ifconfig_wlan0="WPA DHCP"\n' >> /etc/rc.conf
cp ${SCRIPTDIRECTORY}/assets/wpa_supplicant.conf /etc
printf "$blue Enter Wireless Network Name:$end \n"
set ssid = $<
printf "$blue Enter Wireless Network Password:$end \n"
set psk = $<
sed -i .original 's/qhe-ssid/'${ssid}'/g' /etc/wpa_supplicant.conf
sed -i .original 's/qhe-psk/'${psk}'/g' /etc/wpa_supplicant.conf
printf "name_servers=208.67.222.222" >> /etc/resolvconf.conf


# Install Basic Firewall
cp $SCRIPTDIRECTORY/assets/pf.conf /etc
sed -i .original 's/vio0/wlan0/g' /etc/pf.conf
printf 'pf="YES"\n' >> /etc/rc.conf
printf 'pf_load="YES"\n' >> /boot/loader.conf
cat ${SCRIPTDIRECTORY}/assets/denyhosts >> /etc/hosts

printf "\n**********************$green Success $end************************\n"
printf "Reboot and re-run script to continue \n"
printf "*******************************************************\n\n"
exit 0


network2:
printf "\n***********************$blue Checking $end**********************\n"
printf "*******************************************************\n\n"
if ( $netcheck == "up" ) then
    printf "\n**********************$green Success $end************************\n"
    printf "Network Connected\n"
    printf "*******************************************************\n\n"
else
    printf "**********************$magenta Error $end**************************\n"
    printf "Check password, router WPA2/3, Reboot\n"
    printf "*******************************************************\n\n"
    exit 1
endif


printf "\n*********************$blue Fix pkg bug $end*********************\n"
printf "Answer y[yes] to all \n"
printf "*******************************************************\n\n"
pkg update
sleep 4
pkg update
sleep 2
printf "\n********************$blue Reseting Repo $end********************\n"
printf "*******************************************************\n\n"
# rm  /usr/local/etc/pkg.conf
pkg upgrade
sleep 2
cp /usr/local/etc/pkg/repos/df-latest.conf.sample /usr/local/etc/pkg/repos/df-latest.conf
pkg check -Bda
printf "\n*********************$blue Repo Reset $end**********************\n"
printf "*******************************************************\n\n"
sleep 2
pkg install -y wget curl sudo python nghttp2
sleep 2
set wget_check = `pkg info wget | grep -m1 Name | awk '{ print $3 }'`
pkg check -Bda
sleep 6
if ( $wget_check == "wget" ) then
    printf "\n**********************$green Success $end***********************\n"
    printf "Package system fixed\n"
    printf "      $magenta PHASE 2 $end\n"
    printf "Two things must be done here and now\n"
    printf "1. You must allow your real user account to sudo\n"
    printf "2. Copy this software over to your user account from root\n"
    printf "The manual has instructions on how to allow sudo\n"
    printf "Reboot, login with normal user account, and re-run script\n"
    printf "*******************************************************\n\n"
else
    printf "\n********************$magenta Error $end*************************\n"
    printf "Pkg system error or network problem, re-run script\n"
    printf "*******************************************************\n\n"
endif
exit 0


# Setup Awesome Window Manager for AMD Thinkpads
xorg:

# Sound
printf "\n*******************$blue Sounds Set $end************************\n"
printf "*******************************************************\n\n"
printf 'hw.snd.default_unit=3\n' >> /etc/sysctl.conf
printf "\n**********************$green Success $end************************\n"
printf "Sound Enabled\n"
printf "*******************************************************\n\n"
sleep 2


printf "\n*******************$blue Desktop Set $end************************\n"
printf "*******************************************************\n\n"
printf 'acpi_ibm_load="YES"\n' >> /boot/loader.conf
sleep 2

# Setup XDG environment
printf 'setenv XDG_RUNTIME_DIR /var/run/$USER-runtime\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XDG_CONFIG_HOME $HOME/.config\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XDG_DATA_HOME $HOME/.local/share\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XDG_STATE_HOME $HOME/.local/state\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XDG_CACHE_HOME $HOME/.cache\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XDG_DATA_DIRS /usr/local/share/:/usr/share/\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XDG_CONFIG_DIRS /etc/xdg\n' >> $SUDO_USER_HOME/.cshrc
printf 'setenv XKB_DEFAULT_RULES xorg\n' >> $SUDO_USER_HOME/.cshrc
mkdir /var/run/${SUDO_USER}-runtime
chmod 700 /var/run/${SUDO_USER}-runtime
cp ${SCRIPTDIRECTORY}/assets/.xinitrc $SUDO_USER_HOME
# touch $SUDO_USER_HOME/.Xauthority
# chmod 700 $SUDO_USER_HOME/.Xauthority
# printf 'xhost si:localuser:'${USER}'' >> $SUDO_USER_HOME/.Xauthority


# Install Xorg Desktop
printf 'kern.evdev.rcpt_mask=6\n' >> /etc/sysctl.conf
printf 'dbus_enable="YES"\n' >> /etc/rc.conf
printf 'hald_enable="YES"\n' >> /etc/rc.conf
printf 'kld_list="radeonkms"\n' >> /etc/rc.conf
pkg install -y xorg xf86-video-ati lua54
set xorg_check = `pkg info xorg | grep -m1 Name | awk '{ print $3 }'`
if ( $xorg_check == "xorg" ) then
    printf "\n***********************$green Success $end**********************\n"
    printf "Reboot and re-run script to continue \n"
    printf "*******************************************************\n\n"
else   
    printf "**********************$magenta Error $end**************************\n"
    printf "Possible Pkg error or network problem, re-run\n"
    printf "*******************************************************\n\n"
endif
sleep 2
exit 0


# Fix Xorg install keyboard device settings overwrite, setup tooling
# Themes in /usr/local/share/awesome/themes
xorgfix:
pw groupmod wheel -m ${SUDO_USER}
pw groupmod video -m ${SUDO_USER}
mkdir -p $SUDO_USER_HOME/.config/awesome
printf "\n*******************$blue Desktop Fix $end***********************\n"
printf "*******************************************************\n\n"
pkg install -y xf86-input-libinput



set libinput_check = `pkg info xf86-input-libinput | grep -m1 Name | awk '{ print $3 }'`
if ( -e /usr/local/libexec/libinput ) then
    printf "\n********************$green Fix Complete $end*********************\n"
    printf "Reboot and re-run script to continue\n"
    printf "*******************************************************\n\n"
else
    printf "**********************$magenta Error $end**************************\n"
    printf "Possible Network Problem or Pkg Error, Reboot, re-run\n"
    printf "*******************************************************\n\n"
endif
exit 0


theme:
printf "\n******************$blue Theme Install $end**********************\n"
printf "*******************************************************\n\n"

# Setup AwesomeWM 
pkg install -y awesome elementary-terminal ohmyzsh claws-mail abiword hs-pandoc gnupg neofetch gmake
cp /usr/local/share/ohmyzsh/templates/zshrc.zsh-template $SUDO_USER_HOME/.zshrc
gsettings set io.elementary.terminal.settings font 'Monoid Nerd Font 12'
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

sed -i .original 's/mvim/nvim/g' $SUDO_USER_HOME/.zshrc

# Setup z shell function & alias to preview Markdown files in Firefox and run Dragonfly Status Script
pkg install -y npm libuv libnghttp2 rust firefox
npm install -g markdown-toc
printf 'PATH=$PATH:${SUDO_USER_HOME}/.cargo/bin; export PATH\n' >> $SUDO_USER_HOME/.profile
cargo install fzyr
printf 'alias dfs="dfs.sh"\n' >> $SUDO_USER_HOME/.zshrc
printf 'alias fd="fd -H"\n' >> $SUDO_USER_HOME/.zshrc 
cat ${SCRIPTDIRECTORY}/assets/mdp.zsh >> $SUDO_USER_HOME/.zshrc
cp ${SCRIPTDIRECTORY}/assets/qhe-markdown.html /usr/local/share/pandoc/data/templates/
sed -i .original 's/\/bin\/tcsh/\/usr\/local\/bin\/zsh/g' /etc/passwd


# Clean Up
printf "\n*****************$green  Cleaning Up  $end***********************\n"
printf "Pkg system check, clean, audit\n"
printf "*******************************************************\n\n"
rm -rf $SUDO_USER_HOME/.config/nvim/.git
rm -rf $SUDO_USER_HOME/luarocks-3.9.2.tar.gz
rm -rf $SUDO_USER_HOME/luarocks-3.9.2

# Set ownership and perms
chown $SUDO_USER $SUDO_USER_HOME/.zshrc
chown $SUDO_USER $SUDO_USER_HOME/dfs.sh
chown $SUDO_USER /usr/local/share/pandoc/data/templates
chown -R $SUDO_USER $SUDO_USER_HOME/.config
chown $SUDO_USER /var/run/${SUDO_USER}-runtime
chown -R $SUDO_USER $SUDO_USER_HOME/harden-dragonflybsd
chmod -R 740 $SUDO_USER_HOME/harden-dragonflybsd
chmod 750 $SUDO_USER_HOME/dfs.sh


# Pkg system clean
pkg clean
pkg check -Bda


# End
printf "\n***************$green  Setup complete  $end**********************\n"
printf "Reboot, startx, and enjoy!\n"
printf "*******************************************************\n\n"


