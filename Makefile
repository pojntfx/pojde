all: build

.PHONY: build apply

pre:
	chmod +x ./build/*.sh
	chmod +x ./configuration/*.sh
	chmod +x ./bin/*

build: pre
	docker build -t pojntfx/pojde-ng .

link: pre
	sudo ln -sf "$(shell pwd)/bin/pojdectl" /usr/local/bin/pojdectl

install:
	sudo install bin/pojdectl /usr/local/bin

uninstall:
	sudo rm /usr/local/bin/pojdectl
