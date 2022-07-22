#! /bin/bash

# Search recursively for rich in all files
# Pass output to the next command
# Replace all occurances of rich with richard and edit in place to save the file
grep -rl rich * | xargs gsed -i 's/rich/richard/g'
