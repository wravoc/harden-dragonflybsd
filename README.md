# Harden DragonFly BSD 

![](images/harden-dragonflybsd-preview.png)

This security script utilizes years of security contributions by the entire BSD community across all spectra and decades of Professional Security Experience to implement what would take an experienced operator an hour or so to harden their system can be done in seconds with backups, logs, syntax checking, and Zenbleed workaround. 

Not only security directives, but any conf directive can be set and re-set with a customizable `settings.ini` suitable for administering and tuning duties. All existing entries in all confs will remain untouched unless they are modified in the settings file.

Each of the security settings was researched, assessed, and chosen as a set of mitigations for maximizing threat reduction while minimizing restriction of system capability and availability to DragonFly BSD.


---

## Main Features

* Makes backups of `rc.conf`, `sysctl.conf`, `login.conf`, and `loader.conf` on first run
* Sets passwords to blowfish encryption
* Sets passwords to expire at 120 days
* Sets default `umask` to 27 (USER all, GROUP rx, OTHER none)
* Disables sendmail completely
* Installs and configures a Firewall
* Removes `other` write permissions from key system files and folders
* Allows only root for `cron` and `at`
* Primitive flag verification catches simple errors
* Modularizable within other tools
* Automate any shell script
* System Logging to `/var/log/messages` and Script Logging to `/var/log/harden-dragonflybsd.log`
* Pretty prints color output of script execution to console while running
* Sets umask to 27

---


## Includes
* Desktop Wallpapers as a special gift to users of the Software
* Directory (Hier)archy Visual Map, PDF, in /docs


---


## New Features in 3.0.1
* ZenBleed Workaround
* CPU microcode updating enabled in anticipation of Zenbleed and Downfall Patches


*Full [Changelog](Changelog.md)*

---

