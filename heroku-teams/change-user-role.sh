#!/bin/bash
TEAMS=$(heroku teams | awk '{print $1;}')

for TEAM in $TEAMS
do
    SUBSTRAKT=$(heroku members -t $TEAM | grep @substrakt.co | grep collaborator | awk '{print $1}')
    if [ ! -z "$SUBSTRAKT" ]; then
        for MEMBER in $SUBSTRAKT
        do
            heroku members:add $MEMBER -t $TEAM --role member
        done
    else
        echo "No collaborators with @substrakt.* email addresses found in ${TEAM} team."
    fi
done
