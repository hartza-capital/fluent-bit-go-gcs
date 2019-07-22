FROM golang:1.12 as gobuilder

ENV GOOS=linux\
    GOARCH=amd64

RUN go get -u github.com/golang/dep/cmd/dep

WORKDIR ${GOPATH}/src/fluent-bit-out-gcs
COPY . .
RUN make

# Experimental: the library github.com/fluent/fluent-bit-go
# is based on v1.1 branch
FROM fluent/fluent-bit:1.2.1

COPY --from=gobuilder /go/src/fluent-bit-out-gcs/out_gcs.so /fluent-bit/bin/
COPY --from=gobuilder /go/src/fluent-bit-out-gcs/fluent-bit.conf /fluent-bit/etc/
COPY --from=gobuilder /go/src/fluent-bit-out-gcs/plugins.conf /fluent-bit/etc/

EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
