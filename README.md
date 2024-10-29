# bloxette

An ipset-based blocklist tool inspired by [banIP](https://github.com/openwrt/packages/blob/master/net/banip/files/README.md), [this ServerFault post](https://serverfault.com/a/1115842), [this ServerFault post](https://serverfault.com/a/675605), and [this OpenWrt forum post](https://forum.openwrt.org/t/nftables-chokes-on-very-large-sets/172580).

### Background

I really, really wanted nftables named sets to work as advertised since iptables is deprecated. [According to RedHat](https://developers.redhat.com/blog/2017/04/11/benchmarking-nftables), [nftables named sets](https://wiki.nftables.org/wiki-nftables/index.php/Sets) are just as performant as [iptables ipset](https://ipset.netfilter.org/), but my personal testing and online research suggests otherwise. After wrestling with nftables for way too long, I just did what many IT professionals are doing -- returned to iptables. _Sigh_

### Prerequisites

- [cidr-merger](https://github.com/zhanhb/cidr-merger)

```
sudo apt-get install golang-go
sudo curl -sLo /usr/local/bin/cidr-merger https://github.com/zhanhb/cidr-merger/releases/latest/download/cidr-merger-linux-arm64
sudo chmod +x /usr/local/bin/cidr-merger
```

- curl
- iptables
- ipset
- git
- cron
- jq

```
sudo apt-get autopurge -y nftables
sudo apt-get install -y curl iptables ipset git cron jq
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
```

### Installation

```
sudo git clone https://github.com/ascension-association/bloxette /var/lib/bloxette
sudo chown -R $USER:$USER /var/lib/bloxette
chmod +x /var/lib/bloxette/bloxette.sh
sudo ln -s /var/lib/bloxette/bloxette.sh /usr/local/bin/bloxette
```

### Configuration

1. Edit /var/lib/bloxette/whitelists.txt, /var/lib/bloxette/blocklists.txt, and /var/lib/bloxette/geo.txt as needed
2. Run `bloxette update`
3. Add to cron: `(crontab -l ; echo "2 30 * * * sleep $((RANDOM % 1800)) && /usr/local/bin/bloxette") | sudo crontab -`
