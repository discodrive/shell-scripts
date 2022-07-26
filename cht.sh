#! /bin/bash

# List languages and replace spaces with new lines
languages=`printf "python php bash terraform aws vault ansible golang" | tr ' ' '\n'`
core_utils=`printf "xargs sed mv awk find tmux" | tr ' ' '\n'`

selected=`printf "${languages}\n${core_utils}" | fzf`
read -p "query: " query

# Check if we are selecting a language
# grep check for a match to see if the selection is in the languages list
# -q Quiet; Do not return to standard output
# -s Suppress error messages 
if printf "$languages" | grep -qs $selected; then
    # curl the cheat sheet for the selected language plus args
    tmux neww bash -c "curl cht.sh/$selected/`echo $query | tr ' ' '+'` & while [ : ]; do sleep 1; done"
else
    # curl the cheat sheet for the selected coreutil plus args
    tmux neww bash -c "curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done"
fi
