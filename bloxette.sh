#!/bin/bash

if [ "$1" = "update" ]; then
  echo "Please wait, this may take a while..."

  rm -rf /tmp/bloxette
  mkdir /tmp/bloxette

  touch /tmp/bloxette/whitelist-raw /tmp/bloxette/whitelist-ipv4 /tmp/bloxette/whitelist-ipv6
  if [ -f /var/lib/bloxette/whitelists.txt ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      if [[ "$line" == "http"* ]]; then
        curl -sL "$line" >> /tmp/bloxette/whitelist-raw
      else
        echo "$line" >> /tmp/bloxette/whitelist-raw
      fi
    done < /var/lib/bloxette/whitelists.txt
  fi
  if [ -f /tmp/bloxette/whitelist-raw ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      if [[ -z "$line" ]]; then
        continue
      elif [[ "$line" == "#"* ]]; then
        continue
      elif [[ "$line" == *"::"* ]]; then
        echo "${line%% *}" >> /tmp/bloxette/whitelist-ipv6
      else
        echo "${line%% *}" >> /tmp/bloxette/whitelist-ipv4
      fi
    done < /tmp/bloxette/whitelist-raw
  fi
  if [ -f /tmp/bloxette/whitelist-ipv6 ]; then
    cidr-merger -s /tmp/bloxette/whitelist-ipv6 > /tmp/bloxette/whitelist-ipv6-cidr
  fi
  if [ -f /tmp/bloxette/whitelist-ipv4 ]; then
    cidr-merger -s /tmp/bloxette/whitelist-ipv4 > /tmp/bloxette/whitelist-ipv4-cidr
  fi

  touch /tmp/bloxette/blocklist-raw /tmp/bloxette/blocklist-ipv4 /tmp/bloxette/blocklist-ipv6
  if [ -f /var/lib/bloxette/blocklists.txt ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      if [[ "$line" == "http"* ]]; then
        curl -sL "$line" >> /tmp/bloxette/blocklist-raw
      else
        echo "$line" >> /tmp/bloxette/blocklist-raw
      fi
    done < /var/lib/bloxette/blocklists.txt
  fi
  if [ -f /tmp/bloxette/blocklist-raw ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      if [[ -z "$line" ]]; then
        continue
      elif [[ "$line" == "#"* ]]; then
        continue
      elif [[ "$line" == *"::"* ]]; then
        echo "${line%% *}" >> /tmp/bloxette/blocklist-ipv6
      else
        echo "${line%% *}" >> /tmp/bloxette/blocklist-ipv4
      fi
    done < /tmp/bloxette/blocklist-raw
  fi
  if [ -f /tmp/bloxette/blocklist-ipv6 ]; then
    cidr-merger -s /tmp/bloxette/blocklist-ipv6 > /tmp/bloxette/blocklist-ipv6-cidr
  fi
  if [ -f /tmp/bloxette/blocklist-ipv4 ]; then
    cidr-merger -s /tmp/bloxette/blocklist-ipv4 > /tmp/bloxette/blocklist-ipv4-cidr
  fi
fi

exit
