#!/bin/bash

profiles="$(aws configure list-profiles)"

for profile in $profiles
do
    r=$(aws configure get region --profile "$profile")
    cluster=$(aws rds describe-db-clusters --query "*[].{DBClusterIdentifier:DBClusterIdentifier,EngineVersion:EngineVersion}" --output text --profile "$profile" --region "$r" --no-cli-pager | grep 5.6 | awk '{print $1;}')

    if [ -n "$cluster" ];then
        aws rds modify-db-cluster \
            --db-cluser-identifier $cluster
            --engine-version "5.7.mysql_aurora.2.11.0"
            --preferred-maintenance-window "Wed:03:00-Wed:04:00"
            --region $r
            --profile $profile
            --no-cli-pager
    fi
done


