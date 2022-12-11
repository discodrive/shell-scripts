#!/bin/bash

profiles="$(aws configure list-profiles)"

for profile in $profiles
do
    r=$(aws configure get region --profile "$profile")
    if
        # Check if EU or US so that we can set maintenance window accordingly
        # Create a maintenance window aws ssm create-maintenance-window https://docs.aws.amazon.com/systems-manager/latest/userguide/mw-cli-tutorial-create-mw.html
        # Schedule a database engine update to run on the new maintenance window
    fi
    aws rds describe-db-instances --query "*[].{DBInstanceIdentifier:DBInstanceIdentifier,Engine:Engine,EngineVersion:EngineVersion}" --output text --no-cli-pager --profile "$profile" --region "$r" | grep 5.6 >> test.txt
done
