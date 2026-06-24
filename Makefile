.PHONY: test test-unit coverage lint clean help

SHELL := /usr/bin/env bash
BATS := $(shell command -v bats 2>/dev/null || echo "bats")
SHELLCHECK := $(shell command -v shellcheck 2>/dev/null || echo "shellcheck")
KCOV := $(shell command -v kcov 2>/dev/null || echo "kcov")
COVERAGE_MIN ?= 95

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

test: ## Run the full test suite
	@$(BATS) --recursive test/

test-unit: ## Run unit tests only (no tmux server needed)
	@$(BATS) --recursive test/lib/

coverage: ## Measure line coverage with kcov and enforce COVERAGE_MIN (Linux)
	@command -v kcov >/dev/null 2>&1 || { \
		echo "kcov is not installed. On Ubuntu: sudo apt-get install -y kcov"; exit 1; }
	@rm -rf coverage
	@$(KCOV) --include-path=$(CURDIR)/src --exclude-pattern=previews.sh \
		coverage "$(BATS)" --recursive test/ >/dev/null
	@percent=$$(python3 -c "import json,glob; \
files=glob.glob('coverage/kcov-merged/coverage.json') or glob.glob('coverage/*/coverage.json'); \
data=json.load(open(sorted(files)[-1])) if files else {}; \
print(data.get('percent_covered', '0'))"); \
	echo "Line coverage: $$percent% (min $(COVERAGE_MIN)%)"; \
	awk -v p="$$percent" -v m="$(COVERAGE_MIN)" 'BEGIN { exit (p+0 >= m+0) ? 0 : 1 }' || \
		{ echo "Coverage below $(COVERAGE_MIN)%"; exit 1; }

lint: ## Run shellcheck on all shell files
	@find . -type f \( -name "*.sh" -o -name "*.tmux" -o -name "*.bash" \) \
		-not -path "./.git/*" -not -path "./specs/*" -not -path "./coverage/*" | sort | \
		xargs $(SHELLCHECK) --severity=warning

clean: ## Remove log files and temp artifacts
	@rm -rf /tmp/tiling-test-* coverage
	@echo "Cleaned up temp files."
