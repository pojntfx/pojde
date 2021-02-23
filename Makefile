all: build build-sysvinit

.PHONY: build apply

pre:
	chmod +x ./build/*.sh
	chmod +x ./configuration/*.sh
	chmod +x ./bin/*

build: pre
	docker build -t pojntfx/pojde-ng:latest .

build-sysvinit: pre
	docker build --build-arg POJDE_NG_SYSVINIT='true' -t pojntfx/pojde-ng:latest-sysvinit .

link: pre
	sudo ln -sf "$(shell pwd)/bin/pojdectl" /usr/bin/pojdectl

install:
	sudo install bin/pojdectl /usr/bin

uninstall:
	sudo rm /usr/bin/pojdectl
