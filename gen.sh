#!/bin/bash
set -ev
git clone https://${GH_REF} .deploy_git
cd .deploy_git
git checkout master
cd ../
mv .deploy_git/.git/ ./public/
cd ./public
ls
git config user.name  "huangyisan"
git config user.email "anonymousyisan@gmail.com"
# add commit timestamp
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"
git push --force --quiet "https://${token}@${GH_REF}" master:master
