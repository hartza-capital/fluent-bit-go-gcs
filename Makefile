all: build

container:
	@echo "Build image"
	@docker build --no-cache -t docker.pkg.github.com/universe-sh/fluent-bit-out-gcs/app:1.2.2 .

build:
	@echo "Build library"
	@go build -ldflags "-w -s" -buildmode=c-shared -o out_gcs.so

clean:
	@rm -rf *.so *.h *~
