all: build

.PHONY: build apply

# Lifecycle

pre:
	chmod +x ./build/*.sh
	chmod +x ./configuration/*.sh

build: pre
	docker build -t pojntfx/pojde-ng .

apply:
	docker run -d --name pojde-ng --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v pojde-ng-preferences:/opt/pojde-ng/preferences:z -v pojde-ng-ca:/opt/pojde-ng/ca:z -p 18000-18004:8000-8004 -p 18022:8022 pojntfx/pojde-ng
	docker exec -it pojde-ng /opt/pojde-ng/configuration/parameters.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/user.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/code-server.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/ttyd.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/novnc.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/jupyter-lab.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/nginx.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/ssh.sh
	docker exec -it pojde-ng /opt/pojde-ng/configuration/webwormhole.sh

start:
	docker start pojde-ng

stop:
	docker stop pojde-ng

restart:
	docker restart pojde-ng

remove:
	docker rm -f pojde-ng

purge: remove
	docker volume rm pojde-ng-preferences pojde-ng-ca

# Debugging

logs:
	docker exec -it pojde-ng journalctl -f

enter:
	docker exec -it pojde-ng bash
