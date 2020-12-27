include zonedata/config.mk

RNDC = /usr/sbin/rndc
GIT = /usr/bin/git

all: servers.conf all-recursive

.PHONY: all clean reload remote-reload all-recursive clean-recursive
clean: clean-recursive
	rm -f servers.conf

reload: all
	(cd /var/named/zonedata; \
	$(GIT) pull); \
	$(RNDC) reload

all-recursive:
	for d in $(MASTER_SERVERS); do \
	  $(MAKE) -f /var/named/Makefile.ns -C zonedata/$$d NAMED_ROLE=$(NAMED_ROLE) NAMED_SERVER=$$d all; \
	done

clean-recursive:
	for d in $(MASTER_SERVERS); do \
	  $(MAKE) -f /var/named/Makefile.ns -C zonedata/$$d clean; \
	done

servers.conf: Makefile
	cat /dev/null >$@; \
	echo -e "acl \"all_nameservers\" {" >>$@; \
	for ns in $(NAMESERVERS); do \
	  ip=`host -4 -ta -cIN $${ns} | sed -e 's/^.* //'`; \
	  echo -e "\t$${ip}; // $${ns}" >>$@; \
	done; \
	echo -e "};" >>$@; \
	for ns in $(MASTER_SERVERS); do \
	  masters=`echo $${ns} | sed -e 's/\./_/g'`; \
	  ip=`host -4 -ta -cIN $${ns} | sed -e 's/^.* //'`; \
	  echo -e "masters \"$${masters}\" {" >>$@; \
	  echo -e "\t$${ip}; // $${ns}" >>$@; \
	  echo -e "};" >>$@; \
	done
