#!/bin/bash
EMAIL=$1
TEAMS=$(heroku teams | awk '{print $1;}')
for TEAM in $TEAMS
do
    USER=$(heroku members -t $TEAM | awk '{print $1;}' | grep $EMAIL)
    if [ ! -z "$USER" ]; then
        heroku members:remove $EMAIL -t $TEAM
    else
        printf "User: ${EMAIL} does not exist.\n"
    fi
done
