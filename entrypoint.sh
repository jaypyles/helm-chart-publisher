#!/bin/sh

set -e

CHART_PATH=$1
HELM_REPO_URL=$2
TARGET_REPO=$3
BRANCH=$4
CHART_NAME=$5
GPAT_TOKEN=$6
NEW_VERSION=$7

echo "Updating version in source repository..."
sed -i "s/^version:.*/version: $NEW_VERSION/" charts/$CHART_NAME/Chart.yaml

echo "Packaging Helm Chart..."
helm package "$CHART_PATH"
mkdir -p artifacts
mv *.tgz artifacts/

echo "Updating Helm repo index..."
helm repo index artifacts/ --url "$HELM_REPO_URL/main/charts/$CHART_NAME"

echo "Cloning target repo..."
git clone https://${GPAT_TOKEN}@github.com/${TARGET_REPO}.git
cd "$(basename "$TARGET_REPO")"

echo "Configuring Git..."
git config user.name "GitHub Actions"
git config user.email "github-actions@github.com"

echo "Copying Helm chart and index..."
mkdir -p charts/$CHART_NAME
cp ../artifacts/*.tgz charts/$CHART_NAME/
cp ../artifacts/index.yaml charts/$CHART_NAME/

echo "Committing and pushing changes..."
git add charts/
git commit -m "Add new $CHART_NAME chart version and update index.yaml"
git push origin main

# Push the updated version to the source repository
echo "Pushing updated version to the source repository..."
git config --add safe.directory /github/workspace
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

cd $GITHUB_WORKSPACE
git add "$CHART_PATH/Chart.yaml" "$CHART_PATH/values.yaml"
git commit -m "Update version [skip ci]"
git push "https://x-access-token:${GPAT_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" "$BRANCH"