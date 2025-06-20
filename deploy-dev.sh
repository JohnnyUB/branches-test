#!/bin/bash

set -e  

if [ -z "$1" ]; then        
  echo "Usage: $0 <task-branch-name>"
  exit 1
fi

TASK_BRANCH="$1"
DEV_BRANCH="${TASK_BRANCH}-dev"
MASTER_DEV_BRANCH="master-DEV"

# Check if task branch exists locally or remotely
if ! git show-ref --verify --quiet refs/heads/$TASK_BRANCH && ! git ls-remote --exit-code --heads origin $TASK_BRANCH > /dev/null; then
  echo "Branch $TASK_BRANCH does not exist locally or remotely."
  exit 2
fi

# Fetch all
git fetch

# Checkout task branch
git checkout $TASK_BRANCH

# Create dev branch from task branch
git checkout -b $DEV_BRANCH

# Push dev branch to remote
git push -u origin $DEV_BRANCH

# Checkout master-DEV and update
git checkout $MASTER_DEV_BRANCH
git pull origin $MASTER_DEV_BRANCH

# Merge dev branch into master-DEV
git merge --no-ff $DEV_BRANCH

# Push master-DEV
git push origin $MASTER_DEV_BRANCH

echo "✅ Branch $DEV_BRANCH merged into $MASTER_DEV_BRANCH and pushed."