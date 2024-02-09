#!/bin/bash
Help() {
    # Display Help
    echo "Launch odoo-bin with py-spy in speedscope mode by default."
    echo
    echo "Syntax: py-spy-start [-f|o] <database>"
    echo "options:"
    echo " f [speedscope|flamegraph]   Change the format of the input (flamegraph or speedscope)"
    echo " o                           Path where the file will be outputed"
    echo
}

if [[ $# -lt 1 ]]; then
    Help
    exit 1
fi

OPTSTRING=":f:o:l:"

file_format="speedscope"
output="./"
log=debug_sql
while getopts "$OPTSTRING" opt; do
    case ${opt} in
        f)
            file_format="$OPTARG"
            ;;
        o)
            output="$OPTARG"
            ;;
        l)
            log=$OPTARG
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

case "$file_format" in
    flamegraph)
        file_type="svg"
        file_format="flamegraph"
        ;;
    speedscope)
        file_type="json"
        file_format="speedscope"
        ;;
    ?)
        echo "Invalid format: $format"
        exit 1
        ;;
esac
shift $(($OPTIND - 1))
date_time=$(date "+%Y-%m-%d_%H:%M:%S")
py-spy record -f "$file_format" -o "$o"output-"$1"-"$date_time"."$file_type" -- python3 /home/odoo/Documents/repo/odoo/odoo-bin --addons-path="/home/odoo/Documents/repo/odoo/addons,/home/odoo/Documents/repo/enterprise,/home/odoo/Documents/repo/internal/default,/home/odoo/Documents/repo/design-themes" --log-level=$log --limit-time-real=7200 --http-port=9000 --limit-memory-hard=1097152000 -d $1
