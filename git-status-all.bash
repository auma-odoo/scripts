#!/bin/bash
parent_path=~/Documents/repo

all_repo=('odoo' 'enterprise' 'design-themes' 'internal' 'support-tools')

echo "Fetch:"
for repo in "${all_repo[@]}"; do
    git -C "$parent_path/$repo" fetch
done

echo "---------------------------"
echo "Status"
for repo in "${all_repo[@]}"; do
    git -C "$parent_path/$repo" status
done

echo "---------------------------"
read -p "Do you want to pull new commit? [Y/n]" answer

if [[ $answer == "Y" ]] || [[ $answer == "y" ]]; then
    for repo in "${all_repo[@]}"; do
        git -C "$parent_path/$repo" pull --ff-only
    done
fi
