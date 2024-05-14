#!/bin/bash

Help() {
	# Display Help
	echo "Launch odoo-bin with py-spy in speedscope mode by default."
	echo
	echo "Syntax: odoo-bin-start [-m] <database>"
	echo "options:"
	echo " m   Change the limit of the memory (default: 1097152000)"
	echo " v   Change the log level to 'debug_sql'"
	echo " w   Chang the log level to 'warn'"
	echo
}

if [[ $# -lt 1 ]]; then
	Help
	exit 1
fi

OPTSTRING="m:v:w:iu"

OPTIND=1

memory=1097152000
log=info
other_parameter=""
echo $@
while getopts "$OPTSTRING" opt; do
	case ${opt} in
	m)
		memory=$OPTARG
    echo "memory: $memory"
		;;
	v)
		log=debug_sql
		;;
	w)
		log=warn
		;;
	i | u)
		other_parameter="-${opt} ${OPTARG} $other_parameter"
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
echo "         Settings          "
echo "---------------------------"
echo "Memory: $memory"
echo "Log level: $log"
echo "Database name: $1"
echo "Other parameters: $other_parameter"
echo "---------------------------"
echo
/home/odoo/Documents/repo/odoo/odoo-bin --addons-path="~/Documents/repo/odoo/addons,~/Documents/repo/enterprise,~/Documents/repo/internal/default,~/Documents/repo/design-themes" --log-level=$log --limit-time-real=7202 --http-port=9000 --limit-memory-soft=$memory --limit-memory-hard=$memory $other_parameter --db-filter="$1"
