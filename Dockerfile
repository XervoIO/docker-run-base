FROM onmodulus/image-base:1.0.0

ADD . /opt/modulus

RUN /opt/modulus/bootstrap.sh

CMD ["/sbin/my_init"]
