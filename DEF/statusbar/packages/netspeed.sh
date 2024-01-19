#!/bin/zsh

tempfile=$(cd $(dirname $0);cd ..;pwd)/temp
this=_netspeed
text_color="^c#3E206F^^b#6E51760x99^"
icon_color="^c#3E206F^^b#6E51760x88^"
signal=$(echo "^s$this^" | sed 's/_//')

function get_bytes {
    interface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}')
    line=$(grep $interface /proc/net/dev | cut -d ':' -f2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
    eval $line
    now=$(date +%s%N)
}


function get_velocity {
    value=$1
    old_value=$2
    now=$3
    timediff=$(($now - $old_time))
    velKB=$(echo "$value/1024/1024" | bc)
    echo $(echo "scale=2; $velKB/1024" | bc)GB
}

disk=$(df -h | grep -e "home$" | awk '{print "Disk:" $4 "|" $2 "|"  $5}')

bluetoothisconnected=$(bluetoothctl info 1C:52:16:6B:B5:D4 | grep Connected | awk '{print $2}')

if [ "$bluetoothisconnected" == "yes" ]; then
    bluetoothiscon="QCY_on "
  else
    bluetoothiscon="QCY_off"
fi

get_bytes
old_received_bytes=0
old_transmitted_bytes=0
old_time=$now

get_bytes

vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

#echo "$vel_recv⬇ $vel_trans⬆ "
update() {
    
    icon=""
    text="total: $vel_recv⬇ $vel_trans⬆  $disk  $bluetoothiscon "
    sed -i '/^export '$this'=.*$/d' $tempfile
    printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
}

case "$1" in
    *) update ;;
esac
