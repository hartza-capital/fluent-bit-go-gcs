# Experimental: the library github.com/fluent/fluent-bit-go
# is based on v1.2 branch
FROM fluent/fluent-bit:1.3.3

ARG BUILD_DATE
ARG VCS_REF

# These are pretty static
LABEL maintainer="Universe.sh <https://github.com/universe-sh/fluent-bit-go-gcs/issues>" \
    org.opencontainers.image.title="fluent-bit-go-gcs" \
    org.opencontainers.image.description="Universe.sh Fluent-Bit Go GCS" \
    org.opencontainers.image.url="https://github.com/fluent-bit-go-gcs-sh/satellite" \
    org.opencontainers.image.source="git@github.com:universe-sh/fluent-bit-go-gcs" \
    org.opencontainers.image.vendor="Universe.sh" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="fluent-bit-go-gcs" \
    org.label-schema.description="Universe.sh Fluent-Bit Go GCS" \
    org.label-schema.url="https://github.com/universe-sh/fluent-bit-go-gcs" \
    org.label-schema.vcs-url="git@github.com:universe-sh/fluent-bit-go-gcs" \
    org.label-schema.vendor="Universe.sh"

# These will change for every build
LABEL org.opencontainers.image.revision="$VCS_REF" \
    org.opencontainers.image.created="$BUILD_DATE" \
    org.label-schema.vcs-ref="$VCS_REF" \
    org.label-schema.build-date="$BUILD_DATE"

COPY out_gcs.so /fluent-bit/bin/
COPY plugins.conf /fluent-bit/etc/

EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
