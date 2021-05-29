all: build build-openrc

.PHONY: build apply

pre:
	chmod +x ./bin/*
	chmod +x versions.sh
	chmod +x ./build/*.sh
	chmod +x ./configuration/*.sh
	chmod +x ./modules/*.sh

build: pre
	docker build --build-arg POJDE_OPENRC=false -t pojntfx/pojde:latest .

build-openrc: pre
	docker build --build-arg POJDE_OPENRC=true -t pojntfx/pojde:latest-openrc .

link: pre
	sudo ln -sf "$(shell pwd)/bin/pojdectl" /usr/local/bin/pojdectl

install:
	sudo install bin/pojdectl /usr/local/bin

uninstall:
	sudo rm /usr/local/bin/pojdectl
