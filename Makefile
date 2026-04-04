.PHONY: test lint clean help

SHELL := /usr/bin/env bash
BATS := $(shell command -v bats 2>/dev/null || echo "bats")
SHELLCHECK := $(shell command -v shellcheck 2>/dev/null || echo "shellcheck")

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

test: ## Run the full test suite
	@$(BATS) --recursive test/

test-unit: ## Run unit tests only (no tmux server needed)
	@$(BATS) --recursive test/lib/

lint: ## Run shellcheck on all shell files
	@find . -type f \( -name "*.sh" -o -name "*.tmux" -o -name "*.bash" \) \
		-not -path "./.git/*" -not -path "./specs/*" | sort | \
		xargs $(SHELLCHECK) --severity=warning

clean: ## Remove log files and temp artifacts
	@rm -rf /tmp/tiling-test-*
	@echo "Cleaned up temp files."
