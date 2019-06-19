all: build

dep:
	@if [ ! -d "./vendor" ]; then dep ensure -v; fi

docker:
	@echo "Build image"
	@docker build -t quay.io/universe-sh/fluent-bit-out-gcs:latest .

build: dep
	@echo "Build library"
	@go build -buildmode=c-shared -o out_gcs.so

clean:
	@rm -rf *.so *.h *~
