all: build

.PHONY: build

# Lifecycle

build:
	chmod +x ./build/*.sh
	docker build -t pojntfx/pojde-ng .

apply:
	docker run -d --name pojde-ng --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 18000-18004:8000-8004 -p 18022:8022 pojntfx/pojde-ng

start:
	docker start pojde-ng

stop:
	docker stop pojde-ng

restart:
	docker restart pojde-ng

remove:
	docker rm -f pojde-ng

# Debugging

logs:
	docker exec -it pojde-ng journalctl -f

enter:
	docker exec -it pojde-ng bash
