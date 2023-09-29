# Hardened Dragonfly BSD Install Manual

### DragonlyBSD Install Notes

* If the Dragonfly pkg manager ever asks to delete everything and install libressl say No!

* You need two FAT32 formatted USB drives, one for the install, the other for this software
  * You can use BalenaEtcher to make your install drive
  * When copying to and from *USB drives* `/mnt` make sure to `cp` *overwrite* with `cp -fR /mnt/harden-dragonflybsd $HOME`
* Use your FAT32 USB drive `mount_msdos /dev/da8s1 /mnt` , `ls /mnt`
* `cp -fR /mnt/harden-dragonflybsd $HOME` the files to root home, using `-f` here to get into the habit.
* Yes, the reboot stratgey is best on a physical laptop! Booting the kernel modules for smoothest operation, for pkg update purposes, and to be in habit, and ready, or already done `kern.securelevel=1`! This will not be needed after setup.
* Always run the script from the repository base directory. Do not go until `util` and run it from there.
* `Fn-K` allows to arrow and PgUp PgDown the console screen. Then `Fn-K` again to release.
* Make sure to "Configure this System"
* Set the time, date, and say yes to UTC clock, set your timezone.
* Skip keyboard map, console font, and screen map
* Add yourself as user during setup with permanent accurate information
  * Fill in the first 4 rows
* Do **NOT** "Configure network interfaces"
* Enter "Set Hostname/Domain"
  * Hostname is your nickname, no special characters, not starting with a number
  * Domain is `localhost`
  * Return to Main Menu, Reboot This Computer
  * Do **NOT** pull out the installation USB drive until "The operating system has halted"
  * Login as root, insert the FAT32 formatted USB drive with this software.
    * You will not see a prompt, that's ok just type  `mount_msdos /dev/da8s1 /mnt`
  * `cp -fR /mnt/harden-dragonflybsd ~`
  * `cd harden-dragonflybsd`
  * `util/thinkpad-t495-setup.csh` , after Success, issue the `reboot` command
  * There are some pkg bugs in DF, if the software `pkg` management systems asks to upgrade or fix missing dependencies then select `y`
    * You may end up running the script twice after an error, this is unfortunately expected
* **Phase 2 setup**
* When you see this message do the following before rebooting:
  * Run this command: `visudo`
  * That will launch the VI editor. VI command for search is `/`
  * Type `/root ALL` <enter|returrn key>, then type `o`, then we're going replicate the line above but instead of using `root` we'll use the actual username you made during setup
  * `your-user-name ALL=(ALL:ALL) ALL`
  * Quit and Write the changes at the same time by typing  `:x`
  * Copy this software from root to your user
    * `sudo cp -fR /root/harden-dragonflybsd /home/<your-user-name>`
    * `sudo chown -R <your-user-name> /home/<your-user-name>/harden-dragonflybsd`
  * Reboot, login with your username, not root, and re-run script to continue setup
  * Run the script again from the repository base directory but use `sudo`
    * `sudo util/thinkpad-t495-setup.csh` Enter your password, not the root password for sudo permissions.
  * From now on you'll need to `sudo util/thinkpad-t495-setup.csh`,  `sudo reboot` , `sudo shutdown -p now`
  * If anything went wrong, just keep running the script!
    * Dragonfly has quirks in the `pkg` system in 6.4 and it will sometimes conflict on openssl - libressl and sometimes will delete everything that depends on them automatically! Do not worry, just run the script again to fix this situation.

### Awesome Window Manger (AwesomeWM)

* Type `startx` to start your desktop
  * Ignore the .Xauthority at first run, this is normal
  * Ignore the .serverauth file does not exist this is normal.
    * Delete them all regularly or change file `/usr/local/bin/startx` directive  to 0`enable_xauth=0`

* If you want to turn off beeps type `xset b off`
* When the terminal starts type `gsettings set io.elementary.terminal.settings font 'Monoid Nerd Font 12'` to match the rest of the theme or whatever Nerd Font you'd like.

* Rarely, the trackpoint will get stuck, simply issue a `reboot` command.

* Windows Key on the keyboard is called the "Mod" key
* Quit a Window `Mod-Shift-C`
* `Mod-R` Start any application, "Run" appears in the top system bar, type the full path to the binary or simply the app name if it's in system path already.
* Terminal Command: `io.elementary.terminal`
* Shutdown `shutdown -p now` command in terminal
* Crash Restart: `Mod-Shift-Q`, `Ctrl-Alt-Backspace` wait 7 seconds, `Ctrl-Alt-Delete`

### Firefox Block

