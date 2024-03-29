#!/bin/bash
Help() {
    # Display Help
    echo "Launch odoo-bin with py-spy in speedscope mode by default."
    echo
    echo "Syntax: odoo-bin-start [-m] <database>"
    echo "options:"
    echo " m   Change the limit of the memory (default: 1097152000)"
    echo
}

if [[ $# -lt 1 ]]; then
    Help
    exit 1
fi

OPTSTRING=":i:t:"

memory=1097152000
init=""
tags=""
while getopts "$OPTSTRING" opt; do
    case ${opt} in
        i)
            init=${OPTARG}
            ;;

        t)
            tags=${OPTARG}
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            exit 1
            ;;
        ?)
            echo "Invalid option: -${OPTARG}."
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1))
/home/odoo/Documents/repo/odoo/odoo-bin --addons-path="~/Documents/repo/odoo/addons,~/Documents/repo/enterprise,~/Documents/repo/internal/default,~/Documents/repo/design-themes" --init="base,$init" --log-level="info" --test-enable --test-tags="$tags" --stop-after-init -d "$database"
