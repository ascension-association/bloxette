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
  if [ -f /tmp/bloxette/whitelist-ipv6-cidr ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      echo "add bloxette-whitelist6 $line" >> /tmp/bloxette/whitelist-ipv6-ipset
    done < /tmp/bloxette/whitelist-ipv6-cidr
  fi
  sudo ip6tables -D INPUT -m set --match-set bloxette-whitelist6 dst -j ACCEPT > /dev/null 2>&1
  sudo ip6tables -D FORWARD -m set --match-set bloxette-whitelist6 dst -j ACCEPT > /dev/null 2>&1
  sudo ipset destroy bloxette-whitelist6 > /dev/null 2>&1
  if [ -f /tmp/bloxette/whitelist-ipv6-ipset ]; then
    sudo ipset create bloxette-whitelist6 hash:net family inet6 hashsize 131072 maxelem 10000000 timeout 0
    sudo ipset restore < /tmp/bloxette/whitelist-ipv6-ipset
    sudo ip6tables -A INPUT -m set --match-set bloxette-whitelist6 dst -j ACCEPT
    sudo ip6tables -A FORWARD -m set --match-set bloxette-whitelist6 dst -j ACCEPT
  fi
  if [ -f /tmp/bloxette/whitelist-ipv4-cidr ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      echo "add bloxette-whitelist4 $line" >> /tmp/bloxette/whitelist-ipv4-ipset
    done < /tmp/bloxette/whitelist-ipv4-cidr
  fi
  sudo iptables -D INPUT -m set --match-set bloxette-whitelist4 dst -j ACCEPT > /dev/null 2>&1
  sudo iptables -D FORWARD -m set --match-set bloxette-whitelist4 dst -j ACCEPT > /dev/null 2>&1
  sudo ipset destroy bloxette-whitelist4 > /dev/null 2>&1
  if [ -f /tmp/bloxette/whitelist-ipv4-ipset ]; then
    sudo ipset create bloxette-whitelist4 hash:net family inet hashsize 131072 maxelem 10000000 timeout 0
    sudo ipset restore < /tmp/bloxette/whitelist-ipv4-ipset
    sudo iptables -A INPUT -m set --match-set bloxette-whitelist4 dst -j ACCEPT
    sudo iptables -A FORWARD -m set --match-set bloxette-whitelist4 dst -j ACCEPT
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
      elif [[ "$line" == *":"* ]]; then
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
  if [ -f /tmp/bloxette/blocklist-ipv6-cidr ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      echo "add bloxette-blocklist6 $line" >> /tmp/bloxette/blocklist-ipv6-ipset
    done < /tmp/bloxette/blocklist-ipv6-cidr
  fi
  sudo ip6tables -D INPUT -m set --match-set bloxette-blocklist6 dst -j DROP > /dev/null 2>&1
  sudo ip6tables -D FORWARD -m set --match-set bloxette-blocklist6 dst -j DROP > /dev/null 2>&1
  sudo ipset destroy bloxette-blocklist6 > /dev/null 2>&1
  if [ -f /tmp/bloxette/blocklist-ipv6-ipset ]; then
    sudo ipset create bloxette-blocklist6 hash:net family inet6 hashsize 131072 maxelem 10000000 timeout 0
    sudo ipset restore < /tmp/bloxette/blocklist-ipv6-ipset
    sudo ip6tables -A INPUT -m set --match-set bloxette-blocklist6 dst -j DROP
    sudo ip6tables -A FORWARD -m set --match-set bloxette-blocklist6 dst -j DROP
  fi
  if [ -f /tmp/bloxette/blocklist-ipv4-cidr ]; then
    while IFS="" read -r line || [ -n "$line" ]
    do
      echo "add bloxette-blocklist4 $line" >> /tmp/bloxette/blocklist-ipv4-ipset
    done < /tmp/bloxette/blocklist-ipv4-cidr
  fi
  sudo iptables -D INPUT -m set --match-set bloxette-blocklist4 dst -j DROP > /dev/null 2>&1
  sudo iptables -D FORWARD -m set --match-set bloxette-blocklist4 dst -j DROP > /dev/null 2>&1
  sudo ipset destroy bloxette-blocklist4 > /dev/null 2>&1
  if [ -f /tmp/bloxette/blocklist-ipv4-ipset ]; then
    sudo ipset create bloxette-blocklist4 hash:net family inet hashsize 131072 maxelem 10000000 timeout 0
    sudo ipset restore < /tmp/bloxette/blocklist-ipv4-ipset
    sudo iptables -A INPUT -m set --match-set bloxette-blocklist4 dst -j DROP
    sudo iptables -A FORWARD -m set --match-set bloxette-blocklist4 dst -j DROP
  fi
fi

exit