* For security and privacy, the network settings have been changed to block the 110+ servers that Mozilla  uses to track browser activity. 
* It is recommended for the user the setup [NextDNS](https://my.nextdns.io/start) Security to remove ads and malware, not uBlockOrigin.
* **Settings required in the URL** `about:config` **on first run!**
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* **<<<Firefox will render itself inoperative if you do not set these on first run!>>>**
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  * dom.push.connection.enabled `false`
  * dom.push.enabled `false`
  * geo.enabled `false`
  * *(Extra)* intl.regional_prefs.use_os_locales `true`
  * *(Extra)* services.sync.prefs.sync.intl.regional._prefs.use_os_locates `false`

### System Tools

* Pre-Installed Languages
  * NPM + NodeJS

  * Rust

  * Luarocks

* Enhanced Command Lines Tools
  * Enhanced file and directory [find](https://github.com/sharkdp/fd) `fd`
    * Custom `alias` added to your `.zshrc` to not ignore dot files
    * `fd <searchstring> /` to search the whole drive.

  * [Enhanced  grep](https://github.com/BurntSushi/ripgrep) `rg`
    * Find text in files recursively in the current directory. `rg <searchstring> /` to search the whole drive.

* Rust Language `$HOME/.cargo/bin` added to your user `PATH`
* **Quadhelion Engineering Dragonfly Status Dashboard**
  * Just type `dfs` in your shell
    * WiFi Status
    * Current Internet IP Address sourced from the [envs.net](https://envs.net/)
    * Current DNS Server
    * Power type, either from 120v power *adapter* or from the laptop *battery*
    * Battery percentage
      * Alerts with two system beeps and warning icon with less than 10%

    * Current CPU Frequency taking into account sleep states, powerd, AMD ACPI
    * Current average CPU temperate of all CPU cores
      * Alerts with two system beeps and warning icon when above 85%

    * Current CPU utilization
    * Current free memory
    * Current used hard drive space


### Xorg

* There are logged errors for /dev/card0 and Screens not being found.Tthis is normal for the Thinkpad external monitor drivers are not supported
* There are logged errors in system mouse. This is normal and expected when the user disables either the trackpoint or the trackpad in the BIOS.
  * If the mouse does not work in Awesome, then reboot, it happens rarely, cause unknown.
  * Setup best for trackpoint
* There is rarely trackpoint/pad glitching especially when in a new X session. This is just a glitch in Xorg with Trackpoints. All settings were used to reduce this behavior and should only happen very rarely.

### OhMyZsh

* `omz help`, `omz theme <command>`
* Edit `./zshrc` and uncommnet line 74, `export LANG=en_US.UTF-8`
* Create `fd` alias below the examples `alias fd="fd -H"`

* There are uni-code characters present at the prompt when running as root in the system console, this is normal as root account need to the "C" locale and should **not** be changed.

* It may start creating .zcompdump files in your directory because of missing paths used by `compinit` which you can set to explain the dump by locating the below function in `/usr/local/share/ohmyzsh`:

  ```sh
  if [[ "$ZSH_DISABLE_COMPFIX" != true ]] then
  ```

  and adding `-w` to all `compinit` flags to debug or use `-D` instead of `-d` to disable the .compdump. I found no adverse affects from disabling the dump. 

### AstroNvim [*](https://astronvim.com/)

* Use`nvim` command with no file to let it setup, update, then quit `:q!`
* If Treesitter cloning error:
  * `cd ~/.local/share/nvim/lazy/`
  * `rm -rf nvim-treesitter`
  * `git clone https://github.com/nvim-treesitter/nvim-treesitter.git`
* The Dragonfly versions avaible to build with do not properly render some of the Nerd Fonts.
* 
* Update `:AstroUpdatePackages`
* Add a language `:TSInstall ruby`
* Plug-In directory is` ~/.local/share/nvim/lazy`
* Install new language  `:TSInstall rust`
* Update `~/.config/nvim/lua/plugins/telescope.lua` to change the `fzf` in `telescope-fzf-native.nvim` to `fzy` instead of `fzf` and the `vim.fn.executeable` from `make` to `cmake` for both fields

### IRC Client

* Of the dozens of clients available very few still work, `irssi` and `iris-fish`(encryption module) are tested as working

### Abiword

Abiword is useful for viewing Office docs, but it always saves in it's own format `.abw`. You can always type in Asciidoc or Markdown in NVIM, but if you need to convert your Abiword files you can use https://cloudconvert.com/abw-converter or https://www.vertopal.com/en/convert/abw-to-asciidoc for free.

### Quadhelion Engineering Markdown Preview Shell Function

Preview Markdown files in as they would appear in GitHub (with a QHE provided template) in Firefox with auto-generated Table of Contents for faster review. 

**Firefox may throw errors complaining that it cannot get your precise location, ignore!**

Simply type `mdp` in your shell

**Usage:** 
`mdp README.md`

#### Customization

Gives you an HTML copy of your markdown file as well. You can have the `mdp` function remove this file by editing the function.

**File**: `~/.zshrc`

Append the following line at the end of function to delete HTML preview file: 
`rm ${filepath}/${basename_toc}.html`

Append the following line at the end of function to delete Markdown with Table of Contents file:
`rm ${filepath}/${filename_toc}`

*Firefox will automatically open file and show preview until cache refreshed or tab/window despite file deletion.*



#### Markdown Format

QHE `mdp` z shell function uses [MultiMarkdown format](https://fletcherpenney.net/multimarkdown/) `markdown_mmd` which can be [changed](https://pandoc.org/chunkedhtml-demo/8.22-markdown-variants.html#markdown-variants) although this format was heavily tested to be the best:


**Table of Contents Insertion and Format**
`--maxdepth` is set to only recognize` ##` markdown headings `2` but the default is `6`, all subheadings.

The Table of Contents is auto-inserted at the line after the first single `#`, usually the main title of the document. If you wish to insert the TOC yourself remove the statement staring with `printf`
and insert <!-- toc --> inside your markdown document where you would like it to appear before you run the `mdp` command

All changes in this function will not appear until you've exited the terminal and restarted it

The pandoc custom template by Quadhelion Engineering and [Fabrizio Musacchio](https://www.fabriziomusacchio.com) mimicing GitHub Markdown can be modified however you wish.

* /usr/local/share/pandoc/data/templates/qhe-markdown.html

