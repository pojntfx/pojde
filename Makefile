all: build

build:
	docker build -t pojntfx/pojde-ng .

start: build
	docker run -d --name pojde-ng --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 18000-18004:8000-8004 -p 18022:8022 pojntfx/pojde-ng

logs:
	docker exec -it pojde-ng journalctl -f

stop:
	docker rm -f pojde-ng

enter:
	docker exec -it pojde-ng bash