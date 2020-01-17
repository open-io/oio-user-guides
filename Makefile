
LINT_USE_DOCKER ?= true

all: lint build test

# Search for scripts to lint with shellcheck
ifeq ($(LINT_USE_DOCKER),true)
lint: CMD_PREFIX=docker run -t --rm -v $(CURDIR):$(CURDIR) -w /repo koalaman/shellcheck-alpine
lint: docker
	@command -v docker >/dev/null || ( echo "ERROR: docker command not found. Exiting." && exit 1)
	@docker info >/dev/null || ( echo "ERROR: docker engine not started. Exiting." && exit 1)
else
lint: CMD_PREFIX=
lint:
	@command -v shellcheck >/dev/null || ( echo "ERROR: shellcheck command not found. Exiting." && exit 1)
endif
# Shell scripts
	@$(CMD_PREFIX) find $(CURDIR) -type f -name "*sh" -exec shellcheck {} \;
# Bats scripts
	@$(CMD_PREFIX) find $(CURDIR) -type f -name "*.bats" -exec shellcheck {} \;
	@echo "== Lint finished"

# Search for Dockerfiles to build images from. Image name is always `openio/<name of directory>` where directory contains the Dockerfile
build: docker
	@set -euo pipefail; for dockerfile in $$(find ./dockerfiles -type f -name Dockerfile);do echo "Building $${dockerfile}"; docker build -t "openio/$$(basename "$$(dirname "$${dockerfile}" )")" "$$(dirname "$${dockerfile}")";done
	@echo "== Build finished"


# Search for files with extension *.bats and run test suites with bats
test:
	@command -v bats >/dev/null || ( echo "ERROR: bats command not found. Exiting." && exit 1)
	@for testfile in $$(find . -type f -name "*.bats");do echo "Testing $${testfile}"; bats "$${testfile}"; done
	@echo "== Tests finished"

docker:
	@command -v docker >/dev/null || ( echo "ERROR: docker command not found. Exiting." && exit 1)
	@docker info >/dev/null || ( echo "ERROR: docker engine not started. Exiting." && exit 1)

.PHONY: all lint build test docker
