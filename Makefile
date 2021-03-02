all: build build-openrc

.PHONY: build apply

pre:
	chmod +x ./bin/*
	chmod +x ./build/*.sh
	chmod +x ./configuration/*.sh
	chmod +x ./modules/*.sh

build: pre
	docker build --build-arg POJDE_NG_OPENRC=false -t pojntfx/pojde-ng:latest .

build-openrc: pre
	docker build --build-arg POJDE_NG_OPENRC=true -t pojntfx/pojde-ng:latest-openrc .

link: pre
	sudo ln -sf "$(shell pwd)/bin/pojdectl-ng" /usr/local/bin/pojdectl-ng

install:
	sudo install bin/pojdectl-ng /usr/local/bin

uninstall:
	sudo rm /usr/local/bin/pojdectl
