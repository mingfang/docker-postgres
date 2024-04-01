FROM postgres:16-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    locales \
    sudo

ENV LANG=en_US.UTF-8
ENV LC_COLLATE=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

# apt-fast
RUN /bin/bash -c "$(curl -sL https://git.io/vokNn)"
RUN apt-fast install -y --no-install-recommends \
    git \
    vim \
    unzip

RUN apt-fast install -y --no-install-recommends \
    build-essential \
    make \
    gcc \
    cmake \
    postgresql-server-dev-16 \
    libcurl4-gnutls-dev \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison

# python
RUN apt-fast install -y python3 python3-pip postgresql-plpython3-16
RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED || true
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 100

RUN pip install rdflib

# pgx
RUN curl -sfL https://install.pgx.sh | sh -

# citus
RUN curl https://install.citusdata.com/community/deb.sh > add-citus-repo.sh && \
    bash add-citus-repo.sh && \
    apt-fast -y install postgresql-16-citus-12.1

# pg_cron
RUN pgxman install pg_cron=1.6.2

# pgmq
RUN pgxman install pgmq=1.1.0

# mysql fdw
RUN pgxman install mysql_fdw=2.9.1

# pg_vector
RUN git clone --branch v0.6.2 https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make && \
    make install && \
    cd .. && rm -rf pgvector

# pg_net
#RUN apt-fast install -y libcurl3-gnutls
RUN wget https://github.com/supabase/pg_net/releases/download/v0.8.0/pg_net-v0.8.0-pg16-amd64-linux-gnu.deb && \
    apt install ./*.deb && \
    rm *.deb

# http
RUN wget -O - https://github.com/pramsey/pgsql-http/archive/refs/tags/v1.6.0.tar.gz | tar zx && \
    cd pgsql-http* && \
    make && \
    make install && \
    cd .. && rm -rf pgsql-http*

# ParadeDB

ARG PARADEDB_VERSION=v0.5.11

# pg_analytics
RUN wget https://github.com/paradedb/paradedb/releases/download/${PARADEDB_VERSION}/pg_analytics-${PARADEDB_VERSION}-pg16-amd64-ubuntu2204.deb && \
    apt install ./*.deb && \
    rm *.deb

# pg_bm25
RUN wget https://github.com/paradedb/paradedb/releases/download/${PARADEDB_VERSION}/pg_bm25-${PARADEDB_VERSION}-pg16-amd64-ubuntu2204.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu70_70.1-2ubuntu1_amd64.deb && \
    apt install ./*.deb && \
    rm *.deb

# pg_sparse
RUN wget https://github.com/paradedb/paradedb/releases/download/${PARADEDB_VERSION}/pg_sparse-${PARADEDB_VERSION}-pg16-amd64-ubuntu2204.deb && \
    apt install ./*.deb && \
    rm *.deb

# pgsql-ogr-fdw

RUN apt-fast install -y postgresql-common && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt update && \
    apt-fast install -y postgresql-16-ogr-fdw

# postgis
RUN apt-fast install -y postgresql-16-postgis-3

# pgrouting
# https://docs.pgrouting.org/latest/en/pgRouting-installation.html

RUN apt-fast install -y cmake libboost-graph-dev
RUN wget -O - https://github.com/pgRouting/pgrouting/archive/v3.6.1.tar.gz | tar zx && \
    cd pgrouting* && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    cd ../.. && \
    rm -rf pgrouting*

# age
RUN SHA=082aafa git clone --depth 1 --branch master https://github.com/apache/age.git && \
    cd age* && \
    make && \
    make install && \
    cd .. && rm -rf age*

RUN apt-fast install -y osm2pgsql

# supa_audit
RUN git clone --branch v0.3.1 https://github.com/supabase/supa_audit.git && \
    cd supa_audit && \
    make && \
    make install && \
    cd .. && rm -rf supa_audit

