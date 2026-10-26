PYTHON = python
DBT = dbt
SQLFLUFF = sqlfluff

.PHONY: help debug deps compile run test \
        build docs serve lint format clean all

debug:
	$(DBT) debug --profiles-dir .

deps:
	$(DBT) deps --profiles-dir .

compile:
	$(DBT) compile --profiles-dir .

run:
	$(DBT) run --profiles-dir .

test:
	$(DBT) test --profiles-dir .

build:
	$(DBT) build --profiles-dir .

docs:
	$(DBT) docs generate --profiles-dir .

serve:
	$(DBT) docs serve --profiles-dir . --port 8080

lint:
	$(SQLFLUFF) lint models/

format:
	$(SQLFLUFF) fix models/

clean:
	$(DBT) clean

all: deps lint build docs