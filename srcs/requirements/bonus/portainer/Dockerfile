FROM debian:trixie

RUN apt-get update -y && \
    apt-get install -y curl tar ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://github.com/portainer/portainer/releases/download/2.45.1/portainer-2.45.1-linux-amd64.tar.gz | tar -xz -C /opt/

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9090

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]