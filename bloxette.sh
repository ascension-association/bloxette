#!/bin/bash

if [ "$1" = "update" ]; then
  echo "Please wait, this may take a while..."
  
  rm -rf /tmp/bloxette
  mkdir /tmp/bloxette
  
  touch /tmp/bloxette/whitelist-raw /tmp/bloxette/whitelist-ipv4 /tmp/bloxette/whitelist-ipv6
  if [ -f /var/lib/bloxette/whitelists.txt ]; then
    while IFS= read -r line; do
      if [[ "$line" == http* ]]; then
        curl -sL "$line" >> /tmp/bloxette/whitelist-raw
      else
        echo "$line" >> /tmp/bloxette/whitelist-raw
      fi
    done < /var/lib/bloxette/whitelists.txt
  fi
  if [ -f /tmp/bloxette/whitelist-raw ]; then
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then
        continue
      elif [[ "$line" == "#"* ]]; then
        continue
      elif [[ "$line" == *"::"* ]]; then
        echo "$line" | awk "{print $1}" >> /tmp/bloxette/whitelist-ipv6
      else
        echo "$line" | awk "{print $1}" >> /tmp/bloxette/whitelist-ipv4
      fi
    done < /tmp/bloxette/whitelist-raw
  fi

  touch /tmp/bloxette/blocklist-raw /tmp/bloxette/blocklist-ipv4 /tmp/bloxette/blocklist-ipv6
  if [ -f /var/lib/bloxette/blocklists.txt ]; then
    echo "TODO"
  fi
fi

exit
