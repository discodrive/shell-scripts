#!/bin/bash
TEAMS=$(heroku teams | awk '{print $1;}')

function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo $LIST | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
}

for TEAM in $TEAMS
do
    MEMBERS=$(heroku members -t "$TEAM")
    PENDING=$(echo "$MEMBERS" | grep @substrakt.co | grep pending | awk '{print $1}')
    COLLABS=$(echo "$MEMBERS" | grep @substrakt.co | grep collaborator | awk '{print $1}')

    if [ ! -z "$COLLABS" ]; then
        for MEMBER in $COLLABS
        do
            if ! exists_in_list "$PENDING" " " $MEMBER; then
                heroku members:add $MEMBER -t $TEAM --role member
            else
                echo "${MEMBER} is already pending a role change in ${TEAM} team."
            fi
        done
    else
        echo "No collaborators with @substrakt.* email addresses found in ${TEAM} team."
    fi
done
