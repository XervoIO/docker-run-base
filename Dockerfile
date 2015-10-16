FROM onmodulus/docker-base

ADD . /opt/modulus

RUN /opt/modulus/bootstrap.sh

CMD ["/sbin/my_init"]
