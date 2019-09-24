FROM golang:1.13 as gobuilder

ENV GO111MODULE=on

WORKDIR ${GOPATH}/src/fluent-bit-out-gcs
COPY . .
RUN make

# Experimental: the library github.com/fluent/fluent-bit-go
# is based on v1.1 branch
FROM fluent/fluent-bit:1.2.2

COPY --from=gobuilder /go/src/fluent-bit-out-gcs/out_gcs.so /fluent-bit/bin/
COPY --from=gobuilder /go/src/fluent-bit-out-gcs/fluent-bit.conf /fluent-bit/etc/
COPY --from=gobuilder /go/src/fluent-bit-out-gcs/plugins.conf /fluent-bit/etc/

EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
