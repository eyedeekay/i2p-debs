
dummy:

update:
	git pull

setup: update docker clean run

clean: clean-i2p-debs clean-i2pd

docker: docker-i2p-debs docker-i2pd

run: run-i2p-debs run-i2pd

clean-i2p-debs:
	docker rm -f i2p-debs; true

docker-i2p-debs:
	docker build -f Dockerfiles/Dockerfile.i2p-debs -t eyedeekay/i2p-debs .

network:
	docker network create i2p-debs; true

run-i2p-debs: network
	docker run \
		-d \
		--name i2p-debs \
		--network i2p-debs \
		--network-alias i2p-debs \
		--hostname i2p-debs \
		--link i2p-debs-i2pd \
		--cap-drop all \
		-p 127.0.0.1::45291 \
		--restart always \
		-t eyedeekay/i2p-debs

clean-i2pd:
	docker rm -f i2p-debs-i2pd; true

docker-i2pd:
	docker build -f Dockerfiles/Dockerfile.i2p-debs-i2pd -t eyedeekay/i2p-debs-i2pd .

run-i2pd: network
	docker run \
		-d \
		--name i2p-debs-i2pd \
		--network i2p-debs \
		--network-alias i2p-debs-i2pd \
		--hostname i2p-debs-i2pd \
		--link i2p-debs \
		-p :4567 \
		-p 127.0.0.1::7068 \
		-v $(PWD)/i2pd_dat:/var/lib/i2pd \
		--restart always \
		-t eyedeekay/i2p-debs-i2pd

surf:
	surf http://127.0.0.1:45291

dylynx = $(shell docker port i2p-debs-i2pd | sed 's|7068/tcp -> ||g')

echo:
	@echo $(dylynx)

lynx:
	/usr/bin/lynx http://$(dylynx)
