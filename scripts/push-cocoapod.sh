#!/bin/sh

set -e # fail script if an error is encountered 

# Pushes a given Cocoapod to the Cocoapods server for deployment. 
# Use script: ./scripts/push-cocoapod.sh CioFirebaseWrapper.podspec

PODSPEC="$1"

if ! [[ -f "$PODSPEC" ]]; then
    echo "File $PODSPEC does not exist. Please check the pod name."
fi

echo "Pushing podspec: $PODSPEC."
echo "Pushing to cocoapods is flaky and there might be errors that happen when pushing to cocoapods that might not mean the deployment failed."
echo "If you do notice an error message when trying to push a pod,"
echo "1. Check this github repo https://github.com/search?q=repo%3ACocoaPods%2FSpecs+CioFirebaseWrapper&type=commits to find the pods that successfully deployed. Dont trust cocoapods.org or the logs from this script if a deployment was successful or not."
echo "2. Feel free to re-run a GitHub Action if you see errors. This script can be run many times and not cause issues with pods that have already been deployed."

# the '|| true' code makes it so the command never fails, even if an error is returned. 
# CocoaPods deployments are flaky. Because of that, when you deploy to cocoapods it's best that you manually confirm 
# that the pods all got deployed successfully. If not, just re-run the job on github actions to try pushing the pods again. 
# If you try to re-run the github action without '|| true', the script would fail early and not allow you to retry pushing all pods. 
pod trunk push "$PODSPEC" --allow-warnings --synchronous || true 

