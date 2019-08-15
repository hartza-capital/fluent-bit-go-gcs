all: build

dep:
	@if [ ! -d "./vendor" ]; then dep ensure -v; fi

container:
	@echo "Build image"
	@docker build --no-cache -t quay.io/universe-sh/fluent-bit-out-gcs:1.1.3 .

build: dep
	@echo "Build library"
	@go build -buildmode=c-shared -o out_gcs.so

clean:
	@rm -rf *.so *.h *~
