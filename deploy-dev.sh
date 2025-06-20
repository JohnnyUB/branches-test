#!/bin/bash

set -e

# Get current branch as TASK_BRANCH
TASK_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEV_BRANCH="${TASK_BRANCH}-dev"
MAIN_DEV_BRANCH="main-DEV"

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
git push -u branches-test $DEV_BRANCH

# Merge main-DEV into dev branch per allineamento
git pull branches-test $MAIN_DEV_BRANCH

echo "✅ $MAIN_DEV_BRANCH merged into $DEV_BRANCH. Risolvi eventuali conflitti, poi premi invio per continuare."
read -p "Premi invio per continuare..."

git push branches-test $DEV_BRANCH

# Checkout main-DEV e aggiorna
git checkout $MAIN_DEV_BRANCH
git pull branches-test $MAIN_DEV_BRANCH

# Merge dev branch into main-DEV
git merge --no-ff $DEV_BRANCH

git push branches-test $MAIN_DEV_BRANCH

# (Opzionale) Cancella il branch dev localmente e remotamente
git branch -d $DEV_BRANCH
git push branches-test --delete $DEV_BRANCH


echo "✅ Branch $DEV_BRANCH aggiornato con $MAIN_DEV_BRANCH, mergiato in $MAIN_DEV_BRANCH e pushato."