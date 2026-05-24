#!/bin/bash
boot_retries=20  # ~40 seconds waiting for sensors at boot

while sleep 2; do
  temps=()
  for f in /dev/cpu_die_temp_*; do
    read val < "$f" 2>/dev/null && temps+=($val)
  done

  if (( ${#temps[@]} == 0 )); then
    if (( boot_retries > 0 )); then
      ((boot_retries--))
      echo "FAN=0 (waiting for sensors, retries left: $boot_retries)"
      /usr/bin/i8kfan - 0 > /dev/null
    else
      /usr/bin/i8kfan - 2 > /dev/null
      echo "FAN=2 (no sensors after timeout)"
    fi
    continue
  fi
  boot_retries=0

  max_temp=0
  for t in "${temps[@]}"; do
    (( t > max_temp )) && max_temp=$t
  done

  echo "max_temp=$max_temp cores=${#temps[@]}"

  if (( max_temp > 65000 )); then
    /usr/bin/i8kfan - 2 > /dev/null
    echo "FAN=2"
  elif (( max_temp > 50000 )); then
    /usr/bin/i8kfan - 1 > /dev/null
    echo "FAN=1"
  else
    /usr/bin/i8kfan - 0 > /dev/null
    echo "FAN=0"
  fi
done
