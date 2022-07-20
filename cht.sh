#! /bin/bash

# List languages and replace spaces with new lines
languages=`echo "python php bash terraform aws vault ansible" | tr ' ' '\n'`
core_utils=`printf "xargs sed mv awk find" | tr ' ' '\n'`

echo ${languages} ${core_utils}
#selected=``
