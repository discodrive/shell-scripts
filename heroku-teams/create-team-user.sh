#!/bin/bash
EMAIL=$1
TEAMS=$(heroku teams | awk '{print $1;}')

function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo "$LIST" | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
}

for TEAM in $TEAMS
do
    MEMBERS=$(heroku members -t "$TEAM" | grep @substrakt.co)
    if ! exists_in_list "$MEMBERS" " " "$EMAIL"; then
        heroku members:add "$EMAIL" -t "$TEAM" --role member
    else
         echo "${EMAIL} is already a member of the ${TEAM} team."
    fi
done
