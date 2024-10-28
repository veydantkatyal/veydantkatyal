#!/bin/bash

# Set your GitHub username and use the token from the secret
USERNAME="veydantkatyal"
TOKEN="${{ secrets.TOKEN }}"  # Accessed via GitHub Actions

# Fetch contribution stats from both public and private repos
TOTAL_REPOSITORIES=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/users/$USERNAME/repos?per_page=100" | jq '. | length')
TOTAL_COMMITS=0

# Loop through each repository to count commits
for REPO in $(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/users/$USERNAME/repos?per_page=100" | jq -r '.[].full_name'); do
    COMMITS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$REPO/stats/contributors" | jq '.[].total' | awk '{s+=$1} END {print s}')
    TOTAL_COMMITS=$((TOTAL_COMMITS + COMMITS))
done

# Total contributions (public + private)
TOTAL_CONTRIBUTIONS=$TOTAL_COMMITS

# Update the README file
README_FILE="README.md"
sed -i "s/<TOTAL_CONTRIBUTIONS>/$TOTAL_CONTRIBUTIONS/g" $README_FILE
sed -i "s/<TOTAL_REPOSITORIES>/$TOTAL_REPOSITORIES/g" $README_FILE
sed -i "s/<TOTAL_COMMITS>/$TOTAL_COMMITS/g" $README_FILE

# Commit and push changes
git add $README_FILE
git commit -m "daily stats"
git push
