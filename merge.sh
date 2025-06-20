#!/bin/bash

TASK_BRANCH=$(git rev-parse --abbrev-ref HEAD)
STAGE=$1  # "PRE" o "STAGE" o "PRODUCTION"

# Remote name
REMOTE=$(git remote show | head -n 1)

if [[ -z "$TASK_BRANCH" || -z "$STAGE" ]]; then
  echo "Errore: Devi specificare un ambiente (PRE, STAGE o PROD)."
  echo "Uso: ./merge.sh <PRE|STAGE|PROD>"
  exit 1
fi

if [[ "$STAGE" == "dev" ]]; then
  TARGET_BRANCH="main-DEV"
elif [[ "$STAGE" == "stage" ]]; then
  TARGET_BRANCH="main-STAGE"
elif [[ "$STAGE" == "prod" ]]; then
  TARGET_BRANCH="main"
else
  echo "Ambiente non valido. Usa dev, stage o prod."
  exit 1
fi

TEMP_BRANCH="${TASK_BRANCH}-${STAGE}"

# Controlla se ci sono modifiche non committate
if ! git diff-index --quiet HEAD --; then
  echo "Ci sono modifiche non committate su $TASK_BRANCH, eseguo il commit..."
  git add .
  git commit -m "Commit automatico prima del merge di $TASK_BRANCH"
  git push $REMOTE "$TASK_BRANCH"
fi

# Creazione branch temporaneo
git checkout -b "$TEMP_BRANCH" "$TASK_BRANCH"

# Merge dell'ultima versione del branch target
git merge "$TARGET_BRANCH" --no-ff -m "Merge $TARGET_BRANCH into $TEMP_BRANCH" || {
  echo "\n⚠️  Conflitti durante il merge di $TARGET_BRANCH in $TEMP_BRANCH. Risolvili, fai il commit e poi premi invio per continuare...";
  read -p "Premi invio per continuare...";
}

# Push del branch temporaneo
git push $REMOTE "$TEMP_BRANCH"

# Merge nel branch di destinazione
git checkout "$TARGET_BRANCH"
git merge "$TEMP_BRANCH" --no-ff -m "Merge $TEMP_BRANCH into $TARGET_BRANCH" || {
  echo "\n⚠️  Conflitti durante il merge di $TEMP_BRANCH in $TARGET_BRANCH. Risolvili, fai il commit (senza push) e poi premi invio per continuare...";
  read -p "Premi invio per continuare...";
}

# Push del branch aggiornato
git push $REMOTE "$TARGET_BRANCH"

# Pulizia del branch temporaneo
git branch -d "$TEMP_BRANCH"
git push $REMOTE --delete "$TEMP_BRANCH" || echo "Branch remoto $TEMP_BRANCH non esiste o già eliminato."
