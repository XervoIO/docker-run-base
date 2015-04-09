FROM onmodulus/image-base:0.0.1

ADD . /opt/modulus

RUN /opt/modulus/bootstrap.sh

CMD ["/sbin/my_init"]
