#!/bin/bash

########################################################################################################################
# Use this script to verify a company
########################################################################################################################

if [ "$#" -lt 1 ];
  then
    echo "Use this script to verify a company"
    echo "One parameter is needed, which indicates fiscal ID of the company."
    echo "Change .env.local and the REMOTE_HOST variable to connect to prod or sanbdox."
    echo "$0 123456789"
    exit 1
fi

DIR="$(dirname "${BASH_SOURCE[0]}")"
DIR="$(readlink -f "${DIR}")"

REMOTE_HOST=https://api-sandbox.acubeapi.com

DIR="$(dirname "${BASH_SOURCE[0]}")"
DIR="$(readlink -f "${DIR}")"

export JWT=$("${DIR}"/getJWT.sh)

curl -X GET -k --no-progress-meter -H "Authorization: bearer $JWT" -H 'Accept: application/json' -H 'Content-Type: application/json' $REMOTE_HOST/verify/company/${1} | jq
