.PHONY: check install unlink test

check:
	./install --check

install:
	./install --apply

unlink:
	./scripts/unlink

test:
	./scripts/test
