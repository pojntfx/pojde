FROM debian:10

# Choose init system
ARG POJDE_OPENRC='false'
ENV POJDE_OPENRC ${POJDE_OPENRC}

# Disable interactive prompts
ENV DEBIAN_FRONTEND noninteractive

# Setup environment
RUN mkdir -p /opt/pojde
WORKDIR /opt/pojde

# Add versions
COPY versions.sh .

# Create build scripts directory
RUN mkdir -p /opt/pojde/build
WORKDIR /opt/pojde/build

# Run build scripts
COPY build/repositories.sh .
RUN ./repositories.sh

COPY build/init.sh .
RUN ./init.sh

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

COPY build/ssh.sh .
RUN ./ssh.sh

COPY build/nginx.sh .
RUN ./nginx.sh

COPY build/docker.sh .
RUN ./docker.sh

COPY build/webwormhole.sh .
RUN ./webwormhole.sh

COPY build/clean.sh .
RUN ./clean.sh

# Add `pojdectl`
COPY bin/* /usr/bin/

# Clean up
RUN rm -rf /opt/pojde/build

# Create preferences & CA directories
RUN mkdir -p /opt/pojde/preferences
RUN mkdir -p /opt/pojde/ca

# Add configuration scripts
RUN mkdir -p /opt/pojde/configuration
COPY configuration/* /opt/pojde/configuration/

# Add module scripts
RUN mkdir -p /opt/pojde/modules
COPY modules/* /opt/pojde/modules/

# Go back to home dir
WORKDIR /root

CMD ["/lib/systemd/systemd"]