## Addtional Software
* Post-Install complete setup script for Thinkpad T495, T495s
    * Configures WiFI, GPU, Sound, Keyboard, Custom Themed [Awesome](https://awesomewm.org/) Desktop
    * Elementary Terminal, Lazy NeoVIM, Ghostwriter+Pandoc, Claws Email Client, Firefox
    * Download and install to FAT32 formatted USB Drive, Insert after install is complete, make a user account for yourself
    * `mount_msdos /dev/da8s1 mnt`, `cp -fR /mnt/harden-dragonflybsd ~`
    * `cd harden-dragonflybsd`
    * `util/thinkpad-t495-setup.csh`
    * Do NOT run as root for the Desktop Setup! `sudo util/thinkpad-t495-setup.csh`
* Z Shell function/alias/macro for Previewing Markdown files in Firefox `mdp <file.md>`
    * Modify in `~/.zshrc`
* Shell Script to present available sensor information like Battery Life, CPU Temp, HDD Status
    * `vendor/sensors.sh`
    * Script by vermaden@interia.pl https://vermaden.wordpress.com 
    * Copyright (c) 2022-2023 Slawomir Wojciech Wojtczak (vermaden)
    * Copyright (c) 2022 Trix Farrar
* Scripts included to verify the implementation 
**Run before and after the hardening.**
    * Kernel vulnerablity diagnosis provided by [Stéphane Lesimple's](https://github.com/speed47) spectre-meltdown-checker
        * `cd vendor`
        * `chmod 750 spectre-meltdown-checker.sh`
        * `sudo ./spectre-meltdown-checker.sh`
        * You should only be left with the MCEPSC, Machine Check Exception on Page Size Change Vulnerability, [CVE-2018-12207](https://www.freebsd.org/security/advisories/FreeBSD-SA-19:25.mcepsc.asc)
    * MMAP, MProtect vulnerability diagnosis provided by [u/zabolekar](https://www.reddit.com/r/BSD/comments/10isrl3/notes_about_mmap_mprotect_and_wx_on_different_bsd/)
        * `cd util`
        * `cc mmap_protect.c` 
        * `./a.out`
        * You should have two successes


## Zenbleed Workaround
* *I could only do very limited testing on VM's, please submit issues!*
* [Security Engineer's Discovery & Write-Up](https://lock.cmpxchg8b.com/zenbleed.html)
* [Affects AMD Zen 2 Chipset Family](https://nakedsecurity.sophos.com/2023/07/26/zenbleed-how-the-quest-for-cpu-performance-could-put-your-passwords-at-risk/)
* Mitigation/workaround suggested by discovering Security Engineer **will not work in Virtual Machines**
* AMD has patched the Rome family, server oriented series, of CPU's but all others are expected in December of 2023.
* The command to manually verify the chicken-bit has been set is `cpucontrol -m "0xc0011029" /dev/cpuctl0`

### Zenbleed Features
* Sets the Model Specific Register chicken-bit exactly as suggested by the discovering Security Engineer
* Patches the latest AMD microcode from [Platomov's GitHub Repository](https://github.com/platomav/CPUMicrocodes/tree/master/AMD) if available for your Zen2 CPU, currently, only "Rome" series as of August 11, 2023.
* If in a Virtual Machine, check for EPYC Rome series CPU and apply AMD patch and exit if not Rome, as there is no other patch available yet and Hypervisor disallows the workaround.
* Only if a Zenbleed vulnerable CPU is detected a CPU chicken-bit is be set every boot via a provided rc script
* Prompts to make a reminder to remove the script using `at` to create a file called `REMINDER-AMD-Zenbleed-Removal` in home directory on the 2023 December Solstice


### Execute
* `cd util`
* `chmod 750 zenbleed-workaround.csh`
* `sudo ./zenbleed-workaround.csh`

### Arguments
* `./zenbleed-workaround.csh clean` removes the CPU microcode/firmware utilities as a security measure once Zenbleed patching is complete
    * Do not use `clean` if you still need the workaround on baremetal as it uses cpucontrol.
* `./zenbleed-workaround.csh remove` removes the rc script for performance reasons or once the patch is applied from AMD in Decemeber 2023. 
    * In the case of an AMD Zenbleed fully patched CPU, follow `remove` with `clean` for security purposes.


---


## Requirements
* DragonFly BSD 6.4.0
* Python 3.9.16


## Installation

**WARNING: Once kernel level 1 is set by this script, you will not be able to modify these confs again with this script until it is set to -1 and rebooted!**

* Set `kernlevel = -1` if you want to test various setting groups with your applications and network
* Customize `settings.ini`  to whatever is needed, the script will change the directive to your flag
* Set permissions `chmod 750 harden-dragonflybsd.py` to prevent shell injection from another account or process
* Set permissions `chmod 640 settings.ini` to prevent shell injection from another account or process
* No `settings.ini` section can be entirely commented out nor be completely empty
* `sudo ./harden-dragonflybsd.py`


## Conf File Verification

`kern.vty = "vt"`

This script does primitive verification of the confs flags in strict accordance with system man. Many online tutorials even on the FreeBSD family of websites do not use the proper syntax. Check the log for any validation failures. Use proper syntax, remove the syntax checking lines 241-261, or rewrite the regular expression to make a new check suitable for you.

* For `/etc/sysctl.conf` the script checks for no quotes
* For `/boot/loader.conf` the script strictly verifies syntax from man and `/boot/defaults/loader.conf` syntax
    * All directives in these sister confs must be in quotes

If you do get stuck in read-only single-user mode and need to correct a configuration file then use:

```sh
zfs set readonly=false zroot
zfs mount -a
```

## Customization

#### 64bit vs 32bit
Most tunable mitigations for 64bit are already included by default in FreeBSD 13.1 so 32bit directives were included for coverage. I can see no affect from setting the 32bit mitigations on 64bit systems, they are simply ignored. For clarity on unknown hardware, hardware mode, VM, or cloud use the following commands:
* CPU: `sysctl hw.model hw.machine hw.ncpu`
* Bits: `getconf LONG_BIT`


#### Backups

The very first time the script is run it will make copies of `rc.conf`, `sysctl.conf`, `login.conf`, and `loader.conf` named `rc.conf.original` etc. If you've already done this yourself you may want to rename or move those files.

If you would like you can set `settings.ini` section `[SCRIPT]`option `first_run` to `True` with capital `T` to make new backups at any time after you've renamed the original backups or the script will overwrite them.


#### Chmod-ability

The set of files needed to be secure changed and changed throughout testing and so it ended up as a shell command but an error checked function was provided for the administrator programmer to use instead of appending to the long list in `settings.ini` section `[FILESEC]` if you wish or to work with other software.

Those files are:

`etc/ftpusers /etc/group /etc/hosts /etc/hosts.allow /etc/hosts.equiv /etc/hosts.lpd /etc/inetd.conf /etc/login.access /etc/login.conf /etc/newsyslog.conf /etc/rc.conf /etc/ssh/sshd_config /etc/sysctl.conf etc/syslog.conf /etc/ttys /etc/crontab /usr/bin/crontab /usr/bin/at /usr/bin/atq /usr/bin/atrm /usr/bin/batch /var/log`

#### Secure Password Settings

The newly applied settings will not take affect until you reset your password.

---

## Automatic Jail Lockdown/Management Strategies

1. Set the correct paths to jailed confs in `harden-dragonflybsd.py` lines 32-38 and run for each jail.
2. Copy software to `/root` and have jail start this script at reboot and all settings will be updated upon next reboot. To update all jails simply copy `settings.ini` with your own copy script to all appropriate locations for uptake. 

`crontab -e`

`@reboot /path/to/harden-dragonflybsd.py`

3. Have all jails pointing to the same rc script via `exec.start` and set paths in the script pointing to the same location modified by the script paths. 
4. Add new jail specific entires to `settings.ini [SYSTEM]` section for sysctl.conf udpate
   - `security.jail.* = 0`
5. Use mutiple copies of the script and settings.ini for each jail
6. Put it in your template


---


## Setting Descriptors
**Startup**
* `kern_securelevel_enable = "YES"`
    * Enable access to other than permanently insecure modes
* `microcode_update_enable = "YES"`
    * Allow CPU microcode/firmware updates
* Disable Sendmail
* `syslogd_flags="-ss"`
    * Disallow syslogd to bind to a network socket
* `clear_tmp_enable = "YES"`
    * Clear the /tmp directory on reboot
* `icmp_drop_redirect="YES"`
    * Disallow redirection of ICMP (ping, echo)
* `inetd_enable = "NO"`
    * Disallow Network File System to share directories over the network
* `portmap_enable = "NO"`
    * Disallow portmapping since Network File Systems is disallowed
* `update_motd = "NO"`
    * Disallow computer system details from being added to /etc/motd on system reboot
* `pf="YES"`
    * Allow pf firewall

**System**

* `kern.securelevel = 1` [(*)](https://man.freebsd.org/cgi/man.cgi?securelevel)
    * The system immutable and system append-only flags may
	   not be turned off; disks for	mounted	file systems, /dev/mem and
	   /dev/kmem may not be	opened for writing; /dev/io (if	your platform
	   has it) may not be opened at	all; kernel modules (see kld(4)) may
	   not be loaded or unloaded.  The kernel debugger may not be entered
	   using the debug.kdb.enter sysctl.  A	panic or trap cannot be	forced
	   using the debug.kdb.panic, debug.kdb.panic_str and other sysctl's.
* `kern.randompid = 107` [(*)](https://wiki.freebsd.org/DevSummit/201308/Security)
    * Force kernel to randomize process ID's using above salt value instead of sequential
* `net.inet.ip.random_id = 1`
    * Randomize IP packet ID
* `net.inet.ip.redirect = 0` 
    * Disallow ICMP host redirects
* `net.inet.tcp.always_keepalive = 0`
    * Disallow keeping open idle TCP connections
* `net.inet.tcp.blackhole = 2` +(UDP)[(*)](https://man.freebsd.org/cgi/man.cgi?query=blackhole)
    * Packets that are received on a closed port will not initiate a reply
* `net.inet.tcp.path_mtu_discovery = 0` [(*)](https://man.freebsd.org/cgi/man.cgi?query=tcp&sektion=4)
    * Disallows TCP to determine the minimum MTU size on any network that is currently in the path between two hosts
* `net.inet.icmp.drop_redirect = 1`
    * Pairs with rc.conf startup, as once enabled, it is then set
* `kern.chroot_allow_open_directories = 0`
    * Disallow a process to chroot if it has a directory open


**Kernel**
* `pf_load = "YES"`
    * Enable Firewall
* `security.bsd.allow_destructive_dtrace = "0"`
    * Disallow DTrace to terminate proccesses
    * Test DTrace hardening: Using all 3 commands should result in `Permission denied` or `Destructive actions not allowed`:
    * `dtrace -wn 'tcp:::connect-established { @[args[3]->tcps_raddr] = count(); }'`
    * `dtrace -wqn tick-1sec'{system("date")}'`
    * `dtrace -qn tick-1sec'{system("date")}'`
* `hw.ibrs_disable = "3"` [(*)](https://wiki.freebsd.org/SpeculativeExecutionVulnerabilities)
    * Prevent Spectre and Meltdown CPU Vulnerabilities, 3 for AUTO
* `kern.elf32.aslr.stack = "3"` [(*)](https://wiki.freebsd.org/AddressSpaceLayoutRandomization)
    * Address space layout randomization is used to increase the difficulty of performing a buffer overflow attack
    * 64bit is enabled by default in 13.2 so you can set this to 0 for 64bit processors or remove
* `kern.elf32.aslr.pie_enable = "1"`
    * Enable ASLR for Position-Independent Executables (PIE) binaries
* `kern.elf64.pie_base_mmap - "1"`



---


## License Summary

### Software
Non-Commercial usage, retain and forward author and license data. Modify existing code as needed up to 25% while allowing unlimited new additions. The Software may use or be used by other software.


### Digital Art
All Original Digital Artists recieve automatic Copyright. 
* Supplemental License [here](digital%20art/Quadhelion%20Engineering%20Universal%20Digital%20Art%20License.md)


## Security Guidelines

Since this Software uses shell commands it is required to place it in a secure directory with permissions on the **parent** directory to have no permissions for `other` /all/world group to write or *execute* and **no network access**. 

Please follow [these guidelines](/docs/SECURITY.md) should you find a vulnerability not addressed in the audit.


## Statement of Security: 

* **Risk** - Low
* **Impact** - Medium

This script has no networking, accesses no sockets, and uses only standard libraries.

Although this script is using `subprocess.run(shell=True)` the only possibility of shell injection is from the paths customized by the Licensee or unauthorized access to the filesystem the script resides on in order to perform unauthorized modifications to `settings.ini`or the Software which is not a vulnerability of the Software. 


### Latest Development Version

[Quadhelion Engineering Code Repository](https://got.quadhelion.engineering)



![quadhelion engineering logo](images/quadhelionEngineeringIcon.jpg)