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
  echo "Creating MOUNT_POINT directory $MOUNT_POINT"
  mkdir -p $MOUNT_POINT
fi

if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_ACCESS_KEY_ID}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_ACCESS_KEY}

  echo 'IAM_ROLE is not set - /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -f -o use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID}'
  /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -f -o use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID}
else
  echo 'IAM_ROLE is set - /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -f -o iam_role=${IAM_ROLE},use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID}'
  /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -f -o iam_role=${IAM_ROLE},use_sse,nosuid,nonempty,nodev,allow_other,default_acl=${S3_ACL},retries=5,umask=${UMASK},uid=${UID},gid=${GID}
fi
