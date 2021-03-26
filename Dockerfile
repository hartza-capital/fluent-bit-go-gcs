FROM golang:1.13-stretch as builder

WORKDIR /go/src/github.com/3-shake/fluent-bit-go-gcs
COPY . .
# Set Environment Variable
ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64
# Build
RUN go build -buildmode=c-shared -o out_gcs.so

FROM fluent/fluent-bit:1.3.3

ARG BUILD_DATE
ARG VCS_REF

# These are pretty static
LABEL maintainer="3-shake <https://github.com/3-shake/fluent-bit-go-gcs/issues>" \
    org.opencontainers.image.title="fluent-bit-go-gcs" \
    org.opencontainers.image.description="3-shake Fluent-Bit Go GCS" \
    org.opencontainers.image.url="https://github.com/fluent-bit-go-gcs-sh/satellite" \
    org.opencontainers.image.source="git@github.com:3-shake/fluent-bit-go-gcs" \
    org.opencontainers.image.vendor="3-shake" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="fluent-bit-go-gcs" \
    org.label-schema.description="3-shake Fluent-Bit Go GCS" \
    org.label-schema.url="https://github.com/3-shake/fluent-bit-go-gcs" \
    org.label-schema.vcs-url="git@github.com:3-shake/fluent-bit-go-gcs" \
    org.label-schema.vendor="3-shake"

# These will change for every build
LABEL org.opencontainers.image.revision="$VCS_REF" \
    org.opencontainers.image.created="$BUILD_DATE" \
    org.label-schema.vcs-ref="$VCS_REF" \
    org.label-schema.build-date="$BUILD_DATE"

COPY --from=builder /go/src/github.com/3-shake/fluent-bit-go-gcs/out_gcs.so /fluent-bit/bin/out_gcs.so
COPY plugins.conf /fluent-bit/etc/

EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
