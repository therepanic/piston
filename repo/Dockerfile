FROM debian:buster-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list \
 && sed -i '/buster-updates/d' /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
 && apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git jq unzip xz-utils gnupg pkg-config \
    build-essential autoconf cmake g++ gawk bison flex \
    python3 \
    zlib1g-dev libbz2-dev liblzma-dev libffi-dev \
    libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    libxml2-dev libcurl4-openssl-dev \
    libncurses5-dev libncursesw5-dev \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /bin/bash /bin/sh

ADD entrypoint.sh mkindex.sh serve.py /
ENTRYPOINT ["bash","/entrypoint.sh"]
CMD ["--no-build"]
