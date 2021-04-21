#!/bin/bash

set -euo pipefail
set -o errexit
set -o errtrace
IFS=$'\n\t'

export S3_ACL=${S3_ACL:-private}

if [ ! -d $MOUNT_POINT ]; then
  mkdir -p $MOUNT_POINT
fi

DEBUG_OPTION=""
if [ $DEBUG = "true" ]; then
  DEBUG_OPTION="-d -d"
fi

if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

  echo 'IAM_ROLE is not set'
  /usr/bin/s3fs $DEBUG_OPTION ${S3_BUCKET} ${MOUNT_POINT} -o nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},umask=0000,retries=5
else
  echo 'IAM_ROLE is set'
  /usr/bin/s3fs $DEBUG_OPTION ${S3_BUCKET} ${MOUNT_POINT} -o iam_role=${IAM_ROLE},nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},umask=0000,retries=5
fi

mounted=$(mount | grep s3fs | grep "${MOUNT_POINT}")
if [ -n "${mounted}" ]; then
    echo "Mounted bucket ${S3_BUCKET} onto ${MOUNT_POINT}"
    exec "$@"
else
    echo "Mount failure - can't found mount"
fi
