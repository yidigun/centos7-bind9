FROM centos:7
MAINTAINER Daekyu Lee <dklee@yidigun.com>

ENV NAMED_ROLE ""
ENV NAMED_REPO ""
ENV NAMED_RECURSION no

RUN yum -y install bind bind-utils git make; \
    yum -y clean all; \
    rm -rf /var/cache/yum

ADD ./ /

EXPOSE 53/tcp
EXPOSE 53/udp

CMD [ "/entrypoint.sh", "start" ]
