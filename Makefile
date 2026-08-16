GO      ?= go
PKGS    ?= ./...
COVER   ?= coverage.out

.DEFAULT_GOAL := check

.PHONY: check
check: tidy-check fmt-check vet lint test ## Run every gate CI runs

.PHONY: build
build:
	$(GO) build $(PKGS)

.PHONY: test
test:
	$(GO) test -race -shuffle=on -covermode=atomic -coverprofile=$(COVER) $(PKGS)

.PHONY: cover
cover: test
	$(GO) tool cover -func=$(COVER) | tail -1

.PHONY: vet
vet:
	$(GO) vet $(PKGS)

.PHONY: lint
lint:
	golangci-lint run

.PHONY: fmt
fmt:
	golangci-lint fmt

.PHONY: fmt-check
fmt-check:
	golangci-lint fmt --diff

.PHONY: tidy
tidy:
	$(GO) mod tidy

# Fails when go.mod/go.sum are not what `go mod tidy` would produce.
.PHONY: tidy-check
tidy-check:
	$(GO) mod tidy -diff

.PHONY: clean
clean:
	rm -f $(COVER)
	$(GO) clean -testcache

.PHONY: help
help:
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "%-12s %s\n", $$1, $$2}'
