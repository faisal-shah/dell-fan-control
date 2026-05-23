#!/bin/bash
while sleep 2; do
  temps=()
  for f in /dev/cpu_die_temp_*; do
    read val < "$f" 2>/dev/null && temps+=($val)
  done

  if (( ${#temps[@]} == 0 )); then
    /usr/bin/i8kfan - 2 > /dev/null
    echo "FAN=2 (no sensors)"
    continue
  fi

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
