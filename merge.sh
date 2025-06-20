#!/bin/bash

TASK_BRANCH=$(git rev-parse --abbrev-ref HEAD)
STAGE=$1  # "PRE" o "STAGE" o "PRODUCTION"

if [[ -z "$TASK_BRANCH" || -z "$STAGE" ]]; then
  echo "Errore: Devi specificare un ambiente (PRE, STAGE o PROD)."
  echo "Uso: ./merge.sh <PRE|STAGE|PROD>"
  exit 1
fi

if [[ "$STAGE" == "PRE" ]]; then
  TARGET_BRANCH="main-PRE"
elif [[ "$STAGE" == "STAGE" ]]; then
  TARGET_BRANCH="main-STAGE"
elif [[ "$STAGE" == "PROD" ]]; then
  TARGET_BRANCH="main"
else
  echo "Stage non valido. Usa PRE, STAGE o PROD."
  exit 1
fi

TEMP_BRANCH="${TASK_BRANCH}-${STAGE}1"

# Controlla se ci sono modifiche non committate
if ! git diff-index --quiet HEAD --; then
  echo "Ci sono modifiche non committate su $TASK_BRANCH, eseguo il commit..."
  git add .
  git commit -m "Commit automatico prima del merge di $TASK_BRANCH"
  git push origin "$TASK_BRANCH"
fi

# Creazione branch temporaneo
git checkout -b "$TEMP_BRANCH" "$TASK_BRANCH"

# Merge dell'ultima versione del branch target
git merge "$TARGET_BRANCH" --no-ff -m "Merge $TARGET_BRANCH into $TEMP_BRANCH"

# Push del branch temporaneo
git push origin "$TEMP_BRANCH"

# Merge nel branch di destinazione
git checkout "$TARGET_BRANCH"
git merge "$TEMP_BRANCH" --no-ff -m "Merge $TEMP_BRANCH into $TARGET_BRANCH"

# Push del branch aggiornato
git push origin "$TARGET_BRANCH"

# Pulizia del branch temporaneo
git branch -d "$TEMP_BRANCH"
git push origin --delete "$TEMP_BRANCH" || echo "Branch remoto $TEMP_BRANCH non esiste o già eliminato."
