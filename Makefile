BINARY_NAME=process-compose
RM=rm
VERSION = $(shell git describe --abbrev=0)
ifeq ($(OS),Windows_NT)
	EXT=.exe
	RM = cmd /C del /Q /F
endif

.PHONY: test run testrace

buildrun: build run

swag:
	~/go/bin/swag init --dir src --output src/docs --parseDependency --parseInternal --parseDepth 1

build:
	go build -o bin/${BINARY_NAME}${EXT} -ldflags="-X main.version=${VERSION}" ./src

compile:
	# Linux
	GOOS=linux GOARCH=386 go build -o bin/${BINARY_NAME}-linux-386 -ldflags="-X main.version=${VERSION}"  ./src
	GOOS=linux GOARCH=amd64 go build -o bin/${BINARY_NAME}-linux-amd64 -ldflags="-X main.version=${VERSION}"  ./src
	GOOS=linux GOARCH=arm64 go build -o bin/${BINARY_NAME}-linux-arm64 -ldflags="-X main.version=${VERSION}"  ./src
	GOOS=linux GOARCH=arm go build -o bin/${BINARY_NAME}-linux-arm -ldflags="-X main.version=${VERSION}"  ./src

	# Windows
	GOOS=windows GOARCH=amd64 go build -o bin/${BINARY_NAME}-windows-amd64.exe  -ldflags="-X main.version=${VERSION}" ./src

test:
	go test -cover ./src/...

testrace:
	go test -race ./src/...

coverhtml:
	go test -coverprofile=coverage.out ./src
	go tool cover -html=coverage.out

run:
	PC_DEBUG_MODE=1 ./bin/${BINARY_NAME}${EXT}

clean:
	$(RM) bin/${BINARY_NAME}*
