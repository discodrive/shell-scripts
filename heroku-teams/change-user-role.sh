#!/bin/bash
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
    # Get the email addresses of all pending members
    PENDING=$(echo "$MEMBERS" | grep pending | awk '{print $1}')
    # Get the email addresses of all collaborators
    COLLABS=$(echo "$MEMBERS" | grep collaborator | awk '{print $1}')

    # Check that the collabs list is not empty
    if [ -n "$COLLABS" ]; then
        for MEMBER in $COLLABS
        do
            # If the current member is NOT already pending a role change, invite them to become a member
            if ! exists_in_list "$PENDING" " " "$MEMBER"; then
                heroku members:add "$MEMBER" -t "$TEAM" --role member
            else
                echo "${MEMBER} is already pending a role change in ${TEAM} team."
            fi
        done
    else
        echo "No collaborators with @substrakt.* email addresses found in ${TEAM} team."
    fi
done
