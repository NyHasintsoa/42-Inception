FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y \
    php8.2-mysql \
    php8.2-cli \
    curl && \
    rm -rf /var/lib/apt/lists/*

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]