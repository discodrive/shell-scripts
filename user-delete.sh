#!/bin/bash
# Run with curl -s https://raw.githubusercontent.com/discodrive/shell-scripts/main/user-delete.sh


# Email address of the user to delete. Save it to a variable for checks.
# read -p "Email address of user to delete: " EMAIL
EMAIL="test@substrakt.com"

# Find the first substrakt user, get the second line (to exclude table headers) and third word (user email)
USER="$(./wp-cli.phar user list --fields=ID,user_email | grep @substrakt | sed -n 1p)"
USER_ID=$(echo $USER | awk '{print $1}')
USER_EMAIL=$(echo $USER | awk '{print $2}')

# if the email input matches the queried user, reassign the USER variable to the next valid user
# Quiet the output and suppress errors - this is just acting as a conditional check
if printf $EMAIL | grep -qs $USER_EMAIL; then
    USER_ID="$(./wp-cli.phar user list --fields=ID,user_email | grep @substrakt | sed -n 2p | awk '{print $1;}')"
fi

printf $USER_ID

# # Delete the user and reassign
# ./wp-cli.phar user delete ${EMAIL} --reassign=${USER_ID}

