FROM centos:7
MAINTAINER Daekyu Lee <dklee@yidigun.com>

ENV NAMED_ROLE ""
ENV NAMED_REPO ""
ENV NAMED_RECURSION no

RUN yum -y install bind bind-utils make; \
    yum -y install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm; \
    yum -y --enablerepo=WANdisco-git install git; \
    yum -y clean all; \
    rm -rf /var/cache/yum

ADD ./ /

EXPOSE 53/tcp
EXPOSE 53/udp

CMD [ "/entrypoint.sh" ]
