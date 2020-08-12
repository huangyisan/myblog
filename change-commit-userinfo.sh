#!/bin/sh

git filter-branch --commit-filter '
OLD_USER="hysan"
CORRECT_NAME="huangyisan"
CORRECT_EMAIL="anonymousyisan@gmail.com"
if [ "$GIT_COMMITTER_USER" = "$OLD_USER" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi' HEAD
