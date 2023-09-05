#!/bin/tcsh -f

# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
# https://got.quadhelion.engineering
# License: QHELP-OME-NC-ND-NAI 
# License URL: https://www.quadhelion.engineering/QHELP-OME-NC-ND-NAI.html


set ext_if = `ifconfig -lu | awk '{ print $2 }'`
sed -i .original 's/vio0/'${ext_if}'/g' pf.conf
cp pf.conf /etc
pfctl -e