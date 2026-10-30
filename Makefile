# Commands for jev-trader. Run `make` to list them.
#
# The same target names exist in every project: help, install, dev, up, down,
# logs, test, lint, format, build. This one has no production server, so it has
# no deploy targets, and no test suite, so no test target.

PYTHON := .venv/bin/python
IMAGE  := jev-trader

.DEFAULT_GOAL := help
.PHONY: help install dev up down logs lint format build

help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "} /^##@/ {printf "\n\033[1m%s\033[0m\n", substr($$0, 5)} \
		/^[a-zA-Z0-9_%-]+:.*## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##@ Local

.env:
	cp .env.example .env

install: .env ## Create .venv and install the bot (dry-runs until PRIVATE_KEY is set)
	python3 -m venv .venv
	$(PYTHON) -m pip install -e .

dev: .env ## Run the bot and dashboard on http://localhost:3000
	$(PYTHON) -m jev_trader

up: build .env ## Run it in Docker, in the background
	docker run -d --name $(IMAGE) --env-file .env -p 3000:3000 $(IMAGE)

down: ## Stop the Docker container
	docker rm -f $(IMAGE)

logs: ## Tail the Docker container's logs
	docker logs -f $(IMAGE)

lint: ## Ruff lint + format check
	uvx ruff check jev_trader scripts
	uvx ruff format --check jev_trader scripts

format: ## Ruff autofix + format
	uvx ruff check --fix jev_trader scripts
	uvx ruff format jev_trader scripts

build: ## Build the Docker image
	docker build -t $(IMAGE) .
