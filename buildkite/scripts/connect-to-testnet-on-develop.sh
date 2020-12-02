#!/bin/bash

set -eo pipefail

if [ ! "$BUILDKITE_PULL_REQUEST_BASE_BRANCH" = "develop" ]; then
  echo "Not pulling against develop, not running the connect test"
  exit 0
fi

apt-get update
apt-get install -y git

export DUNE_PROFILE=testnet_postake_medium_curves

source buildkite/scripts/export-git-env-vars.sh

# Don't prompt for answers during apt-get install
export DEBIAN_FRONTEND=noninteractive

apt-get install -y apt-transport-https ca-certificates
echo "deb [trusted=yes] http://packages.o1test.net unstable main" | tee /etc/apt/sources.list.d/coda.list
apt-get update
apt-get install --allow-downgrades -y curl ${PROJECT}=${VERSION}

TESTNET_NAME="turbo-pickles"


if [ ! -d coda-automation ]; then
  # Somebody ran this without the mina repo checked out...
  echo "WARNING: Connecting to testnet without a checked-out coda-automation repo. Attempting to pull data from github's master branch (fallback branch is 3a4e5ce2d)."
  mkdir -p coda-automation/terraform/testnets/$TESTNET_NAME
  # Fetch the files we need from coda-automation's master instead
  # Fall through to a known-good file
  curl https://raw.githubusercontent.com/MinaProtocol/coda-automation/master/terraform/testnets/$TESTNET_NAME/genesis_ledger.json --output coda-automation/terraform/testnets/$TESTNET_NAME/genesis_ledger.json \
  || curl https://raw.githubusercontent.com/MinaProtocol/coda-automation/3a4e5ce2dc1ff01dde37495d43979aa1aeb20bb5/terraform/testnets/$TESTNET_NAME/genesis_ledger.json  --output coda-automation/terraform/testnets/$TESTNET_NAME/genesis_ledger.json
  curl https://raw.githubusercontent.com/MinaProtocol/coda-automation/master/terraform/testnets/$TESTNET_NAME/peers.txt --output coda-automation/terraform/testnets/$TESTNET_NAME/peers.txt \
  || curl https://raw.githubusercontent.com/MinaProtocol/coda-automation/3a4e5ce2dc1ff01dde37495d43979aa1aeb20bb5/terraform/testnets/$TESTNET_NAME/peers.txt  --output coda-automation/terraform/testnets/$TESTNET_NAME/peers.txt
else
  cd coda-automation && git pull origin master && cd -
fi

# Generate genesis proof and then crash due to no peers
coda daemon \
  -config-file ./coda-automation/terraform/testnets/$TESTNET_NAME/genesis_ledger.json \
  -generate-genesis-proof true \
|| true

# Remove lockfile if present
rm ~/.coda-config/.mina-lock ||:

# Restart in the background
coda daemon \
  -peer-list-file coda-automation/terraform/testnets/$TESTNET_NAME/peers.txt \
  -config-file ./coda-automation/terraform/testnets/$TESTNET_NAME/genesis_ledger.json \
  -generate-genesis-proof true \
  & # -background

# Attempt to connect to the GraphQL client every 10s for up to 4 minutes
num_status_retries=24
for ((i=1;i<=$num_status_retries;i++)); do
  sleep 10s
  set +e
  coda client status
  status_exit_code=$?
  set -e
  if [ $status_exit_code -eq 0 ]; then
    break
  elif [ $i -eq $num_status_retries ]; then
    exit $status_exit_code
  fi
done

# Check that the daemon has connected to peers and is still up after 2 mins
sleep 2m
coda client status
if [ $(coda advanced get-peers | wc -l) -gt 0 ]; then
    echo "Found some peers"
else
    echo "No peers found"
    exit 1
fi
