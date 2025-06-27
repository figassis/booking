setup:
	poetry install

.PHONY: start
start:
	docker compose up -d
	cd squire && poetry run uvicorn app.main:app --reload