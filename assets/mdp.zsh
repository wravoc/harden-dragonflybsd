# Quadhelion Engineering
# elias@quadhelion.engineering
# https://www.quadhelion.engineering
#
# (m)ark(d)own (p)review
#
## Preview Markdown file in Firefox ##
# Usage: 
# $> mdp README.md
# 
## Customization ##
# Append the following line at the end of function to delete HTML preview file: 
# rm ${filepath}/${basename_toc}.html
#
# Append the following line at the end of function to delete Markdown with Table of Contents:
# rm ${filepath}/${filename_toc}
#
# ** Firefox will show preview until cache refreshed or tab/window despite file deletion.
# 
### Markdown Format
# Currently uses MultiMarkdown format which can be changed:
# https://pandoc.org/chunkedhtml-demo/8.22-markdown-variants.html#markdown-variants
# "gfm" for GitHub Flavored Markdown
#
#### Table of Contents Insertion and Format
# --maxdepth is set to only recognize ## markdown headings (2) but the default is 6, all subheadings.
# Table of Contents of inserted at the line after the a single #, usually the main title of the document
# If you wish to insert the TOC yourself remove the statement staring with "printf"
# and insert <!-- toc --> where you would like it to appear before you run the command
# 
# All changes in this function will not appear until you've exited the terminal and restarted it

function mdp() {
        realpath=`realpath $1`
        filepath=`dirname $realpath`
        basename=`basename $1 .md`
        basename_toc=${basename}-toc
        filename_toc=${basename_toc}.md
        cp -f $1 $filename_toc
        printf '%s\n' /'#'/a '<!-- toc -->' . w q | ex -s $filename_toc
        markdown-toc --maxdepth 2 -i $filename_toc
        pandoc $filename_toc -f markdown_mmd -t html5 -s -o "${basename_toc}.html" --metadata title="${basename}" --template=qhe-markdown.html
        firefox file://${filepath}/${basename_toc}.html
}

