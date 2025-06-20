#!/bin/bash

set -e

# Get current branch as TASK_BRANCH
TASK_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEV_BRANCH="${TASK_BRANCH}-dev"

echo "Current branch: $TASK_BRANCH"
echo "Creating and merging $DEV_BRANCH into $MAIN_DEV_BRANCH..."

# Check if task branch exists locally or remotely
if ! git show-ref --verify --quiet refs/heads/$TASK_BRANCH && ! git ls-remote --exit-code --heads origin $TASK_BRANCH > /dev/null; then
  echo "Branch $TASK_BRANCH does not exist locally or remotely."
  exit 2
fi

# Fetch all
git fetch

# Create dev branch from task branch
git checkout -b $DEV_BRANCH

# Push dev branch to remote
git push -u origin $DEV_BRANCH

# Checkout main-DEV and update
git checkout $MAIN_DEV_BRANCH
git pull origin $MAIN_DEV_BRANCH

# Merge dev branch into main-DEV
git merge --no-ff $DEV_BRANCH

# Push main-DEV
git push origin $MAIN_DEV_BRANCH

echo "✅ Branch $DEV_BRANCH merged into $MAIN_DEV_BRANCH and pushed."