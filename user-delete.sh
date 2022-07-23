#!/bin/bash

# Run the script with:
# heroku apps:table --filter="App Name=-live" --columns="app name" --no-header | xargs -n 1 heroku run "./user-delete.sh"

# Input the email address of the user to delete. Save it to a variable for checks.
read -p "Email address of user to delete: " EMAIL
printf $EMAIL
# Find the first substrakt user, get the second line (to exclude table headers) and first word (user ID)
USER="$(./wp-cli.phar user list --fields=ID,display_name,user_email | grep @substrakt | sed -n 2p | awk '{print $1;}')"


# if the email input matches the queried user, reassign the USER variable to the next valid user
# Quiet the output and suppress errors - this is just acting as a conditional check
if printf $EMAIL | grep -qs $USER; then
    USER="$(./wp-cli.phar user list --fields=ID,display_name,user_email | grep @substrakt | sed -n 3p | awk '{print $1;}')"
fi

# Delete the user and reassign
./wp-cli.phar user delete ${EMAIL} --reassign=${USER}







