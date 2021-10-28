#!/bin/bash
# Mocks a call to the "/api/webhook/deploymentCompleted" endpoint on localhost.
# This mock is meant to be used locally and is what's being used by the "send-webhook-callback-once-deployment-ready" job in staging/production GitHub Actions workflows.
# Execute ". ./scripts/webhook-mock-deploymentCompleted.sh" to run this script locally, while the server is started.

VERCEL_DEPLOYMENT_COMPLETED_WEBHOOK="http://localhost:8888/api/webhooks/deploymentCompleted"
WEB3_TRIGGER_DAPP=
WEB3_NETWORK_ID="0x1"

# Generates JSON using a bash function - See https://stackoverflow.com/a/57369772/2391795
generate_deployment_data() {
  cat <<EOF
{
  "WEB3_TRIGGER_DAPP": "${WEB3_TRIGGER_DAPP}",
  "CHAIN_ID_REF": "${WEB3_NETWORK_ID}",
  "STAGE": "staging"
}
EOF
}

echo "EXECUTING: generate_deployment_data():"
echo "$(generate_deployment_data)"

echo "EXECUTING: webhook at '$VERCEL_DEPLOYMENT_COMPLETED_WEBHOOK'"
echo "EXECUTING: HTTP request (curl):"
curl POST \
  "$VERCEL_DEPLOYMENT_COMPLETED_WEBHOOK" \
  -vs \
  --header "Accept: application/json" \
  --header "Content-type: application/json" \
  --data "$(generate_deployment_data)" \
  2>&1 | sed '/^* /d; /bytes data]$/d; s/> //; s/< //'

# See https://stackoverflow.com/a/54225157/2391795
# -vs - add headers (-v) but remove progress bar (-s)
# 2>&1 - combine stdout and stderr into single stdout
# sed - edit response produced by curl using the commands below
#   /^* /d - remove lines starting with '* ' (technical info)
#   /bytes data]$/d - remove lines ending with 'bytes data]' (technical info)
#   s/> // - remove '> ' prefix
#   s/< // - remove '< ' prefix
