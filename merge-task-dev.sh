# Push dev branch to remote
git push -u branches-test $DEV_BRANCH

# Checkout master-DEV and update
git checkout $MASTER_DEV_BRANCH
git pull branches-test $MASTER_DEV_BRANCH

# Merge dev branch into master-DEV
git merge --no-ff $DEV_BRANCH

# Push master-DEV
git push branches-test $MASTER_DEV_BRANCH 