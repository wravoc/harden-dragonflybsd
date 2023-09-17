#!/bin/tcsh -f

# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI 
# License URL: https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html

# Scripting basics
set arguments_number = ${#argv}
set x = 0

while ( $x < $arguments_number )
   @ x = ($x + 1)
   set mode = $argv[$x]
end

set SCRIPTDIRECTORY = `echo $PWD | rev | cut -d'/' -f2- | rev`

# Librewolf Custom Variables
set version = "117.0.1"
set release = "1"

# Librewolf Build Variables
set archive_create = "tar cfz"
set ext = ".tar.gz"
set ff_source_dir = "firefox-$version"
set ff_source_tarball = "firefox-$version.source.tar.xz"
set lw_source_dir = "librewolf-$version-$release"
set lw_source_tarball = "librewolf-$version-$release.source$ext"
setenv MOZBUILD_STATE_PATH "$HOME/.mozbuild"

# Terminal Color set
set green = '\033[0;32m'
set yellow = '\033[1;33m'
set blue = '\033[1;34m'
set magenta = '\033[1;35m'
set cyan = '\033[1;36m'
set white = '\033[0;37m'
set end = '\033[0m'


printf "\n**********************$blue Base Mode $end**********************\n"
printf "$yellow--$end                     Librewolf Setup          $yellow--$end \n"
printf "                         $0 \n"
printf "Version: $version \n"
printf "Release: $release \n"
printf "Hardened Complition: \n"
printf "  -> WebAssembly: None \n"
printf "  -> Telemetry: None \n"
printf "*******************************************************\n\n"


# mach build errors: glean-sdk

# Get Firefox Libraries Installed by DragonFly pkg
# Get GnuPGP for Source verification
pkg install -y firefox gnupg llvm rust nasm py39-clang llvm16
python -m ensurepip --upgrade
cargo install cbindgen
printf "ac_add_options --without-wasm-sandboxed-libraries\n" >> ./mozconfig
printf "ac_add_options --with-system-nspr\n" >> ./mozconfig

# Download and setup in user home
cd
wget -t 3 "https://gitlab.com/api/v4/projects/32320088/packages/generic/librewolf-source/${version}-${release}/librewolf-${version}-${release}.source.tar.gz"
tar -xf librewolf-$version-$release.source.tar.gz
wget --tries=3 "https://keys.openpgp.org/vks/v1/by-fingerprint/14F26682D0916CDD81E37B6D61B7B526D98F0353" -O public_key.asc 
gpg --import public_key.asc
rm -f public_key.asc
wget --tries=3 "https://archive.mozilla.org/pub/firefox/releases/$version/source/firefox-$version.source.tar.xz.asc" -O $ff_source_tarball.asc
wget --tires=3 "https://archive.mozilla.org/pub/firefox/releases/$version/source/firefox-$version.source.tar.xz" -O $ff_source_tarball
gpg --verify $ff_source_tarball.asc $ff_source_tarball
tar -xf $ff_source_tarball
mv $ff_source_dir $lw_source_dir
cd $lw_source_dir 
./mach --no-interactive bootstrap --application-choice=browser
./mach build
cd ..
# ./scripts/setup-wasi-linux.sh