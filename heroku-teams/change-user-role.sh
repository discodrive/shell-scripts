#!/bin/bash
TEAMS=$(heroku teams | awk '{print $1;}')

for TEAM in $TEAMS
do
    SUBSTRAKT=$(heroku members -t $TEAM | grep @substrakt.co | grep collaborator)
    EMAIL="$(echo $SUBSTRAKT | awk '{print $1}')"
    if [ ! -z "$SUBSTRAKT" ]; then
        heroku members:set $EMAIL -t $TEAM --role member
    else
        echo "No collaborators with @substrakt.* email addresses found in ${TEAM} team."
    fi
done
