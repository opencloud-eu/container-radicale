# This file is intended to be used apart from the containing source code tree.

FROM python:3-alpine@sha256:e08874637f2704667426cb3b8d14581b9cb12dd2c237c8419f65446669443921 AS builder

# Version of Radicale (e.g. v3)
# renovate: datasource=github-releases depName=Kozea/Radicale
ARG VERSION=v3.5.4

# Optional dependencies (e.g. bcrypt or ldap)
ARG DEPENDENCIES=bcrypt

RUN apk add --no-cache --virtual gcc libffi-dev musl-dev \
    && python -m venv /app/venv \
    && /app/venv/bin/pip install --no-cache-dir "Radicale[${DEPENDENCIES}] @ https://github.com/Kozea/Radicale/archive/${VERSION}.tar.gz"


FROM python:3-alpine

WORKDIR /app

RUN addgroup -g 1000 radicale \
    && adduser radicale --home /var/lib/radicale --system --uid 1000 --disabled-password -G radicale \
    && apk add --no-cache ca-certificates openssl

COPY --chown=radicale:radicale --from=builder /app/venv /app

# Persistent storage for data
VOLUME /var/lib/radicale
# TCP port of Radicale
EXPOSE 5232
# Run Radicale
ENTRYPOINT [ "/app/bin/python", "/app/bin/radicale"]
CMD ["--hosts", "0.0.0.0:5232,[::]:5232"]

USER radicale
