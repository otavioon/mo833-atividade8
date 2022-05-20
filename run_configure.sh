#!/bin/bash

# Script utilizado para execução do playbook configure.yaml nas máquinas do inventorio.
# Este script não deve ser alterado

source ./vars.sh

$CONTAINER_CMD run --interactive --tty --rm \
  --env "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  --env "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  --env "AWS_REGION=$AWS_REGION" \
  --env "KEYPAIR_NAME=$KEYPAIR_NAME" \
  --env "KEYPAIR_PEM_FILE=$KEYPAIR_PEM_FILE" \
  --env "ANSIBLE_PRIVATE_KEY_FILE=$ANSIBLE_PRIVATE_KEY_FILE" \
  --env "EFS_HOST=$EFS_HOST" \
  --env "EFS_MOUNT_POINT=$EFS_MOUNT_POINT" \
  --env "ANSIBLE_HOST_KEY_CHECKING=$ANSIBLE_HOST_KEY_CHECKING" \
  --workdir $WORK_DIR \
  --volume $WORK_DIR:$WORK_DIR \
  $CONTAINER_IMAGE ansible-playbook -v configure.yaml -i inventory.yaml
