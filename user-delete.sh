#!/bin/bash

# Input the email address of the user to delete. Save it to a variable for checks.
read -p "Email address of user to delete: " EMAIL

# Find the first substrakt user, get the second line (to exclude table headers) and first word (user ID)
USER="$(./wp-cli.phar user list --fields=ID,display_name,user_email | grep @substrakt | sed -n 2p | awk '{print $1;}')"
# Delete the user and reassign
./wp-cli.phar user delete ${EMAIL} --reassign=${USER}


