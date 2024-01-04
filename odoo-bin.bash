Help()
{
   # Display Help
   echo "Launch odoo-bin with py-spy in speedscope mode by default."
   echo
   echo "Syntax: odoo-bin-start [-m] <database>"
   echo "options:"
   echo " m   Change the limit of the memory (default: 1097152000)"
   echo
}

if [[ $# -lt 1 ]] ; then
  Help
  exit 1
fi

OPTSTRING=":m:"

memory=1097152000
while getopts "$OPTSTRING" opt; do
  case ${opt} in
    m)
      memory="$OPTARG"
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

/home/odoo/Documents/repo/odoo/odoo-bin --addons-path="~/Documents/repo/odoo/addons,~/Documents/repo/enterprise,~/Documents/repo/internal/default,~/Documents/repo/design-themes" --log-level=debug_sql --limit-time-real=7200 --http-port=9000 --limit-memory-soft="$memory" --limit-memory-hard="$memory" --db-filter="$1";
