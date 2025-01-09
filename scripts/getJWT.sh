#!/bin/bash

########################################################################################################################
# This script get a JWT token from common sandbox and it is executed also from other scripts
# It requires jq
# You need to add COMMON_LOGIN_URL, COMMON_LOGIN_EMAIL and COMMON_LOGIN_PASSWORD in env.local as well
########################################################################################################################


DIR="$(dirname "${BASH_SOURCE[0]}")"
DIR="$(readlink -f "${DIR}")"

source "${DIR}"/../.env.local

JSON_REQUEST=$( jq -n \
       --arg em "$COMMON_LOGIN_EMAIL" \
       --arg pw "$COMMON_LOGIN_PASSWORD" \
       '{email: $em, password: $pw}' )

curl -s --location --request POST "$COMMON_LOGIN_URL/login" \
 --header 'Content-Type: application/json' \
 --data-raw "$JSON_REQUEST" | jq -r '.token'