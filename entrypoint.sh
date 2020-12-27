#!/bin/sh

NAMED_RECURSION=${NAMED_RECURSION:-no}

if [ -z "$NAMED_REPO" ]; then
  echo "NAMED Repository is not specified." >&2
  exit 1
fi

if [ ! -f /etc/rndc.key ]; then
  echo "Generate /etc/rndc.key..."
  rndc-confgen -a -k rndc-key -u named -r /dev/urandom
  echo "Generate /etc/rndc.key... done"

fi

if [ ! -d "/var/named/zonedata" ]; then

  echo "Initializing Server Configurations..."
  mkdir -p /var/named
  git clone $NAMED_REPO /var/named/zonedata

  mv -f /etc/named.conf /etc/named.conf.default
  cat /etc/named.conf.default | \
    sed -e '/listen-on port/s//\/\/listen-on port/' \
        -e '/listen-on-v6 port/s//\/\/listen-on-v6 port/' \
        -e '/allow-query/s/localhost/any/' \
        -e "/recursion yes/s//recursion $NAMED_RECURSION/" \
    >/etc/named.conf

  echo -e '// rndc config' >>/etc/named.conf
  echo -e 'include "/etc/rndc.key";' >>/etc/named.conf
  echo -e 'controls { inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; }; };' >>/etc/named.conf
  echo -e "\n" >>/etc/named.conf

  echo -e '// define nameservers' >>/etc/named.conf
  echo -e "include \"/var/named/servers.conf\";" >>/etc/named.conf
  echo -e "\n" >>/etc/named.conf

  echo -e '// load zone definitions as master or slave' >>/etc/named.conf
  for ns in `egrep '^\s*MASTER_SERVERS' /var/named/zonedata/config.mk | sed -e 's/^.*=\s*//'`; do
    echo "include \"/var/named/zonedata/$ns/my-role.conf\";" >>/etc/named.conf
  done

  echo "Initializing Server Configurations... done"

fi

make -C /var/named NAMED_ROLE=$NAMED_ROLE all
(while true; do \
  sleep 60; \
  make -C /var/named NAMED_ROLE=$NAMED_ROLE reload; \
done) &
exec /usr/sbin/named -u named -c /etc/named.conf -g
