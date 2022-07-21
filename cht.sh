#! /bin/bash

# List languages and replace spaces with new lines
languages=`printf "python php bash terraform aws vault ansible" | tr ' ' '\n'`
core_utils=`printf "xargs sed mv awk find" | tr ' ' '\n'`

selected=`printf "${languages}\n${core_utils}" | fzf`
#selected=``
