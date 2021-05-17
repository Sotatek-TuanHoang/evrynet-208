# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gev android ios gev-cross evm all test clean
.PHONY: gev-linux gev-linux-386 gev-linux-amd64 gev-linux-mips64 gev-linux-mips64le
.PHONY: gev-linux-arm gev-linux-arm-5 gev-linux-arm-6 gev-linux-arm-7 gev-linux-arm64
.PHONY: gev-darwin gev-darwin-386 gev-darwin-amd64
.PHONY: gev-windows gev-windows-386 gev-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest
GORUN = env GO111MODULE=on go run

gev:
	$(GORUN) build/ci.go install ./cmd/gev
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gev\" to launch gev."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/geth.aar\" to use the library."

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Geth.framework\" to use the library."

test: all
	$(GORUN) build/ci.go test

lint: ## Run linters.
	$(GORUN) build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

gev-cross: gev-linux gev-darwin gev-windows gev-android gev-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gev-*

gev-linux: gev-linux-386 gev-linux-amd64 gev-linux-arm gev-linux-mips64 gev-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-*

gev-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gev
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep 386

gev-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gev
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep amd64

gev-linux-arm: gev-linux-arm-5 gev-linux-arm-6 gev-linux-arm-7 gev-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep arm

gev-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gev
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep arm-5

gev-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gev
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep arm-6

gev-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gev
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep arm-7

gev-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gev
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep arm64

gev-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gev
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep mips

gev-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gev
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep mipsle

gev-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gev
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep mips64

gev-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gev
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gev-linux-* | grep mips64le

gev-darwin: gev-darwin-386 gev-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gev-darwin-*

gev-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gev
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gev-darwin-* | grep 386

gev-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gev
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gev-darwin-* | grep amd64

gev-windows: gev-windows-386 gev-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gev-windows-*

gev-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gev
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gev-windows-* | grep 386

gev-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gev
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gev-windows-* | grep amd64
