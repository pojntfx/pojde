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

COPY build/code-server.sh .
RUN ./code-server.sh

COPY build/ttyd.sh .
RUN ./ttyd.sh

COPY build/novnc.sh .
RUN ./novnc.sh

COPY build/jupyter-lab.sh .
RUN ./jupyter-lab.sh

COPY build/nginx.sh .
RUN ./nginx.sh

# Clean up
RUN rm -rf /opt/pojde-ng/build

# Add configuration scripts
RUN mkdir -p /opt/pojde-ng/configuration
COPY configuration/* /opt/pojde-ng/configuration

# Go back to home dir
WORKDIR /root

CMD ["/lib/systemd/systemd"]
