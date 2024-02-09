#!/bin/bash
if [[ $# -ne 1 ]]; then
    echo "Need only name of the branch"
    exit 2
fi

odoo_path=~/Documents/repo/odoo/
enterprise_path=~/Documents/repo/enterprise/
design_path=~/Documents/repo/design-themes/

git -C "$odoo_path" switch "$1"
git -C "$enterprise_path" switch "$1"
git -C "$design_path" switch "$1"

read -p "Do you want to pull new commit ? " answer

if [[ $answer == "Y" ]] || [[ $answer == "y" ]]; then
    git -C "$odoo_path" pull --ff-only
    git -C "$enterprise_path" pull --ff-only
    git -C "$design_path" pull --ff-only
fi
