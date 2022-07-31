#!/bin/bash
# Run with heroku apps:table --filter="App Name=app-name-heres" --columns="app name" --no-header | xargs -n 1 heroku run "bash <(curl -s https://raw.githubusercontent.com/discodrive/shell-scripts/main/user-delete.sh) test@substrakt.com" -a

# Email address of the user to delete. Save it to a variable for checks.
EMAIL=$1
USERS="$(./wp-cli.phar user list --fields=ID,user_email | grep @substrakt)"

printf $USERS

# Check if the specified email address is a user on the site
if printf $EMAIL | grep -qs "$(./wp-cli.phar user list --fields=ID,user_email)"; then
    # Find the first substrakt user. Set variables for the ID and Email address
    USER="$(./wp-cli.phar user list --fields=ID,user_email | grep @substrakt | sed -n 1p)"
    USER_ID=$(echo $USER | awk '{print $1}')
    USER_EMAIL=$(echo $USER | awk '{print $2}')

    # If the email input matches the queried user, reassign the USER_ID variable to the next valid user
    # Quiet the output and suppress errors - this is just acting as a conditional check so we dont want an output
    if printf $EMAIL | grep -qs $USER_EMAIL; then
        USER_ID="$(./wp-cli.phar user list --fields=ID,user_email | grep @substrakt | sed -n 2p | awk '{print $1;}')"
    fi

    # Delete the user and reassign
    ./wp-cli.phar user delete ${EMAIL} --reassign=${USER_ID}

    printf "User: ${EMAIL} deleted. Content reassigned to ${USER_EMAIL}"
else
    printf "Selected user does not exist"
fi

