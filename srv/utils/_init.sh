# Get the full directory name of the script
# no matter where it is being called from.
# https://stackoverflow.com/a/246128/9254063
UTILS=$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null &&
        pwd
)
source $UTILS/_general.sh
source $UTILS/_shell.sh
source $UTILS/_who.sh
