FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y python3 && \
    rm -rf /var/lib/apt/lists/*

COPY site/ /var/www/static/
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]