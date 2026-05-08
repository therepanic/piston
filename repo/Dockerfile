FROM debian:bullseye-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates curl git jq unzip xz-utils gnupg pkg-config \
    build-essential autoconf cmake g++ gawk bison flex \
    zlib1g-dev libbz2-dev liblzma-dev libffi-dev \
    libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    libxml2-dev libcurl4-openssl-dev \
    libncurses5-dev libncursesw5-dev \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /bin/bash /bin/sh

ADD entrypoint.sh mkindex.sh serve.py /
ENTRYPOINT ["bash","/entrypoint.sh"]
CMD ["--no-build"]
