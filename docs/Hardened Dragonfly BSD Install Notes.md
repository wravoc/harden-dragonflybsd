# Hardened Dragonfly BSD Install Notes

### DragonlyBSD Install Notes

* Yes, the reboots are needed to boot the new pkg into the kernel for smoothest operation!

* `Fn-K` allows to arrow and PgUp PgDown the console screen. Then `Fn-K` again to release.

* Make sure to "Configure this System"
* Add yourself as user during setup with permanent accurate information
* Do **NOT** "Configure network interfaces"
* Enter "Set Hostname/Domain"
  * Hostname is your nickname, no special characters, not starting with a number
  * Domain is `localhost`
  * Skip keyboard map, console font, and screen map
  * Return to Main Menu, Reboot This Computer
  * Do **NOT** pull out the installation USB drive until "The operating system has halted"
  * Login as root, insert the FAT32 formatted USB drive with this software.
    * You will not see a prompt, that's ok just type  `mount_msdos /dev/da8s1 /mnt`
  * `cp -fR /mnt/harden-dragonflybsd ~`
  * `cd harden-dragonflybsd`
  * `util/thinkpad-t495-setup.csh` , after Success, issue the `reboot` command
* **Phase 2 setup**
* When you see this message, after the pkg system if fixed and Phase 2 message appears
  * You must continue installing the script as a non-root user who will use the desktop
  * Run this command: `visudo`
  * We are in VI editor. VI command for search is `/`
  * Type `/root ALL <enter key>` then type `o`, then we're going replicate the line above but instead of using `root` we'll use our actual username you made during setup
  * `your-user-name ALL=(ALL:ALL) ALL`
  * Reboot, login with your username, not root and re-run script to continue setup
    * `sudo cp -R /root/harden-dragonflybsd ~`
    * `sudo util/thinkpad-t495-setup.csh` Enter your password, not root password.
  * From now on you'll need to `sudo reboot` `sudo shutdown -p now`

### Awesome Window Manger (AwesomeWM)

* **Do NOT run the desktop portion of the installer as root!** `sudo thinkpad-t495-setup.csh`

* Rarely, the trackpoint will get stuck, simply issue a `reboot` command.

* Windows Key on the keyboard is called the "Mod" key
* Quit a Window `Mod-Shift-C`
* `Mod-R` Start any application
* Terminal Command: `io.elementary.terminal`
* Shutdown `shutdown -p now` command in terminal
* Crash Restart: `Mod-Shift-Q`, `Ctrl-Alt-Backspace` wait 7 seconds, `Ctrl-Alt-Delete`

### Firefox Block

* For security and privacy, the network settings have been changed to block the 110+ servers that Mozilla  uses to track browser activity. 
* It is recommended for the user the setup [NextDNS](https://my.nextdns.io/start) Security to remove ads and malware, not uBlockOrigin.

### System Tools

* Use your FAT32 USB drive `mount_msdos /dev/da8s1 /mnt` , `ls /mnt`

* Enhanced file and directory [find](https://github.com/sharkdp/fd) `fd`
  * Defaults to find recursively in the current directory, ignoring dot files.
    * Fix in the OhMyZsh section.
  * `fd searchstring /` to search the whole drive.
* [Enhanced  grep](https://github.com/BurntSushi/ripgrep) `rg`
  * Find recursively in the current directory. `rg searchstring /` to search the whole drive.
* Rust Language `cargo` on `PATH`
* Quadhelion Engineering Dragonfly Status Dashboard `dfs`
  * Alias to zsh script that print in terminal:
    * WiFi Status
    * Current Internet IP Address sourced from the [envs.net](https://envs.net/)
    * Current DNS Server
    * Power type, either from 120v power adapter or from the laptop battery
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

* `nvim` let is setup, update, then quit `:q!`
* Fix Treesitter cloning error:
  * `cd ~/.local/share/nvim/lazy/`
  * `rm -rf nvim-treesitter`
  * `git clone https://github.com/nvim-treesitter/nvim-treesitter.git`
* The Dragonfly versions avaible to build with do not properly render some of the Nerd Fonts.
* Update `~/.config/nvim/lua/plugins/telescope.lua` to change the `fzf` in `telescope-fzf-native.nvim` to `fzy` and the `vim.fn.executeable` from `make` to `cmake`
* Update `:AstroUpdatePackages`
* Add a language `:TSInstall ruby`
* Plug-In directory is` ~/.local/share/nvim/lazy`
* Install new language  `:TSInstall rust`

### IRC Client

* Of the dozens of clients available very few still work, `irssi` and `iris-fish`(encryption module) are tested as working

### Markdown Preview Shell Function `mdp`

Preview Markdown files in Firefox with auto-generated Table of Contents for faster review
Usage: 
`mdp README.md`

#### Customization

File `~/.zshrc`

Append the following line at the end of function to delete HTML preview file: 
`rm ${filepath}/${basename_toc}.html`

Append the following line at the end of function to delete Markdown with Table of Contents file:
`rm ${filepath}/${filename_toc}`

*Firefox will automatically open file and show preview until cache refreshed or tab/window despite file deletion.*



#### Markdown Format

Function uses [MultiMarkdown format](https://fletcherpenney.net/multimarkdown/) `markdown_mmd` which can be changed although this format was heavily tested to be the best:
https://pandoc.org/chunkedhtml-demo/8.22-markdown-variants.html#markdown-variants

**Table of Contents Insertion and Format**
`--maxdepth` is set to only recognize` ##` markdown headings `2` but the default is `6`, all subheadings.

The Table of Contents is auto-inserted at the line after the first single `#`, usually the main title of the document. If you wish to insert the TOC yourself remove the statement staring with `printf`
and insert <!-- toc --> inside your markdown document where you would like it to appear before you run the `mdp` command

All changes in this function will not appear until you've exited the terminal and restarted it

The pandoc export uses a custom template by Quadhelion Engineering and Fabrizio Musacchio (https://www.fabriziomusacchio.com) to mimic GitHub Markdown and can be modified however you wish.