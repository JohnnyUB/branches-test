#!/bin/bash

set -e

# Get current branch as TASK_BRANCH
TASK_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Remote name
REMOTE=branches-test

deploy_env() {
  ENV_NAME=$1
  DEST_BRANCH=$2
  SUFFIX=$3

  WORK_BRANCH="${TASK_BRANCH}-${SUFFIX}"

  echo "\n==== Deploy su $ENV_NAME ===="
  echo "Branch di lavoro: $WORK_BRANCH"
  echo "Branch di destinazione: $DEST_BRANCH"

  # Crea branch di lavoro da TASK_BRANCH
  git checkout $TASK_BRANCH
  git checkout -b $WORK_BRANCH

  # Push branch di lavoro
  git push -u $REMOTE $WORK_BRANCH

  # Allinea branch di lavoro con branch di destinazione
  git pull $REMOTE $DEST_BRANCH
  echo "✅ $DEST_BRANCH mergiato in $WORK_BRANCH. Risolvi eventuali conflitti, poi premi invio per continuare."
  read -p "Premi invio per continuare..."

  # Push branch di lavoro aggiornato
  git push $REMOTE $WORK_BRANCH

  # Passa su branch di destinazione e aggiorna
  git checkout $DEST_BRANCH
  git pull $REMOTE $DEST_BRANCH

  # Merge branch di lavoro in branch di destinazione
  git merge --no-ff $WORK_BRANCH
  git push $REMOTE $DEST_BRANCH

  # Cancella branch di lavoro localmente e remotamente
  git branch -d $WORK_BRANCH
  git push $REMOTE --delete $WORK_BRANCH

  echo "✅ Deploy su $ENV_NAME completato."
}

# Menu interattivo
PS3="Seleziona l'ambiente di deploy (1-4): "
options=("DEV" "STAGE" "PROD" "TUTTI")
select opt in "${options[@]}"; do
  case $opt in
    "DEV")
      deploy_env "DEV" "main-DEV" "dev"
      break
      ;;
    "STAGE")
      deploy_env "STAGE" "main-STAGE" "stage"
      break
      ;;
    "PROD")
      deploy_env "PROD" "main" "prod"
      break
      ;;
    "TUTTI")
      deploy_env "DEV" "main-DEV" "dev"
      deploy_env "STAGE" "main-STAGE" "stage"
      deploy_env "PROD" "main" "prod"
      break
      ;;
    *) echo "Opzione non valida";;
  esac
done