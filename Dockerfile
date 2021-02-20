FROM jrei/systemd-debian:10

# Setup environment
RUN mkdir -p /opt/pojde-ng/build
WORKDIR /opt/pojde-ng/build

# Run scripts
COPY build/repositories.sh .
RUN ./repositories.sh

COPY build/packages.sh .
RUN ./packages.sh

COPY build/cockpit.sh .
RUN ./cockpit.sh

# Go back to home dir
WORKDIR /root

CMD ["/lib/systemd/systemd"]
