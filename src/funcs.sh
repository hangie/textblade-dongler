#!/usr/bin/env bash

TRACE=0

declare -A hci

trace() {
  if [[ $TRACE == 1 ]]; then
    echo "TRACE: $@"
  fi
}

load_hcidevs() {
  pipe=/tmp/hcidevs$$
  trap "rm -f $pipe" EXIT

  hciconfig > $pipe 2> /dev/null
  hcidev=
  while read -t 1 line ; do
    case $line in
      hci[0-9]:*)
	strs=($line)
	hcidev=${strs[0]%%:}
        trace "DEV[$hcidev]:  $line"
	;;
      "BD Address:"*)
	set -- $line
	trace DEV[$hcidev]: [$3]
	hci+=([$hcidev]="$3")
        ;;
      *)
	trace "OTHER[$line]"
	;;
    esac
    
  done < $pipe
}

select_hcidev() {
  local hcidev=hci0
  local __resultvar=$1

  # Only neec to display a menu if more than one, otherwise
  # hci0 is the default.
  if [[ ${#hci[@]} -gt 1 ]]; then
    echo "Available hci devices:"
    PS3='Please select a hci device: '
    select opt in "${!hci[@]}"; do
      case $opt in
	"")
	  echo "Invalid choice [$REPLY] => [$opt]"
	  ;;
	*)
	  break
	  ;;
      esac
    done
    hcidev=$opt
  fi  
  
  if [[ "$__resultvar" ]]; then
    eval $__resultvar="$hcidev"
  fi
}

load_hcidevs

select_hcidev foo

echo "Selected [$foo]"

#
# Local Variables:
# sh-basic-offset: 2
# End:
