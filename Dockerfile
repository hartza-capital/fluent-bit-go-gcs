FROM golang:1.12 as gobuilder

ENV GOOS=linux\
    GOARCH=amd64

# RUN apt-get install -y ca-certificates git gcc g++ libc-dev git make
RUN go get -u github.com/golang/dep/cmd/dep

WORKDIR ${GOPATH}/src/fluent-bit-out-gcs
COPY . .
RUN make

FROM fluent/fluent-bit:1.2.0

COPY --from=gobuilder /go/src/fluent-bit-out-gcs/out_gcs.so /fluent-bit/bin/
COPY --from=gobuilder /go/src/fluent-bit-out-gcs/fluent-bit.conf /fluent-bit/etc/
COPY --from=gobuilder /go/src/fluent-bit-out-gcs/plugins.conf /fluent-bit/etc/

EXPOSE 2020

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]
