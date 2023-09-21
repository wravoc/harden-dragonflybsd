# Hardened Dragonfly BSD Install Notes



### Awesome Window Manger (AwesomeWM)

* Windows Key on the keyboard is called the "Mod" key
* Quit a Window `Mod-Shift-C`
* `Mod-R` Start any application
* Terminal Command: `io.elementary.terminal`
* Shutdown `shutdown -p now` command in terminal

### System Tools

* Enhanced file and directory find `fd`
  * Find recursively in the current directory. `fd searchstring /` to search the whole drive.
* Enhanced  grep `rg`
  * Find recursively in the current directory. `rg searchstring /` to search the whole drive.

### Xorg

* There are logged errors for /dev/card0 and Screens not being found.Tthis is normal for the Thinkpad external monitor drivers are not supported
* There are logged errors in system mouse. This is normal and expected when the user disables either the trackpoint or the trackpad in the BIOS.
  * Setup best for trackpoint
* There is rarely trackpoint/pad glitching especially when in a new X session. This is just a glitch in Xorg with Trackpoints. All settings were used to reduce this behavior and should only happen very rarely.

### OhMyZsh

* There are uni-code characters present at the prompt when running as root in the system console, this is normal as root account need to the "C" locale and should **not** be changed.

* It may start creating .zcompdump files in your directory because of missing paths used by `compinit` which you can set to explain the dump by locating the below function in `/usr/local/share/ohmyzsh`:

  ```sh
  if [[ "$ZSH_DISABLE_COMPFIX" != true ]] then
  ```

  and adding `-w` to all `compinit` flags to debug or use `-D` instead of `-d` to disable the .compdump. I found no adverse affects from disabling the dump. 

### LazyVim

* There is a bug with Mason Language Server Protocol using `lua_ls` in Dragonfly BSD as an unsupported OS
  * Run NVIM and Update mutiple times, then perform `:checkhealth`
    * Run inside `nvim` the command 
      * `:MasonUninstall shfmt`
      * `:MasonUninstall stylua`
  * `cd ~/.local/share/nvim/lazy/mason-lspconfig.nvim/stylual.toml`
    * set to disabled
  * `cd ~/.local/share/nvim/lazy/mason-lspconfig.nvim/.cbfmt.toml`
    * delete lua = ["stylua -s -"']
  * `mappings/filetype.lua` delete lua = { "lua_ls"},
  * `Mappings/server.lua` delete line of ["lua_ls"] = "language-server",
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