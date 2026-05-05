.PHONY: build test test-verbose clean

build:
	forge build

test:
	forge test -vvv

test-verbose:
	forge test -vvvv --gas-report

clean:
	rm -rf out cache

all: build test
