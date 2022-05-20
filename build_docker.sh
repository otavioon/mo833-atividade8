#!/bin/bash

# Script utilizado para gerar a imagem Docker, baseado no arquivo Dockerfile
# Este script não deve ser alterado

source ./vars.sh
$CONTAINER_CMD build -t $CONTAINER_IMAGE .
