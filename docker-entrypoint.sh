#!/bin/bash

set -euo pipefail
set -o errexit
set -o errtrace
IFS=$'\n\t'

export S3_ACL=${S3_ACL:-private}
export UMASK=${UMASK:-000}
export UID=${UID:-0}
export GID=${GID:-0}

if [ ! -d $MOUNT_POINT ]; then
  mkdir -p $MOUNT_POINT
fi

if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

  echo 'IAM_ROLE is not set - /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -o use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID},dbglevel=info -o curldbg'
  /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -o use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID},dbglevel=info -o curldbg
else
  echo 'IAM_ROLE is set - /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -o iam_role=${IAM_ROLE},use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID},dbglevel=info -o curldbg'
  /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -o iam_role=${IAM_ROLE},use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID},dbglevel=info -o curldbg
fi

mounted=$(mount | grep s3fs | grep "${MOUNT_POINT}")
if [ -n "${mounted}" ]; then
    echo "Mounted bucket ${S3_BUCKET} onto ${MOUNT_POINT}"
else
    echo "Mount failure - can't found mount"
fi
